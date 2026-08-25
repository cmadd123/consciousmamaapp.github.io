// MomRise LLM router. Single chokepoint for all AI calls from anywhere
// in the codebase — feature code never calls Anthropic / OpenAI / Google
// SDKs directly. This file does.
//
// Why this exists:
//   - Cost: cache responses where deterministic; route classification
//     tasks to cheap models (Haiku) and only escalate to Sonnet/Opus
//     when the prompt actually needs it.
//   - Fallback: if Anthropic is down, fall through to OpenAI. If both
//     are down, return a graceful error from cache or static.
//   - Observability: every call logs latency + tokens + provider + cost
//     estimate to a Firestore `llm_call_log` collection (sampled), so
//     we can spot regressions and tune.
//   - Provider lock-in protection: the API contract this file exposes
//     to feature code is stable. Swapping providers is a one-file edit.
//
// Usage from feature code:
//   const { generate } = require('./llm_router');
//   const result = await generate({
//     task: 'mealSuggestion',          // names a configured task profile
//     userId: 'abc',                    // for per-user rate limiting + logging
//     prompt: 'Suggest a Tuesday dinner for a family of 4...',
//     // optional overrides:
//     // model: 'haiku' | 'sonnet' | 'opus' | 'gpt-4o-mini' | 'gpt-4.1'
//     // maxTokens: 1000,
//     // temperature: 0.7,
//     // cacheKey: 'meal-suggestion-haley-tue-nov4',  // skip cache by omitting
//     // fallbackText: 'Sorry, I had trouble generating a suggestion.',
//   });

const Anthropic = require('@anthropic-ai/sdk');
const OpenAI = require('openai');
const { defineSecret } = require('firebase-functions/params');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const crypto = require('crypto');

const anthropicApiKey = defineSecret('ANTHROPIC_API_KEY');
const openaiApiKey = defineSecret('OPENAI_API_KEY');

// Task profiles. Each task names the model + tuning we want. Feature
// code passes a task name; the router picks the model, max tokens, etc.
// Changing the model for a feature = edit this table, no app-code change.
const TASK_PROFILES = {
  mealSuggestion: {
    primary: 'sonnet',
    fallback: 'gpt-4.1',
    maxTokens: 1500,
    temperature: 0.7,
    cacheable: true,
    cacheTtlHours: 24,
  },
  groceryListCurate: {
    primary: 'haiku',
    fallback: 'gpt-4o-mini',
    maxTokens: 600,
    temperature: 0.2,
    cacheable: true,
    cacheTtlHours: 6,
  },
  recipeImportParse: {
    primary: 'haiku',
    fallback: 'gpt-4o-mini',
    maxTokens: 2000,
    temperature: 0.1,
    cacheable: true,
    cacheTtlHours: 24 * 7, // a parsed recipe doesn't change
  },
  // Reverse meal planner — proactive AI that looks at the user's
  // calendar and suggests a structured plan around it. Sonnet because
  // the reasoning is non-trivial.
  reverseMealPlan: {
    primary: 'sonnet',
    fallback: 'gpt-4.1',
    maxTokens: 3000,
    temperature: 0.6,
    cacheable: false, // depends on user state, refresh per request
  },
  // Creator outreach scoring — rate a batch of discovered creators for
  // MomRise partnership fit and draft a personalized opener for each.
  // Sonnet: light reasoning + warm writing, same tier as mealSuggestion.
  creatorScore: {
    primary: 'sonnet',
    fallback: 'haiku',
    maxTokens: 4000,
    temperature: 0.4,
    cacheable: false, // batch-specific; not worth caching
  },
  // Classification: "is this a recipe or not?" / "what cuisine is this?"
  // Always Haiku — cheap, fast, sufficient.
  classify: {
    primary: 'haiku',
    fallback: 'gpt-4o-mini',
    maxTokens: 200,
    temperature: 0,
    cacheable: true,
    cacheTtlHours: 24 * 30,
  },
};

// Model → provider mapping. When Anthropic adds a new tier, add it here.
const MODEL_MAP = {
  haiku: { provider: 'anthropic', id: 'claude-haiku-4-5-20251001', costPer1MIn: 1, costPer1MOut: 5 },
  sonnet: { provider: 'anthropic', id: 'claude-sonnet-4-6', costPer1MIn: 3, costPer1MOut: 15 },
  opus: { provider: 'anthropic', id: 'claude-opus-4-7', costPer1MIn: 15, costPer1MOut: 75 },
  'gpt-4o-mini': { provider: 'openai', id: 'gpt-4o-mini', costPer1MIn: 0.15, costPer1MOut: 0.6 },
  'gpt-4.1': { provider: 'openai', id: 'gpt-4.1', costPer1MIn: 2, costPer1MOut: 8 },
  'gpt-4.1-nano': { provider: 'openai', id: 'gpt-4.1-nano', costPer1MIn: 0.1, costPer1MOut: 0.4 },
};

// In-memory short-circuit cache (per-instance). Firestore is the
// persistent layer for cross-instance cache hits.
const memCache = new Map();
const MEM_CACHE_MAX = 500;

async function generate({
  task,
  userId,
  prompt,
  systemPrompt,
  model,
  maxTokens,
  temperature,
  cacheKey,
  fallbackText,
}) {
  const profile = TASK_PROFILES[task];
  if (!profile) throw new Error(`Unknown LLM task: ${task}`);

  // Allow per-call overrides over task profile defaults.
  const effective = {
    model: model || profile.primary,
    fallbackModel: profile.fallback,
    maxTokens: maxTokens ?? profile.maxTokens,
    temperature: temperature ?? profile.temperature,
    cacheable: profile.cacheable && cacheKey,
    cacheTtlMs: (profile.cacheTtlHours || 0) * 3600 * 1000,
  };

  const finalCacheKey = effective.cacheable
    ? _cacheKey({ task, cacheKey, model: effective.model })
    : null;

  // Cache lookup: memory first, then Firestore.
  if (finalCacheKey) {
    const memHit = memCache.get(finalCacheKey);
    if (memHit && memHit.expiresAt > Date.now()) {
      _logSampled({ task, model: effective.model, cached: 'memory', userId });
      return memHit.text;
    }
    const fsHit = await _firestoreCacheGet(finalCacheKey);
    if (fsHit) {
      memCache.set(finalCacheKey, { text: fsHit, expiresAt: Date.now() + effective.cacheTtlMs });
      _trimMemCache();
      _logSampled({ task, model: effective.model, cached: 'firestore', userId });
      return fsHit;
    }
  }

  // Call primary model. If it fails, try fallback.
  const startMs = Date.now();
  let text, used = effective.model, error;
  try {
    text = await _callModel(effective.model, prompt, systemPrompt, effective.maxTokens, effective.temperature);
  } catch (e) {
    console.warn(`[llm] primary ${effective.model} failed: ${e.message}. Trying fallback ${effective.fallbackModel}.`);
    error = e;
    try {
      text = await _callModel(effective.fallbackModel, prompt, systemPrompt, effective.maxTokens, effective.temperature);
      used = effective.fallbackModel;
    } catch (e2) {
      console.error(`[llm] fallback ${effective.fallbackModel} also failed: ${e2.message}`);
      if (fallbackText) return fallbackText;
      throw new Error(`Both LLM providers failed. Primary: ${e.message}. Fallback: ${e2.message}.`);
    }
  }

  const latencyMs = Date.now() - startMs;

  // Cache write.
  if (finalCacheKey && text) {
    memCache.set(finalCacheKey, { text, expiresAt: Date.now() + effective.cacheTtlMs });
    _trimMemCache();
    await _firestoreCachePut(finalCacheKey, text, effective.cacheTtlMs);
  }

  _logSampled({ task, model: used, cached: 'miss', latencyMs, userId });
  return text;
}

async function _callModel(modelName, prompt, systemPrompt, maxTokens, temperature) {
  const spec = MODEL_MAP[modelName];
  if (!spec) throw new Error(`Unknown model: ${modelName}`);
  if (spec.provider === 'anthropic') {
    const client = new Anthropic({ apiKey: anthropicApiKey.value().trim() });
    const resp = await client.messages.create({
      model: spec.id,
      max_tokens: maxTokens,
      temperature,
      system: systemPrompt || undefined,
      messages: [{ role: 'user', content: prompt }],
    });
    return resp.content?.[0]?.text || '';
  }
  if (spec.provider === 'openai') {
    const client = new OpenAI({ apiKey: openaiApiKey.value().trim() });
    const resp = await client.chat.completions.create({
      model: spec.id,
      max_tokens: maxTokens,
      temperature,
      messages: [
        ...(systemPrompt ? [{ role: 'system', content: systemPrompt }] : []),
        { role: 'user', content: prompt },
      ],
    });
    return resp.choices?.[0]?.message?.content || '';
  }
  throw new Error(`Unknown provider for model ${modelName}: ${spec.provider}`);
}

function _cacheKey({ task, cacheKey, model }) {
  return crypto.createHash('sha256')
    .update(`${task}::${model}::${cacheKey}`)
    .digest('hex')
    .substring(0, 32);
}

function _trimMemCache() {
  if (memCache.size <= MEM_CACHE_MAX) return;
  // Drop oldest 20% when over the cap. Cheap LRU-ish behavior.
  const dropCount = Math.floor(MEM_CACHE_MAX * 0.2);
  const it = memCache.keys();
  for (let i = 0; i < dropCount; i++) memCache.delete(it.next().value);
}

async function _firestoreCacheGet(key) {
  try {
    const snap = await getFirestore().collection('llm_cache').doc(key).get();
    if (!snap.exists) return null;
    const d = snap.data();
    if (d.expires_at?.toMillis?.() < Date.now()) return null;
    return d.text;
  } catch (_) {
    return null; // never let cache failures break a generation call
  }
}

async function _firestoreCachePut(key, text, ttlMs) {
  try {
    const expiresAt = new Date(Date.now() + ttlMs);
    await getFirestore().collection('llm_cache').doc(key).set({
      text,
      created_at: FieldValue.serverTimestamp(),
      expires_at: expiresAt,
    });
  } catch (e) {
    console.warn('[llm] firestore cache write failed:', e.message);
  }
}

// Sampled logging: write 1 in N calls to llm_call_log. The point is
// observability, not audit — full logging at scale gets expensive.
// Adjust SAMPLE_RATE based on volume.
const SAMPLE_RATE = 0.05; // 5% of calls

function _logSampled({ task, model, cached, latencyMs, userId }) {
  if (Math.random() > SAMPLE_RATE) return;
  try {
    getFirestore().collection('llm_call_log').add({
      task,
      model,
      cached,
      latency_ms: latencyMs || null,
      user_id: userId || null,
      at: FieldValue.serverTimestamp(),
    });
  } catch (_) { /* fire-and-forget */ }
}

module.exports = { generate, TASK_PROFILES, MODEL_MAP };

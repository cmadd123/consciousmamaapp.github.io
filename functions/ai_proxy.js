// MomRise — authenticated AI proxy for the mobile app.
//
// Before: the app pulled an OpenAI key from Remote Config (readable by
// anyone with the app binary) and called api.openai.com directly. Now the
// app calls the `aiGenerate` callable; the key never leaves Secret Manager.
//
// Design:
//   - Fixed set of tasks. Each task pins its model/params (llm_router.js
//     TASK_PROFILES) and system prompt (below), so the endpoint can't be
//     used as a general-purpose "any model, any params" OpenAI proxy.
//   - The user prompt is still built in Dart for most tasks (keeps the
//     existing prompts byte-for-byte), but is size-capped per task.
//   - Requires Firebase Auth. Per-user, per-task hourly + daily limits.
//   - App Check: the app does not activate App Check yet (firebase_app_check
//     is only a transitive dependency; see FIREBASE_APP_CHECK_SETUP.md), so
//     enforcement is off. Flip ENFORCE_APP_CHECK once the app ships with
//     FirebaseAppCheck.instance.activate(...) and metrics look clean.
//
// Request:  { task, prompt?, messages?, ingredient1?, ingredient2? }
// Response: { content: string }   — the model's text, exactly what the Dart
//                                  code used to read from
//                                  choices[0].message.content.

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');
const { generate } = require('./llm_router');

const anthropicApiKey = defineSecret('ANTHROPIC_API_KEY');
const openaiApiKey = defineSecret('OPENAI_API_KEY');

const ENFORCE_APP_CHECK = false;

// System prompts copied verbatim from the Dart callers.
const TASKS = {
  appLearningPath: {
    system: 'You are an expert early childhood development specialist who creates practical, parent-friendly learning programs. You understand child psychology and create tasks that are age-appropriate, engaging, and achievable. Always respond with valid JSON only.',
    maxPromptChars: 20000,
    limits: { hour: 10, day: 30 },
  },
  appSkillCurriculum: {
    system: 'You are an expert curriculum designer creating personalized skill learning paths. You reference real expert methodologies and create high-quality, detailed instructional content.',
    maxPromptChars: 40000,
    limits: { hour: 5, day: 15 },
  },
  appActivityIdeas: {
    system: null,
    maxPromptChars: 8000,
    limits: { hour: 30, day: 100 },
  },
  appIngredientMatch: {
    system: "You are a grocery assistant. Determine if two ingredient names refer to the same ingredient, ignoring quantity, preparation, or descriptive differences. Answer ONLY 'yes' or 'no'.",
    maxPromptChars: 400, // per ingredient name
    limits: { hour: 300, day: 1500 },
  },
  appChat: {
    system: null,
    maxPromptChars: 20000, // total across messages
    maxMessages: 40,
    limits: { hour: 60, day: 200 },
  },
};

// Firestore-backed per-user, per-task counters (ai_usage/{uid}). Fixed
// windows; good enough to stop a leaked ID token from draining credits.
// ai_usage is server-only (falls under the default-deny rule).
async function enforceRateLimit(uid, task, limits) {
  const db = getFirestore();
  const ref = db.collection('ai_usage').doc(uid);
  const now = Date.now();
  const HOUR = 3600 * 1000;
  const DAY = 24 * HOUR;
  await db.runTransaction(async (t) => {
    const snap = await t.get(ref);
    const all = snap.exists ? snap.data() : {};
    const u = all[task] || {};
    let hourStart = u.hour_start?.toMillis?.() || 0;
    let dayStart = u.day_start?.toMillis?.() || 0;
    let hourCount = u.hour_count || 0;
    let dayCount = u.day_count || 0;
    if (now - hourStart >= HOUR) { hourStart = now; hourCount = 0; }
    if (now - dayStart >= DAY) { dayStart = now; dayCount = 0; }
    if (hourCount >= limits.hour || dayCount >= limits.day) {
      throw new HttpsError(
        'resource-exhausted',
        "You've reached the limit for this feature for now. Please try again a bit later.",
      );
    }
    t.set(ref, {
      [task]: {
        hour_start: Timestamp.fromMillis(hourStart),
        day_start: Timestamp.fromMillis(dayStart),
        hour_count: hourCount + 1,
        day_count: dayCount + 1,
      },
    }, { merge: true });
  });
}

function requireString(v, name, max) {
  if (typeof v !== 'string' || !v.trim()) {
    throw new HttpsError('invalid-argument', `${name} is required`);
  }
  if (v.length > max) {
    throw new HttpsError('invalid-argument', `${name} is too long`);
  }
  return v;
}

exports.aiGenerate = onCall(
  {
    secrets: [anthropicApiKey, openaiApiKey],
    timeoutSeconds: 300,
    memory: '512MiB',
    enforceAppCheck: ENFORCE_APP_CHECK,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Please sign in to use this feature.');
    }
    const uid = request.auth.uid;
    const data = request.data || {};
    const task = String(data.task || '');
    const cfg = TASKS[task];
    if (!cfg) throw new HttpsError('invalid-argument', 'Unknown AI task');

    const args = { task, userId: uid, systemPrompt: cfg.system || undefined };

    if (task === 'appIngredientMatch') {
      const a = requireString(data.ingredient1, 'ingredient1', cfg.maxPromptChars);
      const b = requireString(data.ingredient2, 'ingredient2', cfg.maxPromptChars);
      // Same user message the Dart code used to send.
      args.prompt = `Are these the same ingredient?\n1. ${a}\n2. ${b}\n\nAnswer only 'yes' or 'no':`;
      // Order-independent cache key: "milk|whole milk" == "whole milk|milk".
      args.cacheKey = [a, b].map((s) => s.toLowerCase().trim()).sort().join('|');
    } else if (task === 'appChat') {
      const msgs = Array.isArray(data.messages) ? data.messages : [];
      // The legacy chat seeds a 'developer' message with persona + the
      // user's children; pass it through as the system prompt (capped).
      // This task is open-ended chat by design, so a client-chosen system
      // prompt adds no new capability — limits/caps are the control.
      const sys = msgs
        .filter((m) => m && (m.role === 'developer' || m.role === 'system') &&
          typeof m.content === 'string')
        .map((m) => m.content)
        .join('\n\n')
        .slice(0, 4000);
      if (sys) args.systemPrompt = sys;
      const clean = msgs
        .filter((m) => m && (m.role === 'user' || m.role === 'assistant') &&
          typeof m.content === 'string' && m.content.trim())
        .slice(-cfg.maxMessages)
        .map((m) => ({ role: m.role, content: m.content }));
      // Anthropic (fallback) requires the conversation to start with user.
      while (clean.length && clean[0].role !== 'user') clean.shift();
      if (!clean.length) throw new HttpsError('invalid-argument', 'messages is required');
      const total = clean.reduce((n, m) => n + m.content.length, 0);
      if (total > cfg.maxPromptChars) {
        throw new HttpsError('invalid-argument', 'Conversation is too long');
      }
      args.messages = clean;
    } else {
      args.prompt = requireString(data.prompt, 'prompt', cfg.maxPromptChars);
    }

    await enforceRateLimit(uid, task, cfg.limits);

    try {
      const content = await generate(args);
      return { content };
    } catch (e) {
      console.error(`[aiGenerate] ${task} failed for ${uid}: ${e.message}`);
      throw new HttpsError('unavailable', 'The AI service is busy right now. Please try again in a moment.');
    }
  },
);

/*
 * MomRise website analytics (Google Analytics 4).
 *
 * INERT until GA_MEASUREMENT_ID is set. To turn it on:
 *   1. analytics.google.com → Admin → Create property "momrise.app" → Web
 *      stream for https://momrise.app → copy the Measurement ID (G-XXXXXXX).
 *   2. Paste it below and push. Every public page already loads this file.
 *   3. In GA4 → Admin → Custom definitions, register the event parameters
 *      ai_source, store and page_type as custom dimensions so they show up
 *      in reports.
 *
 * What it measures, beyond normal page views:
 *   - ai_referral   — a visit that came from an AI answer engine (ChatGPT,
 *                     Perplexity, Gemini, Copilot, Claude, …), with ai_source.
 *                     This is the AEO scoreboard.
 *   - app_store_click — a click on an App Store / Google Play link, with the
 *                     page it happened on. This is the conversion that
 *                     matters: which pages actually drive installs.
 * No personal data is collected; IP anonymization is on by default in GA4.
 */
(function () {
  'use strict';

  var GA_MEASUREMENT_ID = ''; // ← paste G-XXXXXXXXXX here to enable

  if (!GA_MEASUREMENT_ID) return;
  if (navigator.doNotTrack === '1' || window.doNotTrack === '1') return;

  var s = document.createElement('script');
  s.async = true;
  s.src = 'https://www.googletagmanager.com/gtag/js?id=' + encodeURIComponent(GA_MEASUREMENT_ID);
  document.head.appendChild(s);

  window.dataLayer = window.dataLayer || [];
  function gtag() { window.dataLayer.push(arguments); }
  window.gtag = gtag;

  var path = location.pathname;
  var pageType =
    path === '/' ? 'home' :
    /^\/answers\//.test(path) ? 'answer' :
    /^\/compare\//.test(path) ? 'comparison' :
    /^\/meal-ideas\//.test(path) ? 'meal_tool' :
    /^\/r\//.test(path) ? 'recipe' :
    /^\/for-creators\//.test(path) ? 'creator_guide' :
    'other';

  gtag('js', new Date());
  gtag('config', GA_MEASUREMENT_ID, { page_type: pageType });

  // ── AI answer-engine referrals ──────────────────────────────────────
  // Detected from the referrer host, or from the utm_source some engines
  // append (ChatGPT adds utm_source=chatgpt.com to cited links).
  var AI_SOURCES = [
    [/(^|\.)chatgpt\.com$|(^|\.)chat\.openai\.com$/, 'chatgpt'],
    [/(^|\.)perplexity\.ai$/, 'perplexity'],
    [/(^|\.)gemini\.google\.com$|(^|\.)bard\.google\.com$/, 'gemini'],
    [/(^|\.)copilot\.microsoft\.com$/, 'copilot'],
    [/(^|\.)claude\.ai$/, 'claude'],
    [/(^|\.)you\.com$/, 'you'],
    [/(^|\.)phind\.com$/, 'phind'],
    [/(^|\.)meta\.ai$/, 'meta_ai'],
    [/(^|\.)grok\.com$/, 'grok']
  ];
  function aiSource() {
    var hints = [];
    try { if (document.referrer) hints.push(new URL(document.referrer).hostname); } catch (e) {}
    try {
      var utm = new URLSearchParams(location.search).get('utm_source');
      if (utm) hints.push(utm.toLowerCase());
    } catch (e) {}
    for (var h = 0; h < hints.length; h++) {
      for (var i = 0; i < AI_SOURCES.length; i++) {
        if (AI_SOURCES[i][0].test(hints[h])) return AI_SOURCES[i][1];
      }
    }
    return null;
  }
  var ai = aiSource();
  if (ai) gtag('event', 'ai_referral', { ai_source: ai, page_type: pageType });

  // ── App-store clicks (the conversion) ───────────────────────────────
  document.addEventListener('click', function (e) {
    var a = e.target && e.target.closest ? e.target.closest('a[href]') : null;
    if (!a) return;
    var href = a.getAttribute('href') || '';
    var store =
      /apps\.apple\.com/.test(href) ? 'app_store' :
      /play\.google\.com/.test(href) ? 'google_play' : null;
    if (!store) return;
    gtag('event', 'app_store_click', {
      store: store,
      page_type: pageType,
      ai_source: ai || '(none)',
      transport_type: 'beacon'
    });
  }, true);
})();

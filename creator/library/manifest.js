// Creator Library content manifest.
//
// Edit this file when Haley uploads new assets to Firebase Storage at
// /creator_library/. The library page (index.html) reads from these
// exports on page load — no build step needed.
//
// When adding a video:
//   1. Upload the .mp4 to Firebase Storage at /creator_library/{filename}.mp4
//      (use the Firebase Console UI or the upload helper script).
//   2. Get the public download URL (Firebase Console → Files → click the
//      file → copy the URL under "Access token" / "File location" — the
//      one that starts with https://firebasestorage.googleapis.com).
//   3. Add a row to the matching array below with url, title, duration.
//   4. Commit + push. GitHub Pages picks it up in ~1 minute.
//
// All public-readable: the /creator_library/ Storage rule allows
// read: if true, write: if false (admin SDK only).

export const CAPTION_SNIPPETS = [
  `#ad Affiliate of @momrise — code [CODE] supports my channel (free for you).

The 5pm scramble is over. I import recipes from TikTok in 10 seconds now and our whole week's planned. If you try MomRise, [CODE] is my code.`,

  `#ad Affiliate of @momrise — using code [CODE] supports my channel at no extra cost to you.

Lazy mom meal plan, going up. The MomRise app pulls recipes straight from TikTok and Pinterest and turns them into grocery orders. I haven't planned a week from scratch in three months.`,

  `#ad Affiliate of @momrise — code [CODE] is mine.

POV: every time you find a recipe on TikTok you can just save it to your meal plan. Then it's on the grocery list. Then it's at your door. If you subscribe, plug [CODE] in — supports me at no cost to you.`,

  `#ad Affiliate of @momrise — [CODE] is my code if you try it.

Things I stopped doing once I started using @momrise: writing grocery lists, screenshotting recipes I never make, staring at the fridge at 5pm.`,

  `#ad Affiliate of @momrise — [CODE] supports my channel (free for you).

This is the only app I open in the morning. I look at the week, see what I planned, and the recipe + ingredients are right there. Stops the weekday lunch decision-fatigue at least.`,
];

export const LIBRARY_MANIFEST = {
  // Short, no-audio app demos. Creators splice these between voiceover.
  // Target 5-15 seconds each, vertical 9:16.
  appDemos: [
    // Example shape for when Haley uploads:
    // {
    //   url: 'https://firebasestorage.googleapis.com/v0/b/parenting-plus-7szrif.appspot.com/o/creator_library%2Fshare-tiktok-to-momrise.mp4?alt=media&token=...',
    //   title: 'Share from TikTok to MomRise',
    //   duration: 7,
    //   note: 'no audio',
    // },
  ],

  // Hands-only cooking B-roll. Universal recipe filler.
  bRoll: [
    // Same shape as appDemos.
  ],

  // Brand elements — Canva template URLs, logo downloads, etc.
  brandElements: [
    // {
    //   title: 'MomRise lower-third sticker (PNG, transparent BG)',
    //   description: '"code [CODE] · momrise.app" — drop into your Reels.',
    //   url: 'https://firebasestorage.googleapis.com/.../lower-third.png',
    //   cta: 'Download',
    // },
    // {
    //   title: 'Cook With Me Reel template',
    //   description: 'Editable Canva template — duplicate, swap in your recipe.',
    //   url: 'https://www.canva.com/design/...',
    //   cta: 'Open template',
    // },
  ],

  // Live Reels other creators have posted using this library. Format reference.
  examples: [
    // {
    //   title: '@haley.hostetter — Cook With Me: pesto pasta',
    //   description: '30s Reel. Voiceover + share-from-tiktok app demo + B-roll.',
    //   url: 'https://www.instagram.com/reel/...',
    //   cta: 'Watch',
    // },
  ],
};

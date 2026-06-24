# Social Recipe Import — Architecture Decisions

Last updated: 2026-06-03

Locked direction for how MomRise imports recipes from TikTok and Instagram.
Revisit before building out the share-extension video flow.

---

## TikTok — Path B1 with WebView fetch

**UX**: User taps Share inside TikTok → picks MomRise → MomRise opens with a "Pulling recipe…" card showing the video thumbnail → ~2-3s later the recipe is parsed and saved. One tap, ReciMe-parity feel.

**Implementation**:
- iOS Share Extension + Android share intent already accepts URLs (current state).
- New: in-app `webview_flutter` loads the TikTok URL on the user's device.
- JS injection grabs the `<video>` src (or intercept the `.mp4` network request).
- App downloads the `.mp4` to local storage; sends to backend.
- New backend `transcribeRecipeVideo` cloud function:
  - Optional ffmpeg audio strip (skip initially — send full mp4).
  - OpenAI `audio.transcriptions.create` (Whisper) for the audio.
  - Feed transcript + caption + thumbnail OCR into the existing `extractRecipe` LLM
    pipeline with the `RECIPE_SPECIFICITY_RULES` we shipped in 2.3.0+533.

**Legal posture**: WebView shifts the locus of the page fetch from our server to
the user's device. From TikTok's logs the request looks like a normal mobile
browser, user's IP, user's cookies, user-initiated navigation. Not ToS-clean,
but indistinguishable from legitimate use at small-app scale. The
BrandTotal-style risk (Meta v. Octopus Data, Voyager Labs, Bright Data) is
substantially lower than a server-side scrape pattern. See
[ReciMe deep-research notes from 2026-06-03] for the legal landscape.

**Coverage estimate**: ~80–90% of TikTok cooking content (combines caption +
audio + thumbnail OCR).

**ToS provisions to add before shipping** (separate task):
- Personal-note-taking framing, mirroring ReciMe's Evernote/Pocket language.
- User reps & warranties + indemnification.
- Register DMCA designated agent ($6 with U.S. Copyright Office).
- Platform-affiliation disclaimer.
- Takedown-on-notice policy.

---

## Instagram — Path B2 (save → share from Photos) + stacked recovery

**UX**:
1. User saves the IG Reel to Camera Roll first.
2. Shares from Photos → MomRise. App receives the actual `.mp4` file
   (`public.movie` UTI on iOS, video MIME on Android).
3. Optional "Also paste the caption" field for caption-based recipes.
4. For photo carousels: route user to existing Cookbook → Photo Import flow.

**Why not B1 + WebView for IG**: Instagram's public Reels hit login walls and
interstitials inside a WebView ~50% of the time. Meta also enforces ToS
significantly more aggressively than TikTok (BrandTotal, Octopus Data,
Voyager Labs, Bright Data — all Meta-initiated). Not worth the reliability
hit or the litigation risk.

**Legal posture**: Cleanest possible. The user owns the file on their device.
Sharing it to MomRise is identical to sharing any other personal video.

**Coverage estimate** (rough breakdown by content type):

| IG content type     | Share of cooking posts | B2 catches it?                    |
|---------------------|------------------------|------------------------------------|
| Narrated Reel       | ~40%                   | Yes — audio transcription          |
| Text-overlay Reel   | ~15%                   | Only with frame OCR add-on         |
| Caption recipe      | ~30%                   | Only with optional caption paste   |
| Photo carousel      | ~15%                   | Route to screenshot import         |

**Accuracy ladder** (build in this order):
- Audio-only: ~25–30%
- + frame OCR (GPT-4o Vision on 4–6 keyframes, ~$0.01–0.02/video): ~50–55%
- + optional caption paste field: ~75–80%
- + carousel screenshot fallback: ~90% (full TikTok parity)

**Help copy on the import screen**:
> "Share from TikTok directly. For Instagram, save the video to your Photos
> first, then share from there."

---

## Pre-build checklist

Before scaffolding either flow:

- [ ] 15-min manual test: install a test app with a broad Share Extension and
      tap Share from TikTok / IG to confirm what UTIs come through (validates
      Path B2 feasibility — needs `public.movie`, not just `public.url`).
- [ ] Throwaway WebView test: load a TikTok video URL in `webview_flutter`,
      extract the `.mp4` src via JS injection. Validates the technique works
      against current TikTok.
- [ ] Draft + add the ToS clauses listed above.
- [ ] Register DMCA designated agent.

---

## Open questions to revisit

- Does the iOS share extension from inside TikTok ever expose `public.movie`
  directly, or always URL only? Determines whether we need the WebView at all
  on TT.
- TikTok could ship anti-WebView signals (touch event requirements, viewport
  checks) — no documented small-app cease-and-desists yet, but a live risk
  to monitor.
- On-device Whisper.cpp vs backend Whisper API trade-off — defer until cost
  is felt.

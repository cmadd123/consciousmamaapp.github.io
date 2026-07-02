# Mome Coach - Project Notes

## Project Overview
Mome Coach (App Name: **MomRise**) is a Flutter-based parenting app that helps parents track their children's development, create learning paths, manage meals, activities, and milestones.

**Current Version**: v1.2.314
**Firebase Project**: parenting-plus-7szrif

## Key Project Structure
```
mome_coach/
├── lib/
│   ├── v1/                    # Legacy UI components
│   │   ├── nav_bar/           # Old 5-icon navbar (NavBarWidget)
│   │   └── pages/childern/    # My Kids page (children_widget.dart)
│   ├── v2/                    # New UI components
│   │   ├── learning_path/     # Learning path creation & details
│   │   │   ├── learn_path_detials/    # View learning path tasks
│   │   │   ├── loading_learn_pass/     # Loading animation widget
│   │   │   └── learn_path_stepon_step4/ # Step 4 - triggers AI generation
│   │   └── home_hybrid/       # New home page
│   ├── components/
│   │   ├── puzzle_progress_widget.dart  # Emoji puzzle progress display
│   │   ├── home_nav_bar_widget.dart     # New 4-icon navbar
│   │   └── nav_bar_component_widget.dart # Standard/Comfort mode navbar
│   ├── custom_code/actions/
│   │   └── build_learning_path.dart     # AI-powered learning path generator
│   └── backend/schema/
│       ├── learning_path_record.dart    # Learning path Firestore schema
│       └── learning_path_tasks_record.dart # Tasks schema
└── firebase/                  # Cloud functions
```

## Important Features

### Learning Path System
- AI-generated learning paths using OpenAI API
- Tasks stored in Firestore with puzzle theme association
- Puzzle themes: dinosaurs, animals, space, ocean, vehicles
- Progress tracked via `is_completed` field on tasks

### Navigation Bars
1. **NavBarWidget** (v1/nav_bar/): 5 icons - Home, Meals, Calendar, Milestones, Children
2. **HomeNavBarWidget** (components/): 4 icons - Home, Meals, Calendar, Activities (PREFERRED)
3. **NavBarComponentWidget**: Standard & Comfort modes with 5 icons

### Puzzle Progress Widget
Located: `lib/components/puzzle_progress_widget.dart`
- 3x3 grid of themed emojis
- Greyed out emojis for incomplete tasks
- Animated reveal when tasks complete
- Themes defined in `PuzzleTheme` class

## Known Issues & Fixes Applied

### Loading Screen Stalling (Fixed)
**Problem**: Progress bar jumps to 80% quickly then stalls before suddenly completing.
**Cause**: Timer-based progress (every 1 second) doesn't match actual API call duration.
**Solution**: Use smoother incremental progress that continues until API completes.

### My Kids Page Navbar (Fixed)
**Status**: Updated to use HomeNavBarWidget with 4 icons (Home, Meals, Calendar, Activities)

## API Keys
- OpenAI key stored in `FFAppState().openAiKey`
- Should be moved to Firebase Remote Config for production

## Common Patterns

### FlutterFlow Conventions
- Models use `safeSetState()` for state updates
- `wrapWithModel()` for component composition
- `context.pushNamed()` / `context.goNamed()` for navigation
- Custom icons via `FFIcons` class

### Firestore Collections
- `children` - Child profiles
- `learning_path` - Learning path metadata
- `learning_path_tasks` - Individual tasks within paths
- `event_and_task` - Calendar events

## Session Context
Use this section to track ongoing work:

### Current Session (Last Updated: 2026-01-16)
- Fixed loading screen progress animation
- Updated My Kids page to use new 4-icon navbar
- Added puzzle theme picker to learning path creation (step 4)
- Puzzle theme is now saved to Firestore and displayed in learning path details
- Themes: dinosaurs, animals, space, ocean, vehicles (3x3 emoji grid)
- Moved OpenAI API key to Firebase Remote Config (security fix)
- Fixed Firebase project config (iOS and web now use parenting-plus-7szrif)
- Fixed Firestore rules for childern collection (userRef not user_ref)
- Fixed activity_record.dart to handle capitalized field names (Description, Title, etc.)
- Added child color circles with initials throughout app
- Added Mom (pink "M") and Dad (blue "D") circle indicators
- Multi-child selection for events/tasks
- Updated calendar cards to show assigned family members

## Planned Changes / Discussion Items

### Terminology Changes (To Be Implemented)
1. **"Puzzle" -> TBD** - Need to rename the puzzle progress feature to something else
2. **"Task" -> "Lesson"** - In learning paths, rename "task" to "lesson" for clarity

### Learning Path - Expectations vs Reality Feature
- Add a section in learning path lessons for "Expectations vs Reality"
- Help parents understand what to realistically expect during activities
- Include common challenges and how to handle them

### Known Issues
1. **Learning Path Creation Not Loading** - The learning path creation flow is not loading properly
2. **Different Learning Path Flows** - The flow from milestones page differs from the learning path page flow - need to unify these

---

## App Store Preparation

### Privacy Policy

**CONSCIOUS MAMA PRIVACY POLICY**

Last Updated: January 15, 2026

**1. Introduction**
Conscious Mama ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.

**2. Information We Collect**

*Account Information:*
- Email address (for authentication)
- Name (optional, for personalization)

*Child Information:*
- Child's name or nickname
- Child's birthdate (used to calculate age for age-appropriate content)
- Developmental milestones achieved
- Learning path progress

*Usage Data:*
- App interactions and feature usage
- Device information (device type, operating system)

**3. How We Use Your Information**
- To provide personalized parenting guidance based on your child's age
- To generate AI-powered learning paths and activity suggestions
- To track developmental milestones and progress
- To improve our app and user experience
- To send optional notifications about your child's activities

**4. Third-Party Services**
We use the following third-party services:
- **Firebase (Google)**: Authentication, database, and cloud storage
- **OpenAI**: AI-powered content generation for learning paths and activities

These services have their own privacy policies governing how they handle data.

**5. Data Storage and Security**
- All data is stored securely using Google Firebase
- We use industry-standard encryption for data transmission
- User data is associated with authenticated accounts only
- We do not sell or share your personal information with third parties for marketing purposes

**6. Children's Privacy**
Conscious Mama is designed for parents to track their children's development. We do not collect personal information directly from children. All child-related data is entered and managed by the parent/guardian.

**7. Your Rights**
You have the right to:
- Access your personal data
- Request deletion of your account and associated data
- Opt out of optional notifications
- Export your data

**8. Data Retention**
We retain your data for as long as your account is active. You may request deletion of your account and all associated data at any time by contacting us.

**9. Changes to This Policy**
We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy in the app.

**10. Contact Us**
If you have questions about this Privacy Policy, please contact us at:
Email: [YOUR_EMAIL]
Website: [YOUR_WEBSITE]

---

### App Store Description

**App Name:** Conscious Mama

**Subtitle (30 chars max):** Mindful Parenting Companion

**Full Description (4000 chars max):**

Conscious Mama is your mindful parenting companion, designed to support you through every stage of your child's development. Whether you're tracking milestones, planning activities, or looking for guidance during challenging moments, Conscious Mama is here to help you parent with intention.

**KEY FEATURES**

**AI-Powered Learning Paths**
Create personalized learning paths tailored to your child's age and specific challenges. Our AI generates engaging activities with step-by-step guidance, parent tips, and suggestions for when your child resists.

**Developmental Milestone Tracking**
Track your child's growth with our comprehensive milestone checklist. Celebrate achievements and understand what developmental stages to expect next.

**Activity Suggestions**
Not sure what to do with your little one? Tell us the mood you're in, and we'll suggest age-appropriate activities. Filter by energy level, setup time, indoor/outdoor, and more.

**Meal Planning**
Plan nutritious meals for your family with our meal planning feature. Save favorites and organize your weekly menu.

**Calendar Integration**
Keep track of activities, appointments, and family events all in one place.

**Beautiful Themes**
Choose between our vibrant Standard mode or the calming Comfort mode for a personalized experience.

**WHY PARENTS LOVE CONSCIOUS MAMA**

- Personalized guidance based on your child's actual age
- AI-generated activities that are practical and engaging
- Track multiple children in one app
- Simple, intuitive design that busy parents appreciate
- Works offline for milestone tracking
- Supports mindful, intentional parenting

**PERFECT FOR**
- New parents navigating the early years
- Parents seeking a more conscious approach to child-rearing
- Families wanting to be more intentional about activities
- Anyone seeking support during challenging parenting moments

Download Conscious Mama today and parent with presence and purpose!

---

**Keywords (100 chars max):**
parenting,conscious,mindful,baby,toddler,milestones,development,activities,mama,mother,intentional

**Primary Category:** Lifestyle
**Secondary Category:** Health & Fitness

**Age Rating:** 4+ (No objectionable content)

**Support URL:** [YOUR_WEBSITE]/support
**Privacy Policy URL:** [YOUR_WEBSITE]/privacy

---

### App Store Screenshots Needed
1. Home screen showing child info
2. Learning path creation flow
3. Activity suggestions (mood bubbles)
4. Milestone tracking
5. Meal planning
6. Calendar view

### Required Screen Sizes
- 6.7" (iPhone 15 Pro Max) - 1290 x 2796
- 6.5" (iPhone 11 Pro Max) - 1242 x 2688
- 5.5" (iPhone 8 Plus) - 1242 x 2208
- iPad Pro 12.9" - 2048 x 2732

---

## 🚀 PRE-LAUNCH TODOS

### **CRITICAL PATH (Blockers for Launch)**

#### 1. **Google Play Testing** ⏰ STARTED
- [x] Create Play Console account ($25)
- [x] Build signed AAB release
- [ ] Fill out Play Store listing (in progress)
- [ ] Upload AAB to internal testing track
- [ ] Recruit 12 testers (family, friends, beta testing groups)
- [ ] **14-day testing period** (longest blocker)
- [ ] Address any critical bugs from testing
- [ ] Submit for production review

#### 2. **Apple App Store** ⏰ WAITING
- [ ] Wait for Apple Developer account approval (48 hours max from 2026-01-17)
- [ ] Create app listing in App Store Connect
- [ ] Upload build to TestFlight
- [ ] Internal testing (optional, no time requirement)
- [ ] Submit for App Review
- [ ] Production release

#### 3. **Instacart Affiliate Integration** (Revenue Stream)
- [x] Integration built and deployed
- [ ] Apply to Instacart Affiliate Program via Impact.com (1-2 days approval)
- [ ] Get affiliate tracking URL from Impact.com
- [ ] Add tracking URL to Firebase Remote Config (`instacart_affiliate_url`)
- [ ] Test commission tracking
- [ ] Start earning! 💰

---

### **HIGH PRIORITY (Improves UX)**

#### 4. **Welcome Page Improvements** - "Under-promise, Over-deliver"
**Current Issue**: Welcome page may set expectations too high
**Goal**: Lower initial expectations, let the app surprise and delight

**Proposed Changes**:
- [ ] Simplify feature descriptions (less "AI-powered", more "helpful tools")
- [ ] Reduce scope of promises (don't promise "all your parenting needs")
- [ ] Add realistic disclaimers ("Great for busy parents" not "Perfect solution")
- [ ] Focus on 2-3 core features, not everything
- [ ] Consider softer language: "Helps you" not "Solves"

**Discussion Questions**:
- What specific features should we highlight?
- Should we mention limitations upfront?
- How can we make it feel warm/supportive vs overpromising?

#### 5. **Meal Planner Reminders** 🔔
**Feature**: Push notifications for upcoming meals

**Implementation Needed**:
- [ ] Add "Remind me" toggle to meal planning
- [ ] Default reminder time (e.g., "30 min before dinner")
- [ ] Store notification preferences in Firestore
- [ ] Schedule local notifications via notification_service.dart
- [ ] Handle timezone edge cases
- [ ] Add settings page to manage reminder times
- [ ] Test notifications on Android/iOS

**Questions**:
- Default reminder time? (30 min? 1 hour?)
- Reminder for every meal or just dinner?
- Allow custom times per meal?

#### 6. **Activities Content Upload** 📚
- [ ] Audit existing activities (check for duplicates, quality issues)
- [ ] Upload 190 new activities to Firestore
- [ ] Categorize by: age, difficulty, indoor/outdoor, energy level
- [ ] Add emoji icons for each activity
- [ ] Add tags for filtering
- [ ] Verify all activities display correctly in app

---

### **MEDIUM PRIORITY (Polish & Monetization)**

#### 7. **UI Fixes**
- [x] Gender dropdown color (already correct in code - may be visual bug)
- [ ] Verify all forms have consistent styling
- [ ] Test on different screen sizes
- [ ] Dark mode support (optional)

#### 8. **Payment/Paywall Strategy** 💳
**Decision Needed**: Launch free or freemium?

**Option A - Launch Free** (Recommended):
- Build user base quickly
- Get feedback before monetizing
- Add premium tier later based on usage data
- Lower barrier to entry

**Option B - Freemium from Day 1**:
- Basic features free
- Premium features: unlimited learning paths, advanced meal planning, etc.
- 7-day free trial
- $4.99/month or $49/year

**Implementation** (if freemium):
- [ ] Integrate RevenueCat or Stripe
- [ ] Design paywall UI
- [ ] Determine free vs premium features
- [ ] Set up subscription products in App/Play Store
- [ ] Test payment flow end-to-end

#### 9. **App Store Assets**
- [ ] Take 6-8 screenshots per platform
- [ ] Create feature graphic (1024x500 for Play Store)
- [ ] Record app preview video (optional but recommended)
- [ ] Design promotional graphics
- [ ] Write app store description (already drafted)

#### 10. **Terminology Changes** (User Feedback Pending)
- [ ] Rename "Puzzle" to something else (TBD)
- [ ] Rename "Task" to "Lesson" in learning paths
- [ ] Update all UI references
- [ ] Update Firebase field names if needed

---

### **ONBOARDING STRATEGY** 🎉

#### Premium Onboarding Design (2026-02-05)

**Context**: App has paywall with 7-day free trial at END of onboarding. Must deliver massive value BEFORE asking for payment.

**Current Model**: Freemium + Free Trial Hybrid
- 7-day free trial to premium features
- Paywall appears after onboarding (add child → trial starts)
- Goal: Show value so compelling they can't imagine NOT subscribing

**Competitor Research Insights**:
- Headspace: Meditation intro before signup
- Calm: Interactive breathing exercise first
- Duolingo: Immediate language lesson before account
- Principle: **Let them experience magic BEFORE friction**

#### Voice & Tone Upgrades (APPROVED)

Replace functional copy with emotional, specific copy:

**Before → After Examples**:
- "Track milestones and activities" → "Remember every first - from their first word to their first bike ride"
- "Easy weekly meal plans for your family" → "Stop staring at the fridge at 5pm wondering what's for dinner"
- "Stay organized with events and tasks" → "Finally, a calendar that works for your whole crew"

**Tone Guidelines**:
- Empathetic: "We get it, 5pm is rough"
- Conversational: "Let's fix that" not "Configure settings"
- Encouraging: "You're doing great!" at milestones
- No jargon: "Add your first kiddo" not "Create child profile"

#### Celebration Moments (APPROVED)

**When to celebrate**:
1. First child added → Full-screen confetti animation + "Welcome to MomRise, [Name]! 👋"
2. First meal planned → "Your first dinner is planned! That was easy, right?"
3. First learning path created → "🎉 [Name]'s first learning adventure begins!"
4. First calendar event → "You're getting organized! 📅"

**Implementation**:
- Use confetti package for full-screen animations
- Haptic feedback on celebration moments
- Brief (1-2 seconds), not intrusive
- Shows age-appropriate tip after celebration

#### Lottie Animations (APPROVED)

**Where to use**:
1. Welcome page feature highlights:
   - Meal planning: Fork and plate animating together
   - Child development: Baby crawling animation
   - Calendar: Pages flipping
2. Loading states: Custom illustrations instead of spinners
3. Tutorial overlays: Floating bubbles with bounce
4. Progress indicators: Animated circles that fill

**Resources**:
- LottieFiles.com for free animations
- Keep file sizes under 100KB each
- Subtle loops, not distracting

#### Recommended Onboarding Flow (Pre-Paywall Value Build)

**Goal**: User completes 1-2 "quick wins" BEFORE seeing paywall

**Flow**:
1. **Splash Screen** → (Current - looks good)

2. **Welcome Screen** → Updated copy
   - Hero: "Let's be honest - mom life is beautiful chaos."
   - Sub: "We're here to help with the chaos part, so you can enjoy the beautiful."
   - Emotional feature highlights (with Lottie animations):
     - 🍽️ "Stop staring at the fridge at 5pm wondering what's for dinner"
     - 👶 "Remember every first - from their first word to their first bike ride"
     - 📅 "Finally, a calendar that works for your whole crew"
   - Button: "Let's get started"

3. **Sign Up** → Quick and clear
   - "Create your account - we'll personalize everything for you"
   - Email/password or Google Sign-In
   - Progress indicator: "Step 1 of 3"

4. **Add First Child** → With celebration
   - "Who are we helping you with?"
   - After submit → **Confetti animation**
   - "Welcome to MomRise, [Name]! 👋"
   - Age-appropriate tip: "At 2 years old, they're learning so fast! We'll suggest activities perfect for them."

5. **First Quick Win** → Critical!
   - Don't dump them on empty home page
   - Guided action: "Let's add your first dinner plan together"
   - Tutorial overlay walks through meal composer
   - They pick a recipe → "That looks delicious! 🎉 Your Tuesday dinner is planned."

6. **Paywall (7-Day Free Trial)**
   - **Timing**: After first meal is planned (they've experienced value)
   - Copy: "You just planned dinner in 30 seconds. Imagine doing that for the whole week."
   - **Free trial**: "Try all features free for 7 days"
   - **Benefits list**:
     - ✓ Unlimited meal plans
     - ✓ AI learning paths for [Child's Name]
     - ✓ Full calendar & activity tracker
     - ✓ Milestone tracking & reminders
   - **Pricing**: "$4.99/month after trial - cancel anytime"
   - **CTA**: "Start My Free Trial"
   - **Skip option**: "Maybe later" (goes to home page, can upgrade from settings)

7. **Home Page** → Now with 1 meal already planned
   - Not empty - shows their first action
   - Gentle prompts for next actions

#### Animation & Polish Details

**Page Transitions**:
- Smooth horizontal slides (300ms)
- Fade + slide combo for depth

**Micro-Interactions**:
- Buttons scale slightly when pressed (0.95x)
- Haptic feedback on important actions
- Loading states with custom illustrations

**Gradient Flow**:
- Welcome: Teal → Pink (current brand)
- Add child: Pink → Lavender
- Guided action: Lavender → Mint
- Creates visual journey

#### Key Metrics to Track

**Onboarding Funnel**:
1. Welcome screen views
2. Sign-up starts
3. Sign-up completions
4. First child added
5. First "quick win" completed
6. Paywall views
7. Trial starts
8. Trial → Paid conversions

**Success Targets**:
- 80%+ complete first child
- 70%+ complete first meal plan
- 50%+ start free trial
- 30%+ convert trial to paid

---

### **LOW PRIORITY (Post-Launch)**

#### 11. **Learning Path Enhancements**
- [ ] Add "Expectations vs Reality" section to lessons
- [ ] Help parents understand realistic outcomes
- [ ] Include common challenges and solutions

#### 12. **Analytics & Monitoring**
- [ ] Add Firebase Analytics events
- [ ] Track key user actions (onboarding completion, learning path creation, etc.)
- [ ] Set up crash reporting (Crashlytics)
- [ ] Monitor performance metrics

#### 13. **Bundle ID Updates** (Before Production)
- [ ] Change from `com.mycompany.momecoach` to proper domain
- [ ] Update Android applicationId
- [ ] Update iOS bundle identifier
- [ ] Regenerate signing if needed

---

## 📱 Play Console Store Listing Fields

**Where to fill these in**: Play Console → Your App → Store Presence → Main Store Listing

### Required Fields:

1. **App name**: MomRise
2. **Short description** (80 chars): Your AI-powered parenting companion for meals, activities, and milestones
3. **Full description**: (See App Store Description section above - copy/paste)
4. **App icon**: 512x512 PNG (`assets/images/image_22.png`)
5. **Feature graphic**: 1024x500 PNG (needs creation)
6. **Screenshots**: 2-8 phone screenshots (needs capture from device)
7. **App category**: Lifestyle
8. **Content rating**: Fill out questionnaire (will be PEGI 3 / Everyone)
9. **Contact email**: (Your email)
10. **Privacy policy URL**: https://cmadd123.github.io/privacy.html
11. **Target age**: 18+ (app is for parents, not children)

---

## 🔄 Deployment Process

**For Testing Changes** (Quick iteration):
```bash
flutter install --device-id=192.168.1.224:44443
```

**For Production Release** (App stores):
```bash
# Android
flutter build appbundle --release

# iOS (when Apple account ready)
flutter build ipa --release
```

**Current keystore**: `android/upload-keystore.jks` (gitignored — never commit)
- Alias: upload
- Regenerated 2026-07-01. The previous keystore is retired (its password had been committed to this public file). Credentials live in `android/key.properties` (gitignored) and the password manager — never in this file.

---

## 📝 Notes for Future Work

### Page Transitions & Animations (2026-02-04)
**Status**: Needs revisiting - timing and implementation require more refinement
**Context**: Attempted to implement warm page transitions for recurring event creation with white fade pattern. Issue: difficult to get smooth transitions without overlap/timing issues with Flutter's PageRouteBuilder.
**TODO for later**:
- Revisit warm page transitions for heavy operations (AI calls, bulk operations)
- Consider simpler approach or different animation framework
- May need to use Hero animations or custom animation controllers
- Test different timing approaches for white fade pattern

---

## ✅ Recently Completed (2026-01-22)

- [x] App name changed to "MomRise" throughout
- [x] Onboarding flow reordered (questions before child setup)
- [x] Instacart affiliate integration built
- [x] Version updated to v1.2.314
- [x] Production release build created
- [x] Gender dropdown styling reviewed (already correct)

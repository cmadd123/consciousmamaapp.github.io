# Mome Coach - Project Notes

## Project Overview
Mome Coach is a Flutter-based parenting app that helps parents track their children's development, create learning paths, manage meals, activities, and milestones.

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

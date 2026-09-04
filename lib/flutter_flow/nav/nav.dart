import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';

import '/auth/base_auth_user_provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';
import '/custom_code/actions/analytics_service.dart';

import '/index.dart';
import '/components/animated_splash_screen.dart';
import '/v2/skills_preview/skills_home_preview_widget.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Whether the current user has completed onboarding
  bool _onboardingCompleted = false;
  bool get onboardingCompleted => _onboardingCompleted;
  /// Whether we've actually loaded onboarding status for the logged-in user.
  /// Until this is true we keep the app in "loading" (splash) rather than
  /// routing, so a logged-in user is never shown "Let's get started" while
  /// their onboarding flag is still defaulting to false. See `loading`.
  bool onboardingLoaded = false;
  set onboardingCompleted(bool value) {
    _onboardingCompleted = value;
    onboardingLoaded = true;
    notifyListeners();
  }

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  // A logged-in user isn't "done loading" until we know their onboarding
  // status — otherwise the redirect runs with onboardingCompleted still false
  // and lands them on the welcome page. Logged-out users aren't gated.
  bool get loading =>
      user == null || showSplashImage || (loggedIn && !onboardingLoaded);
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // New/changed user → wait for their onboarding status before routing
    // (main.dart loads it right after and sets onboardingCompleted).
    if (shouldUpdate) onboardingLoaded = false;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      // Tags every page automatically (screen_view events) for app-health tracking.
      observers: [analyticsService.observer],
      redirect: (context, state) {
        // Don't redirect while still loading (splash screen)
        if (appStateNotifier.loading) return null;

        final loggedIn = appStateNotifier.loggedIn;
        final onboardingCompleted = appStateNotifier.onboardingCompleted;
        final currentPath = state.uri.path;

        // If user is logged in, has completed onboarding, and on welcome/init page, send to home
        if (loggedIn && onboardingCompleted && (currentPath == '/' || currentPath == '/welcome-enhanced')) {
          return '/home-hybrid';
        }

        return null;
      },
      errorBuilder: (context, state) =>
          const WelcomeEnhancedWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) =>
              const WelcomeEnhancedWidget(),
        ),
        FFRoute(
          name: HomePageWidget.routeName,
          path: HomePageWidget.routePath,
          builder: (context, params) => const HomePageWidget(),
        ),
        FFRoute(
          name: HomeHybridWidget.routeName,
          path: HomeHybridWidget.routePath,
          builder: (context, params) => const HomeHybridWidget(),
        ),
        FFRoute(
          name: AuthHomeWidget.routeName,
          path: AuthHomeWidget.routePath,
          builder: (context, params) => const AuthHomeWidget(),
        ),
        FFRoute(
          name: LoginWidget.routeName,
          path: LoginWidget.routePath,
          builder: (context, params) => const LoginWidget(),
        ),
        FFRoute(
          name: SignUpWidget.routeName,
          path: SignUpWidget.routePath,
          builder: (context, params) => const SignUpWidget(),
        ),
        // REMOVED: OnboardingSelector testing page (production launch)
        FFRoute(
          name: WelcomeEnhancedWidget.routeName,
          path: WelcomeEnhancedWidget.routePath,
          builder: (context, params) => const WelcomeEnhancedWidget(),
        ),
        FFRoute(
          name: AddChildEnhancedWidget.routeName,
          path: AddChildEnhancedWidget.routePath,
          builder: (context, params) => AddChildEnhancedWidget(
            isOnboarding: params.getParam('isOnboarding', ParamType.bool) ?? true,
          ),
        ),
        FFRoute(
          name: ParentSetupEnhancedWidget.routeName,
          path: ParentSetupEnhancedWidget.routePath,
          builder: (context, params) => const ParentSetupEnhancedWidget(),
        ),
        FFRoute(
          name: FeaturesEnhancedWidget.routeName,
          path: FeaturesEnhancedWidget.routePath,
          builder: (context, params) => const FeaturesEnhancedWidget(),
        ),
        FFRoute(
          name: MealIntroTransitionWidget.routeName,
          path: MealIntroTransitionWidget.routePath,
          builder: (context, params) => const MealIntroTransitionWidget(),
        ),
        FFRoute(
          name: FeatureWalkthroughWidget.routeName,
          path: FeatureWalkthroughWidget.routePath,
          builder: (context, params) => const FeatureWalkthroughWidget(),
        ),
        FFRoute(
          name: MealPlannerSpotlightWidget.routeName,
          path: MealPlannerSpotlightWidget.routePath,
          builder: (context, params) => const MealPlannerSpotlightWidget(),
        ),
        FFRoute(
          name: DaySelectorDemoWidget.routeName,
          path: DaySelectorDemoWidget.routePath,
          builder: (context, params) => const DaySelectorDemoWidget(),
        ),
        FFRoute(
          name: WelcomeCelebrationWidget.routeName,
          path: WelcomeCelebrationWidget.routePath,
          builder: (context, params) => const WelcomeCelebrationWidget(),
        ),
        FFRoute(
          name: SetupTransitionWidget.routeName,
          path: SetupTransitionWidget.routePath,
          builder: (context, params) => const SetupTransitionWidget(),
        ),
        FFRoute(
          name: AccountTransitionWidget.routeName,
          path: AccountTransitionWidget.routePath,
          builder: (context, params) => const AccountTransitionWidget(),
        ),
        FFRoute(
          name: FeatureIntroWidget.routeName,
          path: FeatureIntroWidget.routePath,
          builder: (context, params) => const FeatureIntroWidget(),
        ),
        FFRoute(
          name: MealPlanDemoWidget.routeName,
          path: MealPlanDemoWidget.routePath,
          builder: (context, params) => MealPlanDemoWidget(
            selectedDays: params.getParam(
              'selectedDays',
              ParamType.int,
              isList: true,
            ) as List<int>?,
          ),
        ),
        FFRoute(
          name: MealComposerDemoWidget.routeName,
          path: MealComposerDemoWidget.routePath,
          builder: (context, params) => MealComposerDemoWidget(
            mealName: params.getParam('mealName', ParamType.String)!,
            dayIndex: params.getParam('dayIndex', ParamType.int)!,
          ),
        ),
        FFRoute(
          // Meals route now points to v2 CreateMealPlan (weekly meal planning)
          name: 'Meals',
          path: '/meals',
          builder: (context, params) => const CreateMealPlanWidget(),
        ),
        FFRoute(
          name: ActivitiesWidget.routeName,
          path: ActivitiesWidget.routePath,
          builder: (context, params) => ActivitiesWidget(
            childActivity: params.getParam<ChildActivityStruct>(
              'childActivity',
              ParamType.DataStruct,
              isList: true,
              structBuilder: ChildActivityStruct.fromSerializableMap,
            ),
          ),
        ),
        FFRoute(
          name: CreateActivityWidget.routeName,
          path: CreateActivityWidget.routePath,
          builder: (context, params) => const CreateActivityWidget(),
        ),
        FFRoute(
          name: AiChatWidget.routeName,
          path: AiChatWidget.routePath,
          asyncParams: {
            'messages':
                getDocList(['chats', 'messages'], MessagesRecord.fromSnapshot),
          },
          builder: (context, params) => AiChatWidget(
            messages: params.getParam<MessagesRecord>(
              'messages',
              ParamType.Document,
              isList: true,
            ),
            chatref: params.getParam(
              'chatref',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['chats'],
            ),
          ),
        ),
        FFRoute(
          name: CalendarWidget.routeName,
          path: CalendarWidget.routePath,
          builder: (context, params) => const CalendarWidget(),
        ),
        FFRoute(
          name: ProfileWidget.routeName,
          path: ProfileWidget.routePath,
          builder: (context, params) => const ProfileWidget(),
        ),
        FFRoute(
          name: NotificationSettingsWidget.routeName,
          path: NotificationSettingsWidget.routePath,
          builder: (context, params) => const NotificationSettingsWidget(),
        ),
        // REMOVED: Debug/script pages - not for production
        // FFRoute(name: 'UploadActivities', path: '/upload-activities', builder: (context, params) => UploadActivitiesPage()),
        // FFRoute(name: CleanupDuplicatesPage.routeName, path: CleanupDuplicatesPage.routePath, builder: (context, params) => CleanupDuplicatesPage()),
        FFRoute(
          name: FirstChildWidget.routeName,
          path: FirstChildWidget.routePath,
          builder: (context, params) => FirstChildWidget(
            isFirst: params.getParam(
              'isFirst',
              ParamType.bool,
            ),
          ),
        ),
        FFRoute(
          name: MilestonessWidget.routeName,
          path: MilestonessWidget.routePath,
          builder: (context, params) => const MilestonessWidget(),
        ),
        FFRoute(
          name: ChildrenWidget.routeName,
          path: ChildrenWidget.routePath,
          builder: (context, params) => ChildrenWidget(
            childRef: params.getParam(
              'childRef',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['childern'],
            ),
          ),
        ),
        FFRoute(
          name: PaimentWidget.routeName,
          path: PaimentWidget.routePath,
          builder: (context, params) => const PaimentWidget(),
        ),
        FFRoute(
          name: OnBoadrdingFirstWidget.routeName,
          path: OnBoadrdingFirstWidget.routePath,
          builder: (context, params) => OnBoadrdingFirstWidget(
            childran: params.getParam(
              'childran',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['childern'],
            ),
          ),
        ),
        FFRoute(
          name: OnBoardingPrimaryGoalWidget.routeName,
          path: OnBoardingPrimaryGoalWidget.routePath,
          builder: (context, params) => OnBoardingPrimaryGoalWidget(
            childrean: params.getParam(
              'childrean',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['childern'],
            ),
          ),
        ),
        FFRoute(
          name: OBoardingSelectSupportTypeWidget.routeName,
          path: OBoardingSelectSupportTypeWidget.routePath,
          builder: (context, params) => OBoardingSelectSupportTypeWidget(
            childrean: params.getParam(
              'childrean',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['childern'],
            ),
          ),
        ),
        FFRoute(
          name: OnBoadrdingLastWidget.routeName,
          path: OnBoadrdingLastWidget.routePath,
          builder: (context, params) => OnBoadrdingLastWidget(
            childrean: params.getParam(
              'childrean',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['childern'],
            ),
          ),
        ),
        FFRoute(
          name: OnBoardingTypeOfSupportCopyWidget.routeName,
          path: OnBoardingTypeOfSupportCopyWidget.routePath,
          builder: (context, params) => const OnBoardingTypeOfSupportCopyWidget(),
        ),
        FFRoute(
          name: OBoardingselectChallengeWidget.routeName,
          path: OBoardingselectChallengeWidget.routePath,
          builder: (context, params) => OBoardingselectChallengeWidget(
            childrean: params.getParam(
              'childrean',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['childern'],
            ),
          ),
        ),
        FFRoute(
          name: ProgramesWidget.routeName,
          path: ProgramesWidget.routePath,
          builder: (context, params) => const ProgramesWidget(),
        ),
        // REMOVED: Debug AI chat test page
        // FFRoute(name: AiChattestAssitantWidget.routeName, path: AiChattestAssitantWidget.routePath, builder: (context, params) => AiChattestAssitantWidget()),
        FFRoute(
          name: ProgramDetailsWidget.routeName,
          path: ProgramDetailsWidget.routePath,
          asyncParams: {
            'programs': getDoc(['programs'], ProgramsRecord.fromSnapshot),
          },
          builder: (context, params) => ProgramDetailsWidget(
            programs: params.getParam(
              'programs',
              ParamType.Document,
            ),
          ),
        ),
        FFRoute(
          name: CreatingProgramStep1Widget.routeName,
          path: CreatingProgramStep1Widget.routePath,
          builder: (context, params) => const CreatingProgramStep1Widget(),
        ),
        FFRoute(
          name: CreateAProgramStep2SelectChildIssueWidget.routeName,
          path: CreateAProgramStep2SelectChildIssueWidget.routePath,
          builder: (context, params) =>
              CreateAProgramStep2SelectChildIssueWidget(
            description: params.getParam(
              'description',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: CreateProgrammStep3FrequencyWidget.routeName,
          path: CreateProgrammStep3FrequencyWidget.routePath,
          asyncParams: {
            'child': getDoc(['childern'], ChildernRecord.fromSnapshot),
          },
          builder: (context, params) => CreateProgrammStep3FrequencyWidget(
            description: params.getParam(
              'description',
              ParamType.String,
            ),
            child: params.getParam(
              'child',
              ParamType.Document,
            ),
          ),
        ),
        FFRoute(
          name: CreateProgrammStep4DayTimeWidget.routeName,
          path: CreateProgrammStep4DayTimeWidget.routePath,
          asyncParams: {
            'selectedChild': getDoc(['childern'], ChildernRecord.fromSnapshot),
          },
          builder: (context, params) => CreateProgrammStep4DayTimeWidget(
            description: params.getParam(
              'description',
              ParamType.String,
            ),
            selectedChild: params.getParam(
              'selectedChild',
              ParamType.Document,
            ),
            frequencyText: params.getParam(
              'frequencyText',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: CreateAProgramLoadingWidget.routeName,
          path: CreateAProgramLoadingWidget.routePath,
          asyncParams: {
            'child': getDoc(['childern'], ChildernRecord.fromSnapshot),
          },
          builder: (context, params) => CreateAProgramLoadingWidget(
            child: params.getParam(
              'child',
              ParamType.Document,
            ),
            preferedTime: params.getParam(
              'preferedTime',
              ParamType.String,
            ),
            challenge: params.getParam(
              'challenge',
              ParamType.String,
            ),
            frequency: params.getParam(
              'frequency',
              ParamType.int,
            ),
            timezone: params.getParam(
              'timezone',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: AiChatCompletionWidget.routeName,
          path: AiChatCompletionWidget.routePath,
          builder: (context, params) => const AiChatCompletionWidget(),
        ),
        FFRoute(
          name: ChildSummaryWidget.routeName,
          path: ChildSummaryWidget.routePath,
          builder: (context, params) => ChildSummaryWidget(
            childRef: params.getParam(
              'childRef',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['childern'],
            ),
          ),
        ),
        FFRoute(
          name: ForgetPaswwordWidget.routeName,
          path: ForgetPaswwordWidget.routePath,
          builder: (context, params) => ForgetPaswwordWidget(
            email: params.getParam(
              'email',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: TasksWidget.routeName,
          path: TasksWidget.routePath,
          builder: (context, params) => const TasksWidget(),
        ),
        FFRoute(
          name: OBoardingStep1Widget.routeName,
          path: OBoardingStep1Widget.routePath,
          builder: (context, params) => const OBoardingStep1Widget(),
        ),
        FFRoute(
          name: AuthPageWidget.routeName,
          path: AuthPageWidget.routePath,
          builder: (context, params) => const AuthPageWidget(),
        ),
        FFRoute(
          name: WelcomeWidget.routeName,
          path: WelcomeWidget.routePath,
          builder: (context, params) => const WelcomeWidget(),
        ),
        FFRoute(
          name: Loginv2Widget.routeName,
          path: Loginv2Widget.routePath,
          builder: (context, params) => const Loginv2Widget(),
        ),
        FFRoute(
          name: SignUpv2Widget.routeName,
          path: SignUpv2Widget.routePath,
          builder: (context, params) => const SignUpv2Widget(),
        ),
        FFRoute(
          name: PreparationWidget.routeName,
          path: PreparationWidget.routePath,
          builder: (context, params) => const PreparationWidget(),
        ),
        FFRoute(
          name: HaveCreatorCodeWidget.routeName,
          path: HaveCreatorCodeWidget.routePath,
          builder: (context, params) => const HaveCreatorCodeWidget(),
        ),
        FFRoute(
          name: FamilySetupIntroWidget.routeName,
          path: FamilySetupIntroWidget.routePath,
          builder: (context, params) => const FamilySetupIntroWidget(),
        ),
        FFRoute(
          name: AddChildxWidget.routeName,
          path: AddChildxWidget.routePath,
          builder: (context, params) => AddChildxWidget(
            isFirst: params.getParam(
              'isFirst',
              ParamType.bool,
            ),
          ),
        ),
        FFRoute(
          name: ParentSetupWidget.routeName,
          path: ParentSetupWidget.routePath,
          builder: (context, params) => const ParentSetupWidget(),
        ),
        FFRoute(
          name: FamilyPreviewWidget.routeName,
          path: FamilyPreviewWidget.routePath,
          builder: (context, params) => const FamilyPreviewWidget(),
        ),
        FFRoute(
          name: OBoardingStep2Widget.routeName,
          path: OBoardingStep2Widget.routePath,
          builder: (context, params) => const OBoardingStep2Widget(),
        ),
        FFRoute(
          name: OBoardingStep3Widget.routeName,
          path: OBoardingStep3Widget.routePath,
          builder: (context, params) => const OBoardingStep3Widget(),
        ),
        FFRoute(
          name: OBoardingStep4Widget.routeName,
          path: OBoardingStep4Widget.routePath,
          builder: (context, params) => const OBoardingStep4Widget(),
        ),
        FFRoute(
          name: OnBoadrdingLastV2Widget.routeName,
          path: OnBoadrdingLastV2Widget.routePath,
          builder: (context, params) => OnBoadrdingLastV2Widget(
            childrean: params.getParam(
              'childrean',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['childern'],
            ),
          ),
        ),
        FFRoute(
          name: GetStartedWidget.routeName,
          path: GetStartedWidget.routePath,
          builder: (context, params) => GetStartedWidget(
            childrean: params.getParam(
              'childrean',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['childern'],
            ),
          ),
        ),
        FFRoute(
          name: PaimentCopyWidget.routeName,
          path: PaimentCopyWidget.routePath,
          builder: (context, params) => const PaimentCopyWidget(),
        ),
        FFRoute(
          name: HomePageV2Widget.routeName,
          path: HomePageV2Widget.routePath,
          builder: (context, params) => const HomePageV2Widget(),
        ),
        FFRoute(
          name: WeekPlanWidget.routeName,
          path: WeekPlanWidget.routePath,
          builder: (context, params) => const WeekPlanWidget(),
        ),
        FFRoute(
          name: GenrateFormCookWidget.routeName,
          path: GenrateFormCookWidget.routePath,
          builder: (context, params) => const GenrateFormCookWidget(),
        ),
        FFRoute(
          name: CreateGroceryListWidget.routeName,
          path: CreateGroceryListWidget.routePath,
          builder: (context, params) => const CreateGroceryListWidget(),
        ),
        FFRoute(
          name: AddToGroceryWidget.routeName,
          path: AddToGroceryWidget.routePath,
          builder: (context, params) => AddToGroceryWidget(
            isellectAll: params.getParam(
              'isellectAll',
              ParamType.bool,
            ),
            isWeekly: params.getParam(
              'isWeekly',
              ParamType.bool,
            ),
            skipToList: params.getParam(
              'skipToList',
              ParamType.bool,
            ),
          ),
        ),
        FFRoute(
          name: WeekPlanItemBoxTabWidget.routeName,
          path: WeekPlanItemBoxTabWidget.routePath,
          asyncParams: {
            'mealRef': getDoc(['meal_plan'], MealPlanRecord.fromSnapshot),
          },
          builder: (context, params) => WeekPlanItemBoxTabWidget(
            date: params.getParam(
              'date',
              ParamType.DateTime,
            ),
            meaTyp: params.getParam<MealTyp>(
              'meaTyp',
              ParamType.Enum,
            ),
            isGenrateFromCookBook: params.getParam(
              'isGenrateFromCookBook',
              ParamType.bool,
            ),
            mealRef: params.getParam(
              'mealRef',
              ParamType.Document,
            ),
          ),
        ),
        FFRoute(
          name: CreateMealPlanWidget.routeName,
          path: CreateMealPlanWidget.routePath,
          asyncParams: {
            'mealRef': getDoc(['meal'], MealRecord.fromSnapshot),
          },
          builder: (context, params) => CreateMealPlanWidget(
            mealRef: params.getParam(
              'mealRef',
              ParamType.Document,
            ),
          ),
        ),
        FFRoute(
          name: AddMealIteamPageWidget.routeName,
          path: AddMealIteamPageWidget.routePath,
          builder: (context, params) => const AddMealIteamPageWidget(),
        ),
        FFRoute(
          name: MealComposerWidget.routeName,
          path: MealComposerWidget.routePath,
          builder: (context, params) => MealComposerWidget(
            date: params.getParam('date', ParamType.DateTime) ?? DateTime.now(),
            mealType: params.getParam<MealTyp>('mealType', ParamType.Enum) ?? MealTyp.Dinner,
            existingMealPlan: params.getParam('existingMealPlan', ParamType.Document),
            editTemplateId: params.getParam('editTemplateId', ParamType.String),
            dayTemplateGroup: params.getParam('dayTemplateGroup', ParamType.String),
            dayTemplateName: params.getParam('dayTemplateName', ParamType.String),
          ),
        ),
        FFRoute(
          name: CreateBookCategoryWidget.routeName,
          path: CreateBookCategoryWidget.routePath,
          builder: (context, params) => CreateBookCategoryWidget(
            mealTyp: params.getParam<MealTyp>(
              'mealTyp',
              ParamType.Enum,
            ),
            date: params.getParam(
              'date',
              ParamType.DateTime,
            ),
            mealplan: params.getParam(
              'mealplan',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['meal_plan'],
            ),
            isGenrateFrom: params.getParam(
              'isGenrateFrom',
              ParamType.bool,
            ),
            mealFirbae: params.getParam(
              'mealFirbae',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['meal'],
            ),
          ),
        ),
        FFRoute(
          name: CategoryDetailsWidget.routeName,
          path: CategoryDetailsWidget.routePath,
          builder: (context, params) => CategoryDetailsWidget(
            categoryTearm: params.getParam(
              'categoryTearm',
              ParamType.String,
            ),
            mealTyp: params.getParam<MealTyp>(
              'mealTyp',
              ParamType.Enum,
            ),
            date: params.getParam(
              'date',
              ParamType.DateTime,
            ),
            mealPlan: params.getParam(
              'mealPlan',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['meal_plan'],
            ),
            isFromGenrate: params.getParam(
              'isFromGenrate',
              ParamType.bool,
            ),
            mealRef: params.getParam(
              'mealRef',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['meal'],
            ),
          ),
        ),
        FFRoute(
          name: CategoryDetailsCopyWidget.routeName,
          path: CategoryDetailsCopyWidget.routePath,
          builder: (context, params) => CategoryDetailsCopyWidget(
            itemDetails: params.getParam(
              'itemDetails',
              ParamType.DataStruct,
              isList: false,
              structBuilder: ResultsStruct.fromSerializableMap,
            ),
          ),
        ),
        FFRoute(
          name: EditeAddMealWidget.routeName,
          path: EditeAddMealWidget.routePath,
          asyncParams: {
            'isReplceItem': getDoc(['meal_plan'], MealPlanRecord.fromSnapshot),
            'editCookingMeal': getDoc(['meal'], MealRecord.fromSnapshot),
          },
          builder: (context, params) => EditeAddMealWidget(
            weekData: params.getParam(
              'weekData',
              ParamType.DateTime,
            ),
            dateTyyp: params.getParam<MealTyp>(
              'dateTyyp',
              ParamType.Enum,
            ),
            isGenrateForm: params.getParam(
              'isGenrateForm',
              ParamType.bool,
            ),
            isReplceItem: params.getParam(
              'isReplceItem',
              ParamType.Document,
            ),
            editCookingMeal: params.getParam(
              'editCookingMeal',
              ParamType.Document,
            ),
            isCreatingSide: params.getParam(
              'isCreatingSide',
              ParamType.bool,
            ),
          ),
        ),
        FFRoute(
          name: LearnPathWidget.routeName,
          path: LearnPathWidget.routePath,
          builder: (context, params) => const LearnPathWidget(),
        ),
        FFRoute(
          name: LearnPathSteponeWidget.routeName,
          path: LearnPathSteponeWidget.routePath,
          builder: (context, params) => const LearnPathSteponeWidget(),
        ),
        FFRoute(
          name: LearnPathSteponStep2Widget.routeName,
          path: LearnPathSteponStep2Widget.routePath,
          builder: (context, params) => LearnPathSteponStep2Widget(
            aiTextField: params.getParam(
              'aiTextField',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: LearnPathSteponStep3Widget.routeName,
          path: LearnPathSteponStep3Widget.routePath,
          builder: (context, params) => LearnPathSteponStep3Widget(
            aiTextFiled: params.getParam(
              'aiTextFiled',
              ParamType.String,
            ),
            selectedChild: params.getParam(
              'selectedChild',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['childern'],
            ),
          ),
        ),
        FFRoute(
          name: LearnPathSteponStep4Widget.routeName,
          path: LearnPathSteponStep4Widget.routePath,
          builder: (context, params) => LearnPathSteponStep4Widget(
            childerRef: params.getParam(
              'childerRef',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['childern'],
            ),
            aiTextField: params.getParam(
              'aiTextField',
              ParamType.String,
            ),
            frequanceTime: params.getParam(
              'frequanceTime',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: LoadinglearnPathWidget.routeName,
          path: LoadinglearnPathWidget.routePath,
          builder: (context, params) => const LoadinglearnPathWidget(),
        ),
        FFRoute(
          name: LearnPathDetialsWidget.routeName,
          path: LearnPathDetialsWidget.routePath,
          builder: (context, params) => LearnPathDetialsWidget(
            leRef: params.getParam(
              'leRef',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['learning_path'],
            ),
          ),
        ),
        FFRoute(
          name: EditeLearningPathtaskWidget.routeName,
          path: EditeLearningPathtaskWidget.routePath,
          asyncParams: {
            'learingTask': getDoc(
                ['learning_path_tasks'], LearningPathTasksRecord.fromSnapshot),
          },
          builder: (context, params) => EditeLearningPathtaskWidget(
            learingTask: params.getParam(
              'learingTask',
              ParamType.Document,
            ),
          ),
        ),
        FFRoute(
          name: ActivitiesV2Widget.routeName,
          path: ActivitiesV2Widget.routePath,
          builder: (context, params) => const ActivitiesV2Widget(),
        ),
        FFRoute(
          name: KindofActivitystepWidget.routeName,
          path: KindofActivitystepWidget.routePath,
          builder: (context, params) => const KindofActivitystepWidget(),
        ),
        FFRoute(
          name: KindofActivitystep2Widget.routeName,
          path: KindofActivitystep2Widget.routePath,
          builder: (context, params) => KindofActivitystep2Widget(
            selectedChild: params.getParam(
              'selectedChild',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['childern'],
            ),
          ),
        ),
        FFRoute(
          name: KindofActivitystep3Widget.routeName,
          path: KindofActivitystep3Widget.routePath,
          builder: (context, params) => KindofActivitystep3Widget(
            selectedchild: params.getParam(
              'selectedchild',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['childern'],
            ),
            kindOfActivity: params.getParam(
              'kindOfActivity',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: LoadinglearnPathCopyWidget.routeName,
          path: LoadinglearnPathCopyWidget.routePath,
          builder: (context, params) => const LoadinglearnPathCopyWidget(),
        ),
        // REMOVED: KindofActivityCopyCopyWidget - duplicate from activitiesv3 (use v2/activites instead)
        FFRoute(
          name: EditetASKWidget.routeName,
          path: EditetASKWidget.routePath,
          builder: (context, params) => const EditetASKWidget(),
        ),
        FFRoute(
          name: AddtaskWidget.routeName,
          path: AddtaskWidget.routePath,
          builder: (context, params) => AddtaskWidget(
            fromPage: params.getParam(
              'fromPage',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: AddEventWidget.routeName,
          path: AddEventWidget.routePath,
          builder: (context, params) => AddEventWidget(
            pageCurrent: params.getParam(
              'pageCurrent',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: AddcalenderWidget.routeName,
          path: AddcalenderWidget.routePath,
          builder: (context, params) => AddcalenderWidget(
            fromPage: params.getParam(
              'fromPage',
              ParamType.String,
            ),
            initialDate: params.getParam(
              'initialDate',
              ParamType.DateTime,
            ),
          ),
        ),
        FFRoute(
          name: MilstonesWidget.routeName,
          path: MilstonesWidget.routePath,
          builder: (context, params) => const MilstonesWidget(),
        ),
        FFRoute(
          name: CalendarpageWidget.routeName,
          path: CalendarpageWidget.routePath,
          builder: (context, params) => const CalendarpageWidget(),
        ),
        FFRoute(
          name: CategoryDetailsLocalProducWidget.routeName,
          path: CategoryDetailsLocalProducWidget.routePath,
          asyncParams: {
            'itemDetails': getDoc(['meal'], MealRecord.fromSnapshot),
          },
          builder: (context, params) => CategoryDetailsLocalProducWidget(
            itemDetails: params.getParam(
              'itemDetails',
              ParamType.Document,
            ),
            selectionDate: params.getParam(
              'selectionDate',
              ParamType.DateTime,
            ),
            selectionMealTyp: params.getParam<MealTyp>(
              'selectionMealTyp',
              ParamType.Enum,
            ),
            selectionMealPlan: params.getParam(
              'selectionMealPlan',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['meal_plan'],
            ),
          ),
        ),
        // REMOVED: Test cloud debug page
        // FFRoute(name: TestcloudWidget.routeName, path: TestcloudWidget.routePath, builder: (context, params) => TestcloudWidget()),
        FFRoute(
          name: CategoryDetailsCopy2Widget.routeName,
          path: CategoryDetailsCopy2Widget.routePath,
          builder: (context, params) => const CategoryDetailsCopy2Widget(),
        ),
        FFRoute(
          name: FavMealPageWidget.routeName,
          path: FavMealPageWidget.routePath,
          builder: (context, params) => FavMealPageWidget(
            mealTyp: params.getParam<MealTyp>(
              'mealTyp',
              ParamType.Enum,
            ),
            date: params.getParam(
              'date',
              ParamType.DateTime,
            ),
            mealPlan: params.getParam(
              'mealPlan',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['meal_plan'],
            ),
            isFromGenrate: params.getParam(
              'isFromGenrate',
              ParamType.bool,
            ),
            mealRef: params.getParam(
              'mealRef',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['meal'],
            ),
          ),
        ),
        FFRoute(
          name: PopupWidget.routeName,
          path: PopupWidget.routePath,
          builder: (context, params) => const PopupWidget(),
        ),
        FFRoute(
          name: WeekPlanItemBoxTabCopyWidget.routeName,
          path: WeekPlanItemBoxTabCopyWidget.routePath,
          asyncParams: {
            'mealRef': getDoc(['meal_plan'], MealPlanRecord.fromSnapshot),
          },
          builder: (context, params) => WeekPlanItemBoxTabCopyWidget(
            date: params.getParam(
              'date',
              ParamType.DateTime,
            ),
            meaTyp: params.getParam<MealTyp>(
              'meaTyp',
              ParamType.Enum,
            ),
            isGenrateFromCookBook: params.getParam(
              'isGenrateFromCookBook',
              ParamType.bool,
            ),
            mealRef: params.getParam(
              'mealRef',
              ParamType.Document,
            ),
          ),
        ),
        FFRoute(
          name: RecipeFromLinkWidget.routeName,
          path: RecipeFromLinkWidget.routePath,
          asyncParams: {
            'isReplceItem': getDoc(['meal_plan'], MealPlanRecord.fromSnapshot),
            'editCookingMeal': getDoc(['meal'], MealRecord.fromSnapshot),
          },
          builder: (context, params) {
            // Use ValueKey with timestamp to force new widget when sharing multiple recipes
            final timestamp = params.getParam('t', ParamType.int) ?? DateTime.now().millisecondsSinceEpoch;
            return RecipeFromLinkWidget(
              key: ValueKey('recipe_$timestamp'),
              weekData: params.getParam(
                'weekData',
                ParamType.DateTime,
              ),
              dateTyyp: params.getParam<MealTyp>(
                'dateTyyp',
                ParamType.Enum,
              ),
              isGenrateForm: params.getParam(
                'isGenrateForm',
                ParamType.bool,
              ),
              isReplceItem: params.getParam(
                'isReplceItem',
                ParamType.Document,
              ),
              editCookingMeal: params.getParam(
                'editCookingMeal',
                ParamType.Document,
              ),
            );
          },
        ),
        FFRoute(
          name: WeekViewWidget.routeName,
          path: WeekViewWidget.routePath,
          builder: (context, params) => const WeekViewWidget(),
        ),
        // REMOVED: Activities feature being replaced
        // FFRoute(
        //   name: FeelingBubblesWidget.routeName,
        //   path: FeelingBubblesWidget.routePath,
        //   builder: (context, params) => FeelingBubblesWidget(),
        // ),
        // REMOVED: Activities feature being replaced
        // FFRoute(
        //   name: ActivityResultsWidget.routeName,
        //   path: ActivityResultsWidget.routePath,
        //   builder: (context, params) => ActivityResultsWidget(
        //     bubbleType: params.getParam(
        //       'bubbleType',
        //       ParamType.String,
        //     ),
        //   ),
        // ),
        // REMOVED: Activities feature being replaced
        // FFRoute(
        //   name: FavoriteActivitiesWidget.routeName,
        //   path: FavoriteActivitiesWidget.routePath,
        //   builder: (context, params) => FavoriteActivitiesWidget(),
        // ),
        FFRoute(
          name: CreateMealComboWidget.routeName,
          path: CreateMealComboWidget.routePath,
          asyncParams: {
            'existingCombo': getDoc(['meal_combo'], MealComboRecord.fromSnapshot),
          },
          builder: (context, params) => CreateMealComboWidget(
            existingCombo: params.getParam(
              'existingCombo',
              ParamType.Document,
            ),
            planDate: params.getParam(
              'planDate',
              ParamType.DateTime,
            ),
            planMealType: params.getParam<MealTyp>(
              'planMealType',
              ParamType.Enum,
            ),
            preselectedEntree: params.getParam(
              'preselectedEntree',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['meal'],
            ),
          ),
        ),
// REMOVED:         FFRoute(
// REMOVED:           name: ActivitiesV2CopyWidget.routeName,
// REMOVED:           path: ActivitiesV2CopyWidget.routePath,
// REMOVED:           builder: (context, params) => ActivitiesV2CopyWidget(),
// REMOVED:         ),
// REMOVED:         FFRoute(
// REMOVED:           name: KindofActivityCopyCopyCopyWidget.routeName,
// REMOVED:           path: KindofActivityCopyCopyCopyWidget.routePath,
// REMOVED:           builder: (context, params) => KindofActivityCopyCopyCopyWidget(
// REMOVED:             activityModel: params.getParam<ActivityModelStruct>(
// REMOVED:               'activityModel',
// REMOVED:               ParamType.DataStruct,
// REMOVED:               isList: true,
// REMOVED:               structBuilder: ActivityModelStruct.fromSerializableMap,
// REMOVED:             ),
// REMOVED:           ),
// REMOVED:         ),
// REMOVED:         FFRoute(
// REMOVED:           name: KindofActivitystepCopyWidget.routeName,
// REMOVED:           path: KindofActivitystepCopyWidget.routePath,
// REMOVED:           builder: (context, params) => KindofActivitystepCopyWidget(),
// REMOVED:         ),
// REMOVED:         FFRoute(
// REMOVED:           name: KindofActivitystep2CopyWidget.routeName,
// REMOVED:           path: KindofActivitystep2CopyWidget.routePath,
// REMOVED:           builder: (context, params) => KindofActivitystep2CopyWidget(
// REMOVED:             selectedChild: params.getParam(
// REMOVED:               'selectedChild',
// REMOVED:               ParamType.DocumentReference,
// REMOVED:               isList: false,
// REMOVED:               collectionNamePath: ['childern'],
// REMOVED:             ),
// REMOVED:           ),
// REMOVED:         ),
// REMOVED:         FFRoute(
// REMOVED:           name: KindofActivitystep3CopyWidget.routeName,
// REMOVED:           path: KindofActivitystep3CopyWidget.routePath,
// REMOVED:           builder: (context, params) => KindofActivitystep3CopyWidget(
// REMOVED:             selectedchild: params.getParam(
// REMOVED:               'selectedchild',
// REMOVED:               ParamType.DocumentReference,
// REMOVED:               isList: false,
// REMOVED:               collectionNamePath: ['childern'],
// REMOVED:             ),
// REMOVED:             kindOfActivity: params.getParam(
// REMOVED:               'kindOfActivity',
// REMOVED:               ParamType.String,
// REMOVED:             ),
// REMOVED:           ),
// REMOVED:         ),
// REMOVED:         FFRoute(
// REMOVED:           name: LoadinglearnPathCopyCopyWidget.routeName,
// REMOVED:           path: LoadinglearnPathCopyCopyWidget.routePath,
// REMOVED:           builder: (context, params) => LoadinglearnPathCopyCopyWidget(),
// REMOVED:         )
        FFRoute(
          name: ResourcesPageWidget.routeName,
          path: ResourcesPageWidget.routePath,
          builder: (context, params) => const ResourcesPageWidget(),
        ),
        FFRoute(
          name: ArticleDetailWidget.routeName,
          path: ArticleDetailWidget.routePath,
          builder: (context, params) => ArticleDetailWidget(
            articleId: params.getParam(
              'articleId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: ImportSharedContentWidget.routeName,
          path: ImportSharedContentWidget.routePath,
          builder: (context, params) => ImportSharedContentWidget(
            shareCode: params.getParam(
              'shareCode',
              ParamType.String,
            ) ?? '',
          ),
        ),
        FFRoute(
          name: TodosPageWidget.routeName,
          path: TodosPageWidget.routePath,
          builder: (context, params) => const TodosPageWidget(),
        ),
        // REMOVED: Activities feature being replaced
        // FFRoute(
        //   name: MyActivitiesWidget.routeName,
        //   path: MyActivitiesWidget.routePath,
        //   builder: (context, params) => const MyActivitiesWidget(),
        // ),
        // TEMPORARY: Skills & Hobbies Preview
        FFRoute(
          name: 'skillsPreview',
          path: '/skillsPreview',
          builder: (context, params) => const SkillsHomePreviewWidget(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/loginv2';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? const AnimatedSplashScreen()
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => const TransitionInfo(
    hasTransition: true,
    transitionType: PageTransitionType.fade,
    duration: Duration(milliseconds: 150),
  );
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}

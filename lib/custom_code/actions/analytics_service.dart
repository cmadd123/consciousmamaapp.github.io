import 'package:firebase_analytics/firebase_analytics.dart';

/// Analytics Service for MomRise
/// Tracks user events, traffic sources, and conversions
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ============ APP LIFECYCLE ============

  /// Track app open with source attribution
  Future<void> logAppOpen({String? source}) async {
    await _analytics.logAppOpen();

    // Track source if provided (Product Hunt, Reddit, etc.)
    if (source != null) {
      await _analytics.logEvent(
        name: 'app_open_source',
        parameters: {'source': source},
      );
    }
  }

  /// Track first app open (new user)
  Future<void> logFirstOpen({String? source, String? campaign}) async {
    await _analytics.logEvent(
      name: 'first_open',
      parameters: {
        if (source != null) 'source': source,
        if (campaign != null) 'campaign': campaign,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ============ TRAFFIC SOURCE TRACKING ============

  /// Track Product Hunt traffic
  /// Call this when user arrives from Product Hunt link
  Future<void> logProductHuntVisit({
    String? referrer, // e.g., "homepage", "email", "notification"
  }) async {
    await _analytics.logEvent(
      name: 'traffic_source',
      parameters: {
        'source': 'product_hunt',
        'medium': 'referral',
        if (referrer != null) 'referrer': referrer,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track Reddit traffic with subreddit attribution
  /// Call this when user arrives from Reddit link
  Future<void> logRedditVisit({
    String? subreddit, // e.g., "EatCheapAndHealthy", "Parenting"
    String? postId,    // Reddit post ID if available
  }) async {
    await _analytics.logEvent(
      name: 'traffic_source',
      parameters: {
        'source': 'reddit',
        'medium': 'social',
        if (subreddit != null) 'subreddit': subreddit,
        if (postId != null) 'post_id': postId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track organic app store discovery
  Future<void> logOrganicInstall({String? keyword}) async {
    await _analytics.logEvent(
      name: 'traffic_source',
      parameters: {
        'source': 'organic',
        'medium': 'app_store',
        if (keyword != null) 'search_keyword': keyword,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ============ USER JOURNEY ============

  /// Track onboarding completion
  Future<void> logOnboardingComplete({
    required int childrenAdded,
    bool parentInfoCompleted = false,
  }) async {
    await _analytics.logEvent(
      name: 'onboarding_complete',
      parameters: {
        'children_count': childrenAdded,
        'parent_info_completed': parentInfoCompleted,
      },
    );
  }

  /// Track feature discovery
  Future<void> logFeatureUsed(String featureName) async {
    await _analytics.logEvent(
      name: 'feature_used',
      parameters: {'feature_name': featureName},
    );
  }

  // ============ CONVERSIONS ============

  /// Track subscription started (trial or paid)
  Future<void> logSubscriptionStart({
    required String tier, // "free_trial", "monthly", "annual"
    required double value, // $6.99 for monthly
  }) async {
    await _analytics.logEvent(
      name: 'subscribe',
      parameters: {
        'tier': tier,
        'value': value,
        'currency': 'USD',
      },
    );
  }

  /// Track grocery integration usage (key monetization metric)
  Future<void> logGroceryIntegration({
    required String provider, // "instacart" or "walmart"
    required int itemCount,
  }) async {
    await _analytics.logEvent(
      name: 'grocery_integration_used',
      parameters: {
        'provider': provider,
        'item_count': itemCount,
      },
    );
  }

  // ============ ENGAGEMENT ============

  /// Track learning path creation (AI usage)
  Future<void> logLearningPathCreated({
    required String theme,
    required int taskCount,
  }) async {
    await _analytics.logEvent(
      name: 'learning_path_created',
      parameters: {
        'theme': theme,
        'task_count': taskCount,
      },
    );
  }

  /// Track meal plan creation
  Future<void> logMealPlanCreated({
    required int recipeCount,
    required int daysPlanned,
  }) async {
    await _analytics.logEvent(
      name: 'meal_plan_created',
      parameters: {
        'recipe_count': recipeCount,
        'days_planned': daysPlanned,
      },
    );
  }

  /// Track milestone marked
  Future<void> logMilestoneMarked({required String category}) async {
    await _analytics.logEvent(
      name: 'milestone_marked',
      parameters: {'category': category},
    );
  }

  // ============ RETENTION ============

  /// Track return visit (Day 1, Day 7, Day 30)
  Future<void> logReturnVisit({required int daysSinceInstall}) async {
    await _analytics.logEvent(
      name: 'return_visit',
      parameters: {'days_since_install': daysSinceInstall},
    );
  }

  // ============ USER PROPERTIES ============

  /// Set user properties for segmentation
  Future<void> setUserProperties({
    int? childrenCount,
    String? subscriptionTier,
    bool? hasUsedGroceryIntegration,
  }) async {
    if (childrenCount != null) {
      await _analytics.setUserProperty(
        name: 'children_count',
        value: childrenCount.toString(),
      );
    }
    if (subscriptionTier != null) {
      await _analytics.setUserProperty(
        name: 'subscription_tier',
        value: subscriptionTier,
      );
    }
    if (hasUsedGroceryIntegration != null) {
      await _analytics.setUserProperty(
        name: 'grocery_user',
        value: hasUsedGroceryIntegration.toString(),
      );
    }
  }

  /// Set user ID (for cross-device tracking)
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  // ============ SCREEN TRACKING ============

  /// Track screen views
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // ============ CAMPAIGN TRACKING ============

  /// Track campaign parameters from deep links
  /// Example: momrise://open?utm_source=reddit&utm_medium=post&utm_campaign=launch
  Future<void> logCampaign({
    required String source,     // "reddit", "product_hunt", "email"
    required String medium,     // "post", "comment", "newsletter"
    String? campaign,           // "launch_week", "feature_announcement"
    String? content,            // specific post/email variant
  }) async {
    await _analytics.logEvent(
      name: 'campaign_attribution',
      parameters: {
        'utm_source': source,
        'utm_medium': medium,
        if (campaign != null) 'utm_campaign': campaign,
        if (content != null) 'utm_content': content,
      },
    );
  }
}

/// Global analytics service instance
final analyticsService = AnalyticsService();

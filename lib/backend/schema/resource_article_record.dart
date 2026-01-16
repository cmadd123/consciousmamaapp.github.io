import 'package:cloud_firestore/cloud_firestore.dart';

/// Resource Article model for curated parenting content
/// Articles are stored in Firestore 'resource_articles' collection
class ResourceArticleRecord {
  ResourceArticleRecord({
    this.id,
    this.title,
    this.subtitle,
    this.category,
    this.iconName,
    this.content,
    this.readTimeMinutes,
    this.order,
    this.isPublished,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? title;
  final String? subtitle;
  final String? category; // e.g., "morning", "sleep", "meals", "behavior", "development"
  final String? iconName; // Material icon name
  final String? content; // Markdown content
  final int? readTimeMinutes;
  final int? order; // Display order
  final bool? isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Firestore collection reference
  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('resource_articles');

  // Get document reference
  DocumentReference get reference => collection.doc(id);

  // Create from Firestore document
  factory ResourceArticleRecord.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    return ResourceArticleRecord(
      id: snapshot.id,
      title: data?['title'] as String?,
      subtitle: data?['subtitle'] as String?,
      category: data?['category'] as String?,
      iconName: data?['icon_name'] as String?,
      content: data?['content'] as String?,
      readTimeMinutes: data?['read_time_minutes'] as int?,
      order: data?['order'] as int?,
      isPublished: data?['is_published'] as bool? ?? false,
      createdAt: (data?['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (data?['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'icon_name': iconName,
      'content': content,
      'read_time_minutes': readTimeMinutes,
      'order': order,
      'is_published': isPublished,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  // Stream of all published articles ordered by 'order' field
  static Stream<List<ResourceArticleRecord>> queryPublishedArticles() {
    return collection
        .where('is_published', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ResourceArticleRecord.fromSnapshot(doc))
            .toList());
  }

  // Stream of articles by category
  static Stream<List<ResourceArticleRecord>> queryByCategory(String category) {
    return collection
        .where('is_published', isEqualTo: true)
        .where('category', isEqualTo: category)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ResourceArticleRecord.fromSnapshot(doc))
            .toList());
  }

  // Get single article by ID
  static Future<ResourceArticleRecord?> getById(String id) async {
    final doc = await collection.doc(id).get();
    if (doc.exists) {
      return ResourceArticleRecord.fromSnapshot(doc);
    }
    return null;
  }

  // Get single article stream
  static Stream<ResourceArticleRecord> getDocument(DocumentReference ref) {
    return ref.snapshots().map((snapshot) => ResourceArticleRecord.fromSnapshot(snapshot));
  }
}

/// Article categories for organizing content
class ArticleCategory {
  static const String morning = 'morning';
  static const String sleep = 'sleep';
  static const String meals = 'meals';
  static const String behavior = 'behavior';
  static const String development = 'development';
  static const String selfCare = 'self_care';
  static const String routines = 'routines';
  static const String siblings = 'siblings';

  static const Map<String, String> displayNames = {
    morning: 'Morning Routines',
    sleep: 'Sleep & Bedtime',
    meals: 'Meals & Eating',
    behavior: 'Behavior & Discipline',
    development: 'Development & Learning',
    selfCare: 'Self-Care for Mom',
    routines: 'Daily Routines',
    siblings: 'Siblings & Family',
  };

  static const Map<String, String> icons = {
    morning: 'wb_sunny',
    sleep: 'bedtime',
    meals: 'restaurant',
    behavior: 'psychology',
    development: 'school',
    selfCare: 'spa',
    routines: 'schedule',
    siblings: 'family_restroom',
  };
}

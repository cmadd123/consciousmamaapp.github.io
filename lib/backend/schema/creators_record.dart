import 'dart:async';


import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CreatorsRecord extends FirestoreRecord {
  CreatorsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "bio" field.
  String? _bio;
  String get bio => _bio ?? '';
  bool hasBio() => _bio != null;

  // "avatar_url" field.
  String? _avatarUrl;
  String get avatarUrl => _avatarUrl ?? '';
  bool hasAvatarUrl() => _avatarUrl != null;

  // "niche" field.
  String? _niche;
  String get niche => _niche ?? '';
  bool hasNiche() => _niche != null;

  // "code" field — unique creator code (e.g., "HALEY23").
  String? _code;
  String get code => _code ?? '';
  bool hasCode() => _code != null;

  // "user_ref" field — links to the creator's user account.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "follower_count" field.
  int? _followerCount;
  int get followerCount => _followerCount ?? 0;
  bool hasFollowerCount() => _followerCount != null;

  // Theme fields
  // "theme_primary" field — primary color hex (e.g., "#52A097").
  String? _themePrimary;
  String get themePrimary => _themePrimary ?? '';
  bool hasThemePrimary() => _themePrimary != null;

  // "theme_secondary" field — secondary/background color hex.
  String? _themeSecondary;
  String get themeSecondary => _themeSecondary ?? '';
  bool hasThemeSecondary() => _themeSecondary != null;

  // "theme_accent" field — accent color hex.
  String? _themeAccent;
  String get themeAccent => _themeAccent ?? '';
  bool hasThemeAccent() => _themeAccent != null;

  // "theme_font" field — font family name (e.g., "Playfair Display").
  String? _themeFont;
  String get themeFont => _themeFont ?? '';
  bool hasThemeFont() => _themeFont != null;

  // "theme_background_gradient_start" field.
  String? _themeBackgroundGradientStart;
  String get themeBackgroundGradientStart => _themeBackgroundGradientStart ?? '';
  bool hasThemeBackgroundGradientStart() => _themeBackgroundGradientStart != null;

  // "theme_background_gradient_end" field.
  String? _themeBackgroundGradientEnd;
  String get themeBackgroundGradientEnd => _themeBackgroundGradientEnd ?? '';
  bool hasThemeBackgroundGradientEnd() => _themeBackgroundGradientEnd != null;

  // "theme_icon_color" field.
  String? _themeIconColor;
  String get themeIconColor => _themeIconColor ?? '';
  bool hasThemeIconColor() => _themeIconColor != null;

  // "is_active" field — whether creator account is active.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  bool hasIsActive() => _isActive != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "social_links" field — map of platform → URL.
  Map<String, String>? _socialLinks;
  Map<String, String> get socialLinks => _socialLinks ?? {};
  bool hasSocialLinks() => _socialLinks != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _bio = snapshotData['bio'] as String?;
    _avatarUrl = snapshotData['avatar_url'] as String?;
    _niche = snapshotData['niche'] as String?;
    _code = snapshotData['code'] as String?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _followerCount = castToType<int>(snapshotData['follower_count']);
    _themePrimary = snapshotData['theme_primary'] as String?;
    _themeSecondary = snapshotData['theme_secondary'] as String?;
    _themeAccent = snapshotData['theme_accent'] as String?;
    _themeFont = snapshotData['theme_font'] as String?;
    _themeBackgroundGradientStart = snapshotData['theme_background_gradient_start'] as String?;
    _themeBackgroundGradientEnd = snapshotData['theme_background_gradient_end'] as String?;
    _themeIconColor = snapshotData['theme_icon_color'] as String?;
    _isActive = snapshotData['is_active'] as bool?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    if (snapshotData['social_links'] != null) {
      _socialLinks = Map<String, String>.from(snapshotData['social_links'] as Map);
    }
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('creators');

  static Stream<CreatorsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CreatorsRecord.fromSnapshot(s));

  static Future<CreatorsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CreatorsRecord.fromSnapshot(s));

  static CreatorsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CreatorsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CreatorsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CreatorsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CreatorsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CreatorsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCreatorsRecordData({
  String? name,
  String? bio,
  String? avatarUrl,
  String? niche,
  String? code,
  DocumentReference? userRef,
  int? followerCount,
  String? themePrimary,
  String? themeSecondary,
  String? themeAccent,
  String? themeFont,
  String? themeBackgroundGradientStart,
  String? themeBackgroundGradientEnd,
  String? themeIconColor,
  bool? isActive,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'bio': bio,
      'avatar_url': avatarUrl,
      'niche': niche,
      'code': code,
      'user_ref': userRef,
      'follower_count': followerCount,
      'theme_primary': themePrimary,
      'theme_secondary': themeSecondary,
      'theme_accent': themeAccent,
      'theme_font': themeFont,
      'theme_background_gradient_start': themeBackgroundGradientStart,
      'theme_background_gradient_end': themeBackgroundGradientEnd,
      'theme_icon_color': themeIconColor,
      'is_active': isActive,
      'created_at': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

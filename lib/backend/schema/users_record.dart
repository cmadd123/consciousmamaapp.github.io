import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "selectedAvtar" field.
  String? _selectedAvtar;
  String get selectedAvtar => _selectedAvtar ?? '';
  bool hasSelectedAvtar() => _selectedAvtar != null;

  // "children_primary_goal" field.
  String? _childrenPrimaryGoal;
  String get childrenPrimaryGoal => _childrenPrimaryGoal ?? '';
  bool hasChildrenPrimaryGoal() => _childrenPrimaryGoal != null;

  // "user_challenge" field.
  String? _userChallenge;
  String get userChallenge => _userChallenge ?? '';
  bool hasUserChallenge() => _userChallenge != null;

  // "user_support" field.
  String? _userSupport;
  String get userSupport => _userSupport ?? '';
  bool hasUserSupport() => _userSupport != null;

  // "first_child_created" field.
  bool? _firstChildCreated;
  bool get firstChildCreated => _firstChildCreated ?? false;
  bool hasFirstChildCreated() => _firstChildCreated != null;

  // "preventing_meal_times" field.
  String? _preventingMealTimes;
  String get preventingMealTimes => _preventingMealTimes ?? '';
  bool hasPreventingMealTimes() => _preventingMealTimes != null;

  // "fcmToken" field.
  String? _fcmToken;
  String get fcmToken => _fcmToken ?? '';
  bool hasFcmToken() => _fcmToken != null;

  // "onboarding_completed" field.
  bool? _onboardingCompleted;
  bool get onboardingCompleted => _onboardingCompleted ?? false;
  bool hasOnboardingCompleted() => _onboardingCompleted != null;

  // "my_name" field - what the user calls themselves (defaults to "Me")
  String? _myName;
  String get myName => _myName ?? 'Me';
  bool hasMyName() => _myName != null;

  // "my_color" field - user's chosen color (stored as int)
  int? _myColor;
  int? get myColor => _myColor;
  bool hasMyColor() => _myColor != null;

  // "partner_name" field - what user calls their partner
  String? _partnerName;
  String get partnerName => _partnerName ?? '';
  bool hasPartnerName() => _partnerName != null;

  // "partner_color" field - partner's chosen color (stored as int)
  int? _partnerColor;
  int? get partnerColor => _partnerColor;
  bool hasPartnerColor() => _partnerColor != null;

  // "meal_plan_reminders_enabled" field - weekly meal planning reminder toggle
  bool? _mealPlanRemindersEnabled;
  bool get mealPlanRemindersEnabled => _mealPlanRemindersEnabled ?? true; // Default ON
  bool hasMealPlanRemindersEnabled() => _mealPlanRemindersEnabled != null;

  // "meal_plan_reminder_day" field - which day of week to remind (0 = Sunday, 6 = Saturday)
  int? _mealPlanReminderDay;
  int get mealPlanReminderDay => _mealPlanReminderDay ?? 0; // Default Sunday
  bool hasMealPlanReminderDay() => _mealPlanReminderDay != null;

  // "meal_plan_reminder_hour" field - hour of day (0-23)
  int? _mealPlanReminderHour;
  int get mealPlanReminderHour => _mealPlanReminderHour ?? 18; // Default 6 PM
  bool hasMealPlanReminderHour() => _mealPlanReminderHour != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _selectedAvtar = snapshotData['selectedAvtar'] as String?;
    _childrenPrimaryGoal = snapshotData['children_primary_goal'] as String?;
    _userChallenge = snapshotData['user_challenge'] as String?;
    _userSupport = snapshotData['user_support'] as String?;
    _firstChildCreated = snapshotData['first_child_created'] as bool?;
    _preventingMealTimes = snapshotData['preventing_meal_times'] as String?;
    _fcmToken = snapshotData['fcmToken'] as String?;
    _onboardingCompleted = snapshotData['onboarding_completed'] as bool?;
    _myName = snapshotData['my_name'] as String?;
    _myColor = castToType<int>(snapshotData['my_color']);
    _partnerName = snapshotData['partner_name'] as String?;
    _partnerColor = castToType<int>(snapshotData['partner_color']);
    _mealPlanRemindersEnabled = snapshotData['meal_plan_reminders_enabled'] as bool?;
    _mealPlanReminderDay = castToType<int>(snapshotData['meal_plan_reminder_day']);
    _mealPlanReminderHour = castToType<int>(snapshotData['meal_plan_reminder_hour']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? selectedAvtar,
  String? childrenPrimaryGoal,
  String? userChallenge,
  String? userSupport,
  bool? firstChildCreated,
  String? preventingMealTimes,
  String? fcmToken,
  bool? onboardingCompleted,
  String? myName,
  int? myColor,
  String? partnerName,
  int? partnerColor,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'selectedAvtar': selectedAvtar,
      'children_primary_goal': childrenPrimaryGoal,
      'user_challenge': userChallenge,
      'user_support': userSupport,
      'first_child_created': firstChildCreated,
      'preventing_meal_times': preventingMealTimes,
      'fcmToken': fcmToken,
      'onboarding_completed': onboardingCompleted,
      'my_name': myName,
      'my_color': myColor,
      'partner_name': partnerName,
      'partner_color': partnerColor,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.selectedAvtar == e2?.selectedAvtar &&
        e1?.childrenPrimaryGoal == e2?.childrenPrimaryGoal &&
        e1?.userChallenge == e2?.userChallenge &&
        e1?.userSupport == e2?.userSupport &&
        e1?.firstChildCreated == e2?.firstChildCreated &&
        e1?.preventingMealTimes == e2?.preventingMealTimes &&
        e1?.fcmToken == e2?.fcmToken &&
        e1?.onboardingCompleted == e2?.onboardingCompleted &&
        e1?.myName == e2?.myName &&
        e1?.myColor == e2?.myColor &&
        e1?.partnerName == e2?.partnerName &&
        e1?.partnerColor == e2?.partnerColor;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.selectedAvtar,
        e?.childrenPrimaryGoal,
        e?.userChallenge,
        e?.userSupport,
        e?.firstChildCreated,
        e?.preventingMealTimes,
        e?.fcmToken,
        e?.onboardingCompleted,
        e?.myName,
        e?.myColor,
        e?.partnerName,
        e?.partnerColor,
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}

import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// User Activity Record - User-created activities
///
/// Similar to ActivityRecord but includes user_ref for ownership
/// and additional fields for customization
class UserActivityRecord extends FirestoreRecord {
  UserActivityRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "user_ref" field - owner of this activity
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "location" field - "indoor" or "outdoor" or "both"
  String? _location;
  String get location => _location ?? '';
  bool hasLocation() => _location != null;

  // "energy" field - "low", "medium", or "high"
  String? _energy;
  String get energy => _energy ?? '';
  bool hasEnergy() => _energy != null;

  // "things_needed" field - materials/supplies needed
  String? _thingsNeeded;
  String get thingsNeeded => _thingsNeeded ?? '';
  bool hasThingsNeeded() => _thingsNeeded != null;

  // "time_duration" field - e.g. "15 minutes"
  String? _timeDuration;
  String get timeDuration => _timeDuration ?? '';
  bool hasTimeDuration() => _timeDuration != null;

  // "parent_proximity" field - "involved", "nearby", or "free"
  String? _parentProximity;
  String get parentProximity => _parentProximity ?? '';
  bool hasParentProximity() => _parentProximity != null;

  // "setup_time" field - "0-2 min", "3-5 min", "5+ min"
  String? _setupTime;
  String get setupTime => _setupTime ?? '';
  bool hasSetupTime() => _setupTime != null;

  // "cleanup_difficulty" field - "easy", "medium", "messy"
  String? _cleanupDifficulty;
  String get cleanupDifficulty => _cleanupDifficulty ?? '';
  bool hasCleanupDifficulty() => _cleanupDifficulty != null;

  // "icon_code_point" field - stores the icon codepoint as int
  int? _iconCodePoint;
  int get iconCodePoint => _iconCodePoint ?? 0xe40a; // Default to palette icon
  bool hasIconCodePoint() => _iconCodePoint != null;

  // "icon_color" field - stores the icon color as int (Color.value)
  int? _iconColor;
  int get iconColor => _iconColor ?? 0xFFE91E63; // Default to pink
  bool hasIconColor() => _iconColor != null;

  // "icon_emoji" field - stores the emoji as a string
  String? _iconEmoji;
  String get iconEmoji => _iconEmoji ?? '🎨'; // Default to art emoji
  bool hasIconEmoji() => _iconEmoji != null;

  // "is_favorite" field
  bool? _isFavorite;
  bool get isFavorite => _isFavorite ?? false;
  bool hasIsFavorite() => _isFavorite != null;

  // "created_time" field
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "updated_time" field
  DateTime? _updatedTime;
  DateTime? get updatedTime => _updatedTime;
  bool hasUpdatedTime() => _updatedTime != null;

  // "times_used" field - how many times added to calendar
  int? _timesUsed;
  int get timesUsed => _timesUsed ?? 0;
  bool hasTimesUsed() => _timesUsed != null;

  // "last_used_date" field
  DateTime? _lastUsedDate;
  DateTime? get lastUsedDate => _lastUsedDate;
  bool hasLastUsedDate() => _lastUsedDate != null;

  // "assigned_children" field - list of child references
  List<DocumentReference>? _assignedChildren;
  List<DocumentReference> get assignedChildren => _assignedChildren ?? const [];
  bool hasAssignedChildren() => _assignedChildren != null && _assignedChildren!.isNotEmpty;

  // "assigned_to_mom" field
  bool? _assignedToMom;
  bool get assignedToMom => _assignedToMom ?? false;
  bool hasAssignedToMom() => _assignedToMom != null;

  // "assigned_to_dad" field
  bool? _assignedToDad;
  bool get assignedToDad => _assignedToDad ?? false;
  bool hasAssignedToDad() => _assignedToDad != null;

  // "safety_note" field - safety concerns or notes for the activity
  String? _safetyNote;
  String get safetyNote => _safetyNote ?? '';
  bool hasSafetyNote() => _safetyNote != null;

  void _initializeFields() {
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _title = snapshotData['title'] as String?;
    _description = snapshotData['description'] as String?;
    _location = snapshotData['location'] as String?;
    _energy = snapshotData['energy'] as String?;
    _thingsNeeded = snapshotData['things_needed'] as String?;
    _timeDuration = snapshotData['time_duration'] as String?;
    _parentProximity = snapshotData['parent_proximity'] as String?;
    _setupTime = snapshotData['setup_time'] as String?;
    _cleanupDifficulty = snapshotData['cleanup_difficulty'] as String?;
    _iconCodePoint = castToType<int>(snapshotData['icon_code_point']);
    _iconColor = castToType<int>(snapshotData['icon_color']);
    _iconEmoji = snapshotData['icon_emoji'] as String?;
    _isFavorite = snapshotData['is_favorite'] as bool?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _updatedTime = snapshotData['updated_time'] as DateTime?;
    _timesUsed = castToType<int>(snapshotData['times_used']);
    _lastUsedDate = snapshotData['last_used_date'] as DateTime?;
    _assignedChildren = getDataList(snapshotData['assigned_children']);
    _assignedToMom = snapshotData['assigned_to_mom'] as bool?;
    _assignedToDad = snapshotData['assigned_to_dad'] as bool?;
    _safetyNote = snapshotData['safety_note'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('user_activities');

  static Stream<UserActivityRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserActivityRecord.fromSnapshot(s));

  static Future<UserActivityRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UserActivityRecord.fromSnapshot(s));

  static UserActivityRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UserActivityRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UserActivityRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UserActivityRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UserActivityRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UserActivityRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUserActivityRecordData({
  DocumentReference? userRef,
  String? title,
  String? description,
  String? location,
  String? energy,
  String? thingsNeeded,
  String? timeDuration,
  String? parentProximity,
  String? setupTime,
  String? cleanupDifficulty,
  int? iconCodePoint,
  int? iconColor,
  String? iconEmoji,
  bool? isFavorite,
  DateTime? createdTime,
  DateTime? updatedTime,
  int? timesUsed,
  DateTime? lastUsedDate,
  List<DocumentReference>? assignedChildren,
  bool? assignedToMom,
  bool? assignedToDad,
  String? safetyNote,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_ref': userRef,
      'title': title,
      'description': description,
      'location': location,
      'energy': energy,
      'things_needed': thingsNeeded,
      'time_duration': timeDuration,
      'parent_proximity': parentProximity,
      'setup_time': setupTime,
      'cleanup_difficulty': cleanupDifficulty,
      'icon_code_point': iconCodePoint,
      'icon_color': iconColor,
      'icon_emoji': iconEmoji,
      'is_favorite': isFavorite,
      'created_time': createdTime,
      'updated_time': updatedTime,
      'times_used': timesUsed,
      'last_used_date': lastUsedDate,
      'assigned_children': assignedChildren,
      'assigned_to_mom': assignedToMom,
      'assigned_to_dad': assignedToDad,
      'safety_note': safetyNote,
    }.withoutNulls,
  );

  return firestoreData;
}

class UserActivityRecordDocumentEquality
    implements Equality<UserActivityRecord> {
  const UserActivityRecordDocumentEquality();

  @override
  bool equals(UserActivityRecord? e1, UserActivityRecord? e2) {
    const listEquality = ListEquality();
    return e1?.userRef == e2?.userRef &&
        e1?.title == e2?.title &&
        e1?.description == e2?.description &&
        e1?.location == e2?.location &&
        e1?.energy == e2?.energy &&
        e1?.thingsNeeded == e2?.thingsNeeded &&
        e1?.timeDuration == e2?.timeDuration &&
        e1?.parentProximity == e2?.parentProximity &&
        e1?.setupTime == e2?.setupTime &&
        e1?.cleanupDifficulty == e2?.cleanupDifficulty &&
        e1?.iconCodePoint == e2?.iconCodePoint &&
        e1?.iconColor == e2?.iconColor &&
        e1?.iconEmoji == e2?.iconEmoji &&
        e1?.isFavorite == e2?.isFavorite &&
        e1?.createdTime == e2?.createdTime &&
        e1?.updatedTime == e2?.updatedTime &&
        e1?.timesUsed == e2?.timesUsed &&
        e1?.lastUsedDate == e2?.lastUsedDate &&
        listEquality.equals(e1?.assignedChildren, e2?.assignedChildren) &&
        e1?.assignedToMom == e2?.assignedToMom &&
        e1?.assignedToDad == e2?.assignedToDad;
  }

  @override
  int hash(UserActivityRecord? e) => const ListEquality().hash([
        e?.userRef,
        e?.title,
        e?.description,
        e?.location,
        e?.energy,
        e?.thingsNeeded,
        e?.timeDuration,
        e?.parentProximity,
        e?.setupTime,
        e?.cleanupDifficulty,
        e?.iconCodePoint,
        e?.iconColor,
        e?.iconEmoji,
        e?.isFavorite,
        e?.createdTime,
        e?.updatedTime,
        e?.timesUsed,
        e?.lastUsedDate,
        e?.assignedChildren,
        e?.assignedToMom,
        e?.assignedToDad,
      ]);

  @override
  bool isValidKey(Object? o) => o is UserActivityRecord;
}

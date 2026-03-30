import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SkillPathRecord extends FirestoreRecord {
  SkillPathRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "skill_name" field.
  String? _skillName;
  String get skillName => _skillName ?? '';
  bool hasSkillName() => _skillName != null;

  // "skill_icon" field.
  String? _skillIcon;
  String get skillIcon => _skillIcon ?? '';
  bool hasSkillIcon() => _skillIcon != null;

  // "child_ref" field.
  DocumentReference? _childRef;
  DocumentReference? get childRef => _childRef;
  bool hasChildRef() => _childRef != null;

  // "milestones" field.
  List<SkillMilestoneStruct>? _milestones;
  List<SkillMilestoneStruct> get milestones => _milestones ?? const [];
  bool hasMilestones() => _milestones != null;

  // "total_milestones" field.
  int? _totalMilestones;
  int get totalMilestones => _totalMilestones ?? 15;
  bool hasTotalMilestones() => _totalMilestones != null;

  // "completed_milestones" field.
  int? _completedMilestones;
  int get completedMilestones => _completedMilestones ?? 0;
  bool hasCompletedMilestones() => _completedMilestones != null;

  // "total_sub_milestones" field.
  int? _totalSubMilestones;
  int get totalSubMilestones => _totalSubMilestones ?? 45;
  bool hasTotalSubMilestones() => _totalSubMilestones != null;

  // "completed_sub_milestones" field.
  int? _completedSubMilestones;
  int get completedSubMilestones => _completedSubMilestones ?? 0;
  bool hasCompletedSubMilestones() => _completedSubMilestones != null;

  // "progress_percentage" field.
  double? _progressPercentage;
  double get progressPercentage => _progressPercentage ?? 0.0;
  bool hasProgressPercentage() => _progressPercentage != null;

  // "started_date" field.
  DateTime? _startedDate;
  DateTime? get startedDate => _startedDate;
  bool hasStartedDate() => _startedDate != null;

  // "last_updated" field.
  DateTime? _lastUpdated;
  DateTime? get lastUpdated => _lastUpdated;
  bool hasLastUpdated() => _lastUpdated != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "expert_source" field.
  String? _expertSource;
  String get expertSource => _expertSource ?? '';
  bool hasExpertSource() => _expertSource != null;

  // "generation_goal" field.
  String? _generationGoal;
  String get generationGoal => _generationGoal ?? '';
  bool hasGenerationGoal() => _generationGoal != null;

  // "tools_available" field.
  List<String>? _toolsAvailable;
  List<String> get toolsAvailable => _toolsAvailable ?? const [];
  bool hasToolsAvailable() => _toolsAvailable != null;

  // "time_per_session" field.
  String? _timePerSession;
  String get timePerSession => _timePerSession ?? '';
  bool hasTimePerSession() => _timePerSession != null;

  // "safety_level" field.
  String? _safetyLevel;
  String get safetyLevel => _safetyLevel ?? '';
  bool hasSafetyLevel() => _safetyLevel != null;

  void _initializeFields() {
    _skillName = snapshotData['skill_name'] as String?;
    _skillIcon = snapshotData['skill_icon'] as String?;
    _childRef = snapshotData['child_ref'] as DocumentReference?;
    _milestones = getStructList<SkillMilestoneStruct>(
      snapshotData['milestones'],
      SkillMilestoneStruct.fromMap,
    );
    _totalMilestones = castToType<int>(snapshotData['total_milestones']);
    _completedMilestones = castToType<int>(snapshotData['completed_milestones']);
    _totalSubMilestones = castToType<int>(snapshotData['total_sub_milestones']);
    _completedSubMilestones = castToType<int>(snapshotData['completed_sub_milestones']);
    _progressPercentage = castToType<double>(snapshotData['progress_percentage']);
    _startedDate = snapshotData['started_date'] as DateTime?;
    _lastUpdated = snapshotData['last_updated'] as DateTime?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _expertSource = snapshotData['expert_source'] as String?;
    _generationGoal = snapshotData['generation_goal'] as String?;
    _toolsAvailable = getDataList(snapshotData['tools_available']);
    _timePerSession = snapshotData['time_per_session'] as String?;
    _safetyLevel = snapshotData['safety_level'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('skill_paths');

  static Stream<SkillPathRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SkillPathRecord.fromSnapshot(s));

  static Future<SkillPathRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SkillPathRecord.fromSnapshot(s));

  static SkillPathRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SkillPathRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SkillPathRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SkillPathRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SkillPathRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SkillPathRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSkillPathRecordData({
  String? skillName,
  String? skillIcon,
  DocumentReference? childRef,
  int? totalMilestones,
  int? completedMilestones,
  int? totalSubMilestones,
  int? completedSubMilestones,
  double? progressPercentage,
  DateTime? startedDate,
  DateTime? lastUpdated,
  DocumentReference? userRef,
  String? expertSource,
  String? generationGoal,
  String? timePerSession,
  String? safetyLevel,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'skill_name': skillName,
      'skill_icon': skillIcon,
      'child_ref': childRef,
      'total_milestones': totalMilestones,
      'completed_milestones': completedMilestones,
      'total_sub_milestones': totalSubMilestones,
      'completed_sub_milestones': completedSubMilestones,
      'progress_percentage': progressPercentage,
      'started_date': startedDate,
      'last_updated': lastUpdated,
      'user_ref': userRef,
      'expert_source': expertSource,
      'generation_goal': generationGoal,
      'time_per_session': timePerSession,
      'safety_level': safetyLevel,
    }.withoutNulls,
  );

  return firestoreData;
}

class SkillPathRecordDocumentEquality implements Equality<SkillPathRecord> {
  const SkillPathRecordDocumentEquality();

  @override
  bool equals(SkillPathRecord? e1, SkillPathRecord? e2) {
    const listEquality = ListEquality();
    return e1?.skillName == e2?.skillName &&
        e1?.skillIcon == e2?.skillIcon &&
        e1?.childRef == e2?.childRef &&
        listEquality.equals(e1?.milestones, e2?.milestones) &&
        e1?.totalMilestones == e2?.totalMilestones &&
        e1?.completedMilestones == e2?.completedMilestones &&
        e1?.totalSubMilestones == e2?.totalSubMilestones &&
        e1?.completedSubMilestones == e2?.completedSubMilestones &&
        e1?.progressPercentage == e2?.progressPercentage &&
        e1?.startedDate == e2?.startedDate &&
        e1?.lastUpdated == e2?.lastUpdated &&
        e1?.userRef == e2?.userRef &&
        e1?.expertSource == e2?.expertSource &&
        e1?.generationGoal == e2?.generationGoal &&
        listEquality.equals(e1?.toolsAvailable, e2?.toolsAvailable) &&
        e1?.timePerSession == e2?.timePerSession &&
        e1?.safetyLevel == e2?.safetyLevel;
  }

  @override
  int hash(SkillPathRecord? e) => const ListEquality().hash([
        e?.skillName,
        e?.skillIcon,
        e?.childRef,
        e?.milestones,
        e?.totalMilestones,
        e?.completedMilestones,
        e?.totalSubMilestones,
        e?.completedSubMilestones,
        e?.progressPercentage,
        e?.startedDate,
        e?.lastUpdated,
        e?.userRef,
        e?.expertSource,
        e?.generationGoal,
        e?.toolsAvailable,
        e?.timePerSession,
        e?.safetyLevel
      ]);

  @override
  bool isValidKey(Object? o) => o is SkillPathRecord;
}

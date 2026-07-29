import 'dart:async';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RoutinesRecord extends FirestoreRecord {
  RoutinesRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "description" field — optional short note about the routine.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "emoji" field.
  String? _emoji;
  String get emoji => _emoji ?? '📋';
  bool hasEmoji() => _emoji != null;

  // "steps" field — ordered list of step descriptions.
  List<String>? _steps;
  List<String> get steps => _steps ?? const [];
  bool hasSteps() => _steps != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "step_completions" field — list of booleans matching steps indices.
  List<bool>? _stepCompletions;
  List<bool> get stepCompletions => _stepCompletions ?? const [];
  bool hasStepCompletions() => _stepCompletions != null;

  // "last_completed_date" field — YYYY-MM-DD string for midnight reset.
  String? _lastCompletedDate;
  String get lastCompletedDate => _lastCompletedDate ?? '';
  bool hasLastCompletedDate() => _lastCompletedDate != null;

  // "shared_with_followers" field — creator-only toggle; when true the
  // routine is visible to anyone with the creator's active code.
  bool? _sharedWithFollowers;
  bool get sharedWithFollowers => _sharedWithFollowers ?? false;
  bool hasSharedWithFollowers() => _sharedWithFollowers != null;

  // "recur_days" field — weekdays this routine repeats on (1=Mon..7=Sun).
  // Non-empty => scheduled recurrence; empty => shows every day (legacy).
  List<int>? _recurDays;
  List<int> get recurDays => _recurDays ?? const [];
  bool hasRecurDays() => _recurDays != null && _recurDays!.isNotEmpty;

  // "recur_interval_weeks" field — repeat every N weeks (default 1).
  int? _recurIntervalWeeks;
  int get recurIntervalWeeks => _recurIntervalWeeks ?? 1;
  bool hasRecurIntervalWeeks() => _recurIntervalWeeks != null;

  // "recur_anchor" field — YYYY-MM-DD anchor for the every-N-weeks math.
  String? _recurAnchor;
  String get recurAnchor => _recurAnchor ?? '';
  bool hasRecurAnchor() => _recurAnchor != null;

  // Person assignment (mirrors todos).
  bool? _assignedToMom;
  bool get assignedToMom => _assignedToMom ?? false;
  bool hasAssignedToMom() => _assignedToMom != null;

  bool? _assignedToDad;
  bool get assignedToDad => _assignedToDad ?? false;
  bool hasAssignedToDad() => _assignedToDad != null;

  List<DocumentReference>? _selectedChildren;
  List<DocumentReference> get selectedChildren => _selectedChildren ?? const [];
  bool hasSelectedChildren() =>
      _selectedChildren != null && _selectedChildren!.isNotEmpty;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _description = snapshotData['description'] as String?;
    _emoji = snapshotData['emoji'] as String?;
    _steps = getDataList(snapshotData['steps']);
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _stepCompletions = (snapshotData['step_completions'] as List?)
        ?.map((e) => e as bool)
        .toList();
    _lastCompletedDate = snapshotData['last_completed_date'] as String?;
    _sharedWithFollowers = snapshotData['shared_with_followers'] as bool?;
    _recurDays = (snapshotData['recur_days'] as List?)
        ?.map((e) => castToType<int>(e))
        .whereType<int>()
        .toList();
    _recurIntervalWeeks = castToType<int>(snapshotData['recur_interval_weeks']);
    _recurAnchor = snapshotData['recur_anchor'] as String?;
    _assignedToMom = snapshotData['assigned_to_mom'] as bool?;
    _assignedToDad = snapshotData['assigned_to_dad'] as bool?;
    _selectedChildren = getDataList(snapshotData['selected_children']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('routines');

  static Stream<RoutinesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RoutinesRecord.fromSnapshot(s));

  static Future<RoutinesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RoutinesRecord.fromSnapshot(s));

  static RoutinesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RoutinesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RoutinesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RoutinesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RoutinesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RoutinesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRoutinesRecordData({
  String? name,
  String? description,
  String? emoji,
  List<String>? steps,
  DocumentReference? userRef,
  DateTime? createdAt,
  List<bool>? stepCompletions,
  String? lastCompletedDate,
  bool? sharedWithFollowers,
  List<int>? recurDays,
  int? recurIntervalWeeks,
  String? recurAnchor,
  bool? assignedToMom,
  bool? assignedToDad,
  List<DocumentReference>? selectedChildren,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'description': description,
      'emoji': emoji,
      'steps': steps,
      'user_ref': userRef,
      'created_at': createdAt,
      'step_completions': stepCompletions,
      'last_completed_date': lastCompletedDate,
      'shared_with_followers': sharedWithFollowers,
      'recur_days': recurDays,
      'recur_interval_weeks': recurIntervalWeeks,
      'recur_anchor': recurAnchor,
      'assigned_to_mom': assignedToMom,
      'assigned_to_dad': assignedToDad,
      'selected_children': selectedChildren,
    }.withoutNulls,
  );

  return firestoreData;
}

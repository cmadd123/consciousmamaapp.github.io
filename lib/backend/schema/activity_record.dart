import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Activity Record - Clean schema for activity data
///
/// Core fields: title, description, location, energy, things_needed,
///              activity_safety_concerns, time_duration
///
/// Child/parent context: readiness_level, age_floor, parent_proximity,
///                       setup_time, cleanup_difficulty, supervision_needed
///
/// Bubble scores (1-10): bubble_calm, bubble_need_to_move, bubble_learning,
///                       bubble_creative, bubble_independent, bubble_connection,
///                       bubble_outdoor, bubble_minimal_setup, bubble_sensory,
///                       bubble_brain_busy
class ActivityRecord extends FirestoreRecord {
  ActivityRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // ============ CORE FIELDS ============

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "location" field - "indoor" or "outdoor"
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

  // "activity_safety_concerns" field
  String? _activitySafetyConcerns;
  String get activitySafetyConcerns => _activitySafetyConcerns ?? '';
  bool hasActivitySafetyConcerns() => _activitySafetyConcerns != null;

  // "time_duration" field - e.g. "10 minutes", "15 minutes"
  String? _timeDuration;
  String get timeDuration => _timeDuration ?? '';
  bool hasTimeDuration() => _timeDuration != null;

  // ============ CHILD/PARENT CONTEXT ============

  // "readiness_level" field - child's developmental stage
  String? _readinessLevel;
  String get readinessLevel => _readinessLevel ?? '';
  bool hasReadinessLevel() => _readinessLevel != null;

  // "age_floor" field - minimum age in months
  int? _ageFloor;
  int get ageFloor => _ageFloor ?? 0;
  bool hasAgeFloor() => _ageFloor != null;

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

  // "supervision_needed" field
  bool? _supervisionNeeded;
  bool get supervisionNeeded => _supervisionNeeded ?? true;
  bool hasSupervisionNeeded() => _supervisionNeeded != null;

  // "category" field - situation category (sibling, transition, energy, etc.)
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // ============ BUBBLE SCORES (1-10) ============

  // "bubble_calm" field
  int? _bubbleCalm;
  int get bubbleCalm => _bubbleCalm ?? 0;
  bool hasBubbleCalm() => _bubbleCalm != null;

  // "bubble_need_to_move" field
  int? _bubbleNeedToMove;
  int get bubbleNeedToMove => _bubbleNeedToMove ?? 0;
  bool hasBubbleNeedToMove() => _bubbleNeedToMove != null;

  // "bubble_learning" field
  int? _bubbleLearning;
  int get bubbleLearning => _bubbleLearning ?? 0;
  bool hasBubbleLearning() => _bubbleLearning != null;

  // "bubble_creative" field
  int? _bubbleCreative;
  int get bubbleCreative => _bubbleCreative ?? 0;
  bool hasBubbleCreative() => _bubbleCreative != null;

  // "bubble_independent" field
  int? _bubbleIndependent;
  int get bubbleIndependent => _bubbleIndependent ?? 0;
  bool hasBubbleIndependent() => _bubbleIndependent != null;

  // "bubble_connection" field
  int? _bubbleConnection;
  int get bubbleConnection => _bubbleConnection ?? 0;
  bool hasBubbleConnection() => _bubbleConnection != null;

  // "bubble_outdoor" field
  int? _bubbleOutdoor;
  int get bubbleOutdoor => _bubbleOutdoor ?? 0;
  bool hasBubbleOutdoor() => _bubbleOutdoor != null;

  // "bubble_minimal_setup" field
  int? _bubbleMinimalSetup;
  int get bubbleMinimalSetup => _bubbleMinimalSetup ?? 0;
  bool hasBubbleMinimalSetup() => _bubbleMinimalSetup != null;

  // "bubble_sensory" field
  int? _bubbleSensory;
  int get bubbleSensory => _bubbleSensory ?? 0;
  bool hasBubbleSensory() => _bubbleSensory != null;

  // "bubble_brain_busy" field
  int? _bubbleBrainBusy;
  int get bubbleBrainBusy => _bubbleBrainBusy ?? 0;
  bool hasBubbleBrainBusy() => _bubbleBrainBusy != null;

  void _initializeFields() {
    // Core fields - check both lowercase and capitalized versions for compatibility
    _title = snapshotData['title'] as String? ?? snapshotData['Title'] as String?;
    _description = snapshotData['description'] as String? ?? snapshotData['Description'] as String?;
    _location = snapshotData['location'] as String? ?? snapshotData['Location'] as String?;
    _energy = snapshotData['energy'] as String? ?? snapshotData['Energy'] as String?;
    _thingsNeeded = snapshotData['things_needed'] as String? ?? snapshotData['Things_needed'] as String? ?? snapshotData['ThingsNeeded'] as String?;
    _activitySafetyConcerns = snapshotData['activity_safety_concerns'] as String? ?? snapshotData['Activity_safety_concerns'] as String? ?? snapshotData['ActivitySafetyConcerns'] as String?;
    _timeDuration = snapshotData['time_duration'] as String? ?? snapshotData['Time_duration'] as String? ?? snapshotData['TimeDuration'] as String?;

    // Child/parent context - check multiple naming conventions
    _readinessLevel = snapshotData['readiness_level'] as String? ?? snapshotData['Readiness_level'] as String?;
    _ageFloor = castToType<int>(snapshotData['age_floor']) ?? castToType<int>(snapshotData['Age_floor']);
    _parentProximity = snapshotData['parent_proximity'] as String? ?? snapshotData['Parent_proximity'] as String?;
    _setupTime = snapshotData['setup_time'] as String? ?? snapshotData['Setup_time'] as String?;
    _cleanupDifficulty = snapshotData['cleanup_difficulty'] as String? ?? snapshotData['Cleanup_difficulty'] as String?;
    _supervisionNeeded = snapshotData['supervision_needed'] as bool? ?? snapshotData['Supervision_needed'] as bool?;
    _category = snapshotData['category'] as String? ?? snapshotData['Category'] as String?;

    // Bubble scores - check multiple naming conventions
    _bubbleCalm = castToType<int>(snapshotData['bubble_calm']) ?? castToType<int>(snapshotData['Bubble_calm']);
    _bubbleNeedToMove = castToType<int>(snapshotData['bubble_need_to_move']) ?? castToType<int>(snapshotData['Bubble_need_to_move']);
    _bubbleLearning = castToType<int>(snapshotData['bubble_learning']) ?? castToType<int>(snapshotData['Bubble_learning']);
    _bubbleCreative = castToType<int>(snapshotData['bubble_creative']) ?? castToType<int>(snapshotData['Bubble_creative']);
    _bubbleIndependent = castToType<int>(snapshotData['bubble_independent']) ?? castToType<int>(snapshotData['Bubble_independent']);
    _bubbleConnection = castToType<int>(snapshotData['bubble_connection']) ?? castToType<int>(snapshotData['Bubble_connection']);
    _bubbleOutdoor = castToType<int>(snapshotData['bubble_outdoor']) ?? castToType<int>(snapshotData['Bubble_outdoor']);
    _bubbleMinimalSetup = castToType<int>(snapshotData['bubble_minimal_setup']) ?? castToType<int>(snapshotData['Bubble_minimal_setup']);
    _bubbleSensory = castToType<int>(snapshotData['bubble_sensory']) ?? castToType<int>(snapshotData['Bubble_sensory']);
    _bubbleBrainBusy = castToType<int>(snapshotData['bubble_brain_busy']) ?? castToType<int>(snapshotData['Bubble_brain_busy']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('activity');

  static Stream<ActivityRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ActivityRecord.fromSnapshot(s));

  static Future<ActivityRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ActivityRecord.fromSnapshot(s));

  static ActivityRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ActivityRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ActivityRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ActivityRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ActivityRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ActivityRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createActivityRecordData({
  String? title,
  String? description,
  String? location,
  String? energy,
  String? thingsNeeded,
  String? activitySafetyConcerns,
  String? timeDuration,
  String? readinessLevel,
  int? ageFloor,
  String? parentProximity,
  String? setupTime,
  String? cleanupDifficulty,
  bool? supervisionNeeded,
  String? category,
  int? bubbleCalm,
  int? bubbleNeedToMove,
  int? bubbleLearning,
  int? bubbleCreative,
  int? bubbleIndependent,
  int? bubbleConnection,
  int? bubbleOutdoor,
  int? bubbleMinimalSetup,
  int? bubbleSensory,
  int? bubbleBrainBusy,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'description': description,
      'location': location,
      'energy': energy,
      'things_needed': thingsNeeded,
      'activity_safety_concerns': activitySafetyConcerns,
      'time_duration': timeDuration,
      'readiness_level': readinessLevel,
      'age_floor': ageFloor,
      'parent_proximity': parentProximity,
      'setup_time': setupTime,
      'cleanup_difficulty': cleanupDifficulty,
      'supervision_needed': supervisionNeeded,
      'category': category,
      'bubble_calm': bubbleCalm,
      'bubble_need_to_move': bubbleNeedToMove,
      'bubble_learning': bubbleLearning,
      'bubble_creative': bubbleCreative,
      'bubble_independent': bubbleIndependent,
      'bubble_connection': bubbleConnection,
      'bubble_outdoor': bubbleOutdoor,
      'bubble_minimal_setup': bubbleMinimalSetup,
      'bubble_sensory': bubbleSensory,
      'bubble_brain_busy': bubbleBrainBusy,
    }.withoutNulls,
  );

  return firestoreData;
}

class ActivityRecordDocumentEquality implements Equality<ActivityRecord> {
  const ActivityRecordDocumentEquality();

  @override
  bool equals(ActivityRecord? e1, ActivityRecord? e2) {
    return e1?.title == e2?.title &&
        e1?.description == e2?.description &&
        e1?.location == e2?.location &&
        e1?.energy == e2?.energy &&
        e1?.thingsNeeded == e2?.thingsNeeded &&
        e1?.activitySafetyConcerns == e2?.activitySafetyConcerns &&
        e1?.timeDuration == e2?.timeDuration &&
        e1?.readinessLevel == e2?.readinessLevel &&
        e1?.ageFloor == e2?.ageFloor &&
        e1?.parentProximity == e2?.parentProximity &&
        e1?.setupTime == e2?.setupTime &&
        e1?.cleanupDifficulty == e2?.cleanupDifficulty &&
        e1?.supervisionNeeded == e2?.supervisionNeeded &&
        e1?.bubbleCalm == e2?.bubbleCalm &&
        e1?.bubbleNeedToMove == e2?.bubbleNeedToMove &&
        e1?.bubbleLearning == e2?.bubbleLearning &&
        e1?.bubbleCreative == e2?.bubbleCreative &&
        e1?.bubbleIndependent == e2?.bubbleIndependent &&
        e1?.bubbleConnection == e2?.bubbleConnection &&
        e1?.bubbleOutdoor == e2?.bubbleOutdoor &&
        e1?.bubbleMinimalSetup == e2?.bubbleMinimalSetup &&
        e1?.bubbleSensory == e2?.bubbleSensory &&
        e1?.bubbleBrainBusy == e2?.bubbleBrainBusy;
  }

  @override
  int hash(ActivityRecord? e) => const ListEquality().hash([
        e?.title,
        e?.description,
        e?.location,
        e?.energy,
        e?.thingsNeeded,
        e?.activitySafetyConcerns,
        e?.timeDuration,
        e?.readinessLevel,
        e?.ageFloor,
        e?.parentProximity,
        e?.setupTime,
        e?.cleanupDifficulty,
        e?.supervisionNeeded,
        e?.bubbleCalm,
        e?.bubbleNeedToMove,
        e?.bubbleLearning,
        e?.bubbleCreative,
        e?.bubbleIndependent,
        e?.bubbleConnection,
        e?.bubbleOutdoor,
        e?.bubbleMinimalSetup,
        e?.bubbleSensory,
        e?.bubbleBrainBusy,
      ]);

  @override
  bool isValidKey(Object? o) => o is ActivityRecord;
}

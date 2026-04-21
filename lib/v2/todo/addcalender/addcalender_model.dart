import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/components/parent_circle_widget.dart';
import '/index.dart';
import 'addcalender_widget.dart' show AddcalenderWidget;
import 'package:flutter/material.dart';

class AddcalenderModel extends FlutterFlowModel<AddcalenderWidget> {
  ///  Local state fields for this page.

  String selectedType = 'Event';
  DateTime? selectedDate;
  DateTime? endDate; // For multi-day events
  bool isDateSelected = false;
  bool isEndDateSelected = false;
  bool showDateError = false;
  String? recurringPattern = 'None';
  int? repeatCount; // How many times to repeat (for recurring events)
  Set<int> customWeeklyDays = {}; // Days of week (1=Mon, 2=Tue, ..., 7=Sun) for Custom Weekly
  List<ChildernRecord>? userChildren;
  DocumentReference? selectedChild;
  // Support for multiple children selection
  Set<DocumentReference> selectedChildren = {};
  bool assignToMom = false;
  bool assignToDad = false;

  // Parent display info (loaded from current user)
  ParentDisplayInfo parentInfo = ParentDisplayInfo.defaults();

  // Store the editing record for Activity type to display read-only details
  EventAndTaskRecord? editingRecord;

  // Duplicate prevention: processing flag to prevent double-tap submissions
  bool isSubmitting = false;

  // Loading animation state
  bool isCreating = false;
  int creatingProgress = 0;
  int creatingTotal = 0;
  bool showLoadingCard = false;
  bool cardExpanded = false;
  DateTime? creationStartTime; // Track when creation started

  // Delete animation state
  bool isDeleting = false;
  int deletingProgress = 0;
  int deletingTotal = 0;

  // Update all recurring events checkbox (only visible when editing recurring event)
  bool updateAllRecurring = false;

  // Recurring duration mode: false = use count, true = use end date
  bool useEndDate = false;
  DateTime? recurringEndDate; // Only used when useEndDate = true

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();

  // Text controllers
  TextEditingController? nameController;
  FocusNode? nameFocusNode;

  TextEditingController? descriptionController;
  FocusNode? descriptionFocusNode;

  // Recurring dropdown controller
  FormFieldController<String>? recurringController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nameController?.dispose();
    nameFocusNode?.dispose();
    descriptionController?.dispose();
    descriptionFocusNode?.dispose();
  }
}

import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'skill_config_loader.dart';

class CreateSkillPathModel extends FlutterFlowModel {
  // Skill selection
  List<SkillOption> availableSkills = [];
  SkillOption? selectedSkill;

  // Configuration
  Map<String, dynamic> skillConfig = {};
  List<Map<String, dynamic>> creationSteps = [];
  int currentStepIndex = 0;

  // User choices collected during creation flow
  Map<String, dynamic> userChoices = {};

  // Loading states
  bool isLoadingConfig = false;
  bool isGenerating = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}

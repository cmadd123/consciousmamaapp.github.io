import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/generate_skill_curriculum.dart';
import '/components/debug_overlay_widget.dart';
import 'skill_config_loader.dart';
import 'create_skill_path_model.dart';
export 'create_skill_path_model.dart';

class CreateSkillPathWidget extends StatefulWidget {
  const CreateSkillPathWidget({super.key});

  @override
  State<CreateSkillPathWidget> createState() => _CreateSkillPathWidgetState();
}

class _CreateSkillPathWidgetState extends State<CreateSkillPathWidget> {
  late CreateSkillPathModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Debug state
  Map<String, dynamic> _debugData = {};
  bool _showDebugOverlay = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateSkillPathModel());
    _loadAvailableSkills();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableSkills() async {
    final skills = await SkillConfigLoader.getAvailableSkills();
    if (!mounted) return;
    setState(() {
      _model.availableSkills = skills;
    });
  }

  Future<void> _selectSkill(SkillOption skill) async {
    setState(() {
      _model.selectedSkill = skill;
      _model.isLoadingConfig = true;
    });

    try {
      final config = await SkillConfigLoader.loadSkillConfig(skill.key);
      if (!mounted) return;
      setState(() {
        _model.skillConfig = config;
        _model.creationSteps = (config['creation_steps'] as List)
            .map((step) => step as Map<String, dynamic>)
            .toList();
        _model.currentStepIndex = 0;
        _model.isLoadingConfig = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _model.isLoadingConfig = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading skill: $e')),
      );
    }
  }

  void _nextStep() {
    if (_model.currentStepIndex < _model.creationSteps.length - 1) {
      setState(() {
        _model.currentStepIndex++;
      });
    } else {
      // Final step - generate curriculum
      _generateCurriculum();
    }
  }

  void _previousStep() {
    if (_model.currentStepIndex > 0) {
      setState(() {
        _model.currentStepIndex--;
      });
    } else {
      // Go back to skill selection
      setState(() {
        _model.selectedSkill = null;
        _model.creationSteps = [];
        _model.userChoices.clear();
      });
    }
  }

  Future<void> _generateCurriculum() async {
    if (_model.selectedSkill == null) return;

    setState(() {
      _model.isGenerating = true;
      _showDebugOverlay = true;
      _debugData = {
        'status': 'Starting generation...',
        'skill_key': _model.selectedSkill!.key,
        'timestamp': DateTime.now().toIso8601String(),
      };
    });

    try {
      // Load expert template for RAG context
      setState(() {
        _debugData['status'] = 'Loading expert template...';
      });

      final expertTemplate = await rootBundle.loadString(
        'assets/skill_templates/${_model.selectedSkill!.key}_expert_template.json',
      );
      final expertTemplateMap = jsonDecode(expertTemplate) as Map<String, dynamic>;

      setState(() {
        _debugData['status'] = 'Expert template loaded';
        _debugData['template_loaded'] = true;
        _debugData['user_choices'] = _model.userChoices;
      });

      // Call AI curriculum generator
      setState(() {
        _debugData['status'] = 'Calling OpenAI API...';
      });

      final skillPathRef = await generateSkillCurriculum(
        _model.selectedSkill!.key,
        _model.userChoices,
        expertTemplateMap,
      );

      if (!mounted) return;

      if (skillPathRef != null) {
        setState(() {
          _debugData['status'] = 'SUCCESS';
          _debugData['skill_path_created'] = true;
          _debugData['firestore_ref'] = skillPathRef.id;
        });

        // Success! Navigate back to skills home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Skill path created successfully!'),
            backgroundColor: Color(0xFF6EC6CA),
          ),
        );

        // Wait a moment so user can see success in debug overlay
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        context.pop();
      } else {
        // Error generating
        setState(() {
          _model.isGenerating = false;
          _debugData['status'] = 'FAILED - API returned null';
          _debugData['error'] = 'generateSkillCurriculum returned null (check Firebase Remote Config for openai_api_key)';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate curriculum. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      if (!mounted) return;

      setState(() {
        _model.isGenerating = false;
        _debugData['status'] = 'ERROR';
        _debugData['error_message'] = e.toString();
        _debugData['stack_trace'] = stackTrace.toString().split('\n').take(5).join('\n');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFFAF7F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5D4E60)),
          onPressed: () {
            // If on skill selection page, go back to skills home
            if (_model.selectedSkill == null) {
              context.pop();
            } else {
              // Otherwise, go to previous step in creation flow
              _previousStep();
            }
          },
        ),
        title: Text(
          _model.selectedSkill == null
              ? 'Choose a Skill'
              : 'Create ${_model.selectedSkill!.name} Path',
          style: const TextStyle(
            fontFamily: 'Andika New Basic',
            color: Color(0xFF5D4E60),
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Debug toggle button
          IconButton(
            icon: Icon(
              Icons.bug_report,
              color: _showDebugOverlay ? Colors.amberAccent : const Color(0xFF9B8A9E),
            ),
            onPressed: () {
              setState(() {
                _showDebugOverlay = !_showDebugOverlay;
                if (_showDebugOverlay && _debugData.isEmpty) {
                  _debugData = {
                    'status': 'Debug mode enabled',
                    'timestamp': DateTime.now().toIso8601String(),
                  };
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          _model.isLoadingConfig
              ? const Center(child: CircularProgressIndicator())
              : _model.selectedSkill == null
                  ? _buildSkillPicker()
                  : _buildCreationFlow(),

          // Debug overlay
          DebugOverlayWidget(
            title: 'Skill Generation Debug',
            debugData: _debugData,
            isVisible: _showDebugOverlay,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillPicker() {
    if (_model.availableSkills.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        const Text(
          'What skill would you like to learn?',
          style: TextStyle(
            fontFamily: 'Andika New Basic',
            color: Color(0xFF5D4E60),
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24.0),
        ..._model.availableSkills.map((skill) => _buildSkillCard(skill)),
      ],
    );
  }

  Widget _buildSkillCard(SkillOption skill) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _selectSkill(skill),
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: const Color(0xFF9B8A9E),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                skill.icon,
                style: const TextStyle(fontSize: 48.0),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  skill.name,
                  style: const TextStyle(
                    fontFamily: 'Andika New Basic',
                    color: Color(0xFF5D4E60),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF9B8A9E),
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreationFlow() {
    if (_model.creationSteps.isEmpty) {
      return const Center(child: Text('No creation steps configured'));
    }

    final currentStep = _model.creationSteps[_model.currentStepIndex];

    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: List.generate(
              _model.creationSteps.length,
              (index) => Expanded(
                child: Container(
                  height: 4.0,
                  margin: EdgeInsets.only(
                    right: index < _model.creationSteps.length - 1 ? 8.0 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: index <= _model.currentStepIndex
                        ? const Color(0xFF6EC6CA)
                        : const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Step content
        Expanded(
          child: _model.isGenerating
              ? _buildGeneratingView()
              : _buildStepContent(currentStep),
        ),

        // Navigation buttons
        if (!_model.isGenerating)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                if (_model.currentStepIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        side: const BorderSide(
                          color: Color(0xFF9B8A9E),
                          width: 2.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontFamily: 'Andika New Basic',
                          color: Color(0xFF5D4E60),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (_model.currentStepIndex > 0) const SizedBox(width: 12.0),
                Expanded(
                  flex: _model.currentStepIndex > 0 ? 1 : 1,
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _nextStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6EC6CA),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _model.currentStepIndex == _model.creationSteps.length - 1
                          ? 'Generate Curriculum'
                          : 'Next',
                      style: const TextStyle(
                        fontFamily: 'Andika New Basic',
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStepContent(Map<String, dynamic> step) {
    final stepNumber = step['step_number'] as int;
    final stepTitle = step['step_title'] as String;
    final question = step['question'] as String;
    final inputType = step['input_type'] as String;

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text(
          'Step $stepNumber of ${_model.creationSteps.length}',
          style: const TextStyle(
            fontFamily: 'Andika New Basic',
            color: Color(0xFF9B8A9E),
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          stepTitle,
          style: const TextStyle(
            fontFamily: 'Andika New Basic',
            color: Color(0xFF5D4E60),
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          question,
          style: const TextStyle(
            fontFamily: 'Andika New Basic',
            color: Color(0xFF5D4E60),
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 24.0),

        // Render input based on type
        if (inputType == 'single_choice')
          _buildSingleChoiceOptions(step)
        else if (inputType == 'multiple_choice')
          _buildMultipleChoiceOptions(step)
        else if (inputType == 'combo')
          _buildComboInputs(step)
        else
          Text('Unsupported input type: $inputType'),
      ],
    );
  }

  Widget _buildSingleChoiceOptions(Map<String, dynamic> step) {
    final options = step['options'] as List;
    final stepKey = 'step_${step['step_number']}';

    return Column(
      children: options.map((option) {
        final optionMap = option as Map<String, dynamic>;
        final label = optionMap['label'] as String;
        final description = optionMap['description'] as String;
        final isSelected = _model.userChoices[stepKey] == label;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () {
              setState(() {
                _model.userChoices[stepKey] = label;
                // Store full option data for RAG context
                _model.userChoices['${stepKey}_full'] = optionMap;
              });
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6EC6CA).withValues(alpha: 0.1) : Colors.white,
                border: Border.all(
                  color: isSelected ? const Color(0xFF6EC6CA) : const Color(0xFFE0E0E0),
                  width: isSelected ? 2.0 : 1.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? const Color(0xFF6EC6CA) : const Color(0xFF9B8A9E),
                    size: 24.0,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Andika New Basic',
                            color: const Color(0xFF5D4E60),
                            fontSize: 16.0,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          description,
                          style: const TextStyle(
                            fontFamily: 'Andika New Basic',
                            color: Color(0xFF9B8A9E),
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceOptions(Map<String, dynamic> step) {
    final options = step['options'] as List;
    final stepKey = 'step_${step['step_number']}';
    final selectedOptions = _model.userChoices[stepKey] as List<String>? ?? [];

    return Column(
      children: options.map((option) {
        final optionMap = option as Map<String, dynamic>;
        final label = optionMap['label'] as String;
        final description = optionMap['description'] as String;
        final isSelected = selectedOptions.contains(label);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () {
              setState(() {
                final List<String> current = List.from(selectedOptions);
                if (isSelected) {
                  current.remove(label);
                } else {
                  current.add(label);
                }
                _model.userChoices[stepKey] = current;
              });
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6EC6CA).withValues(alpha: 0.1) : Colors.white,
                border: Border.all(
                  color: isSelected ? const Color(0xFF6EC6CA) : const Color(0xFFE0E0E0),
                  width: isSelected ? 2.0 : 1.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: isSelected ? const Color(0xFF6EC6CA) : const Color(0xFF9B8A9E),
                    size: 24.0,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Andika New Basic',
                            color: const Color(0xFF5D4E60),
                            fontSize: 16.0,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          description,
                          style: const TextStyle(
                            fontFamily: 'Andika New Basic',
                            color: Color(0xFF9B8A9E),
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComboInputs(Map<String, dynamic> step) {
    final fields = step['fields'] as List;
    final stepKey = 'step_${step['step_number']}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields.map((field) {
        final fieldMap = field as Map<String, dynamic>;
        final fieldName = fieldMap['field_name'] as String;
        final label = fieldMap['label'] as String;
        final type = fieldMap['type'] as String;
        final fullFieldKey = '${stepKey}_$fieldName';

        if (type == 'slider') {
          final min = (fieldMap['min'] as num).toDouble();
          final max = (fieldMap['max'] as num).toDouble();
          final stepValue = (fieldMap['step'] as num).toDouble();
          final unit = fieldMap['unit'] as String? ?? '';
          final defaultValue = (fieldMap['default'] as num?)?.toDouble() ?? min;
          final currentValue = (_model.userChoices[fullFieldKey] as num?)?.toDouble() ?? defaultValue;

          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Andika New Basic',
                    color: Color(0xFF5D4E60),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: currentValue,
                        min: min,
                        max: max,
                        divisions: ((max - min) / stepValue).round(),
                        activeColor: const Color(0xFF6EC6CA),
                        inactiveColor: const Color(0xFFE0E0E0),
                        onChanged: (value) {
                          setState(() {
                            _model.userChoices[fullFieldKey] = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6EC6CA).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: const Color(0xFF6EC6CA),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        '${currentValue.round()} ${unit == "minutes" ? "min" : unit}',
                        style: const TextStyle(
                          fontFamily: 'Andika New Basic',
                          color: Color(0xFF5D4E60),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else if (type == 'single_choice') {
          final options = fieldMap['options'] as List;
          final currentChoice = _model.userChoices[fullFieldKey] as String?;

          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Andika New Basic',
                    color: Color(0xFF5D4E60),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12.0),
                ...options.map((option) {
                  final optionMap = option as Map<String, dynamic>;
                  final optionLabel = optionMap['label'] as String;
                  final optionDesc = optionMap['description'] as String;
                  final isSelected = currentChoice == optionLabel;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _model.userChoices[fullFieldKey] = optionLabel;
                        });
                      },
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6EC6CA).withValues(alpha: 0.1) : Colors.white,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6EC6CA) : const Color(0xFFE0E0E0),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? const Color(0xFF6EC6CA) : const Color(0xFF9B8A9E),
                              size: 20.0,
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    optionLabel,
                                    style: TextStyle(
                                      fontFamily: 'Andika New Basic',
                                      color: const Color(0xFF5D4E60),
                                      fontSize: 14.0,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    optionDesc,
                                    style: const TextStyle(
                                      fontFamily: 'Andika New Basic',
                                      color: Color(0xFF9B8A9E),
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text('Unsupported combo field type: $type'),
          );
        }
      }).toList(),
    );
  }

  Widget _buildGeneratingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6EC6CA)),
          ),
          const SizedBox(height: 24.0),
          Text(
            'Generating your personalized\n${_model.selectedSkill!.name} curriculum...',
            style: const TextStyle(
              fontFamily: 'Andika New Basic',
              color: Color(0xFF5D4E60),
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12.0),
          const Text(
            'This will take about 30 seconds',
            style: TextStyle(
              fontFamily: 'Andika New Basic',
              color: Color(0xFF9B8A9E),
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    if (_model.creationSteps.isEmpty) return false;

    final currentStep = _model.creationSteps[_model.currentStepIndex];
    final stepKey = 'step_${currentStep['step_number']}';
    final inputType = currentStep['input_type'] as String;

    if (inputType == 'single_choice') {
      return _model.userChoices.containsKey(stepKey);
    } else if (inputType == 'multiple_choice') {
      final selected = _model.userChoices[stepKey] as List<String>?;
      return selected != null && selected.isNotEmpty;
    } else if (inputType == 'combo') {
      // Validate all combo fields are filled
      final fields = currentStep['fields'] as List;
      for (final field in fields) {
        final fieldMap = field as Map<String, dynamic>;
        final fieldName = fieldMap['field_name'] as String;
        final fieldType = fieldMap['type'] as String;
        final fullFieldKey = '${stepKey}_$fieldName';

        // Sliders auto-populate with default, so always valid
        if (fieldType == 'slider') {
          continue;
        }

        // Single choice within combo must be selected
        if (fieldType == 'single_choice') {
          if (!_model.userChoices.containsKey(fullFieldKey)) {
            return false;
          }
        }
      }
      return true;
    }

    // For other types, allow proceeding
    return true;
  }
}

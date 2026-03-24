import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v2/learning_path/loading_learn_pass/loading_learn_pass_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';

class CreateLearningPathBottomSheet extends StatefulWidget {
  const CreateLearningPathBottomSheet({
    super.key,
    this.initialChallenge,
  });

  /// Optional initial challenge text (e.g., from a milestone)
  final String? initialChallenge;

  @override
  State<CreateLearningPathBottomSheet> createState() =>
      _CreateLearningPathBottomSheetState();
}

class _CreateLearningPathBottomSheetState
    extends State<CreateLearningPathBottomSheet> {
  // Current step (0-3)
  int _currentStep = 0;

  // Step 1: Challenge description
  final TextEditingController _challengeController = TextEditingController();
  final FocusNode _challengeFocusNode = FocusNode();

  // Step 2: Selected child
  DocumentReference? _selectedChild;

  // Step 3: Frequency
  String _selectedFrequency = 'Every day';

  // Step 4: Time of day
  String _selectedTimeOfDay = 'Morning';
  String _selectedTime = '09:00 AM';

  // Loading state
  bool _isLoading = false;
  double _loadingProgress = 0.0;

  // Key to control the loading widget
  final GlobalKey<LoadingLearnPassWidgetState> _loadingKey = GlobalKey<LoadingLearnPassWidgetState>();

  // Template challenges
  final List<String> _templateChallenges = [
    'Potty training',
    'Learning to count',
    'Reading first words',
    'Learning to share',
    'Sleeping through the night',
    'Getting dressed independently',
    'Brushing teeth',
    'Managing big emotions',
    'Learning colors',
    'Tying shoelaces',
  ];

  // Frequency options
  final List<String> _frequencyOptions = [
    'Every day',
    'Every 2 days',
    'Every 3 days',
    'Every 4 days',
    'Every 5 days',
    'Every week',
  ];

  // Time of day options with icons and time ranges
  final List<Map<String, dynamic>> _timeOfDayOptions = [
    {
      'label': 'Morning',
      'icon': Icons.wb_sunny_outlined,
      'color': Color(0xFFFFB74D),
      'times': ['07:00 AM', '07:15 AM', '07:30 AM', '07:45 AM', '08:00 AM', '08:15 AM', '08:30 AM', '08:45 AM', '09:00 AM', '09:15 AM', '09:30 AM', '09:45 AM', '10:00 AM', '10:15 AM', '10:30 AM', '10:45 AM', '11:00 AM', '11:15 AM', '11:30 AM', '11:45 AM'],
      'description': '7 AM - 12 PM',
    },
    {
      'label': 'Afternoon',
      'icon': Icons.wb_cloudy_outlined,
      'color': Color(0xFF4FC3F7),
      'times': ['12:00 PM', '12:15 PM', '12:30 PM', '12:45 PM', '01:00 PM', '01:15 PM', '01:30 PM', '01:45 PM', '02:00 PM', '02:15 PM', '02:30 PM', '02:45 PM', '03:00 PM', '03:15 PM', '03:30 PM', '03:45 PM', '04:00 PM', '04:15 PM', '04:30 PM', '04:45 PM'],
      'description': '12 PM - 5 PM',
    },
    {
      'label': 'Evening',
      'icon': Icons.nights_stay_outlined,
      'color': Color(0xFF7E57C2),
      'times': ['05:00 PM', '05:15 PM', '05:30 PM', '05:45 PM', '06:00 PM', '06:15 PM', '06:30 PM', '06:45 PM', '07:00 PM', '07:15 PM', '07:30 PM', '07:45 PM', '08:00 PM', '08:15 PM', '08:30 PM', '08:45 PM'],
      'description': '5 PM - 9 PM',
    },
  ];

  @override
  void initState() {
    super.initState();
    // If an initial challenge was provided (e.g., from a milestone), set it
    if (widget.initialChallenge != null && widget.initialChallenge!.isNotEmpty) {
      _challengeController.text = widget.initialChallenge!;
    }
  }

  @override
  void dispose() {
    _challengeController.dispose();
    _challengeFocusNode.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _challengeController.text.trim().isNotEmpty;
      case 1:
        return _selectedChild != null;
      case 2:
        return _selectedFrequency.isNotEmpty;
      case 3:
        return _selectedTime.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _createLearningPath() async {
    setState(() {
      _isLoading = true;
      _loadingProgress = 0.1;
    });

    try {
      // Get child document
      final childDoc = await ChildernRecord.getDocumentOnce(_selectedChild!);

      // Call AI to build learning path (the loading widget handles its own animation)
      await actions.buildLearningPath(
        _challengeController.text,
        childDoc.birthDay,
        DateTime.now().toString(),
        currentUserReference,
        _selectedChild,
        _selectedFrequency,
        _selectedTime,
      );

      if (mounted) {
        // Signal the loading widget to complete
        _loadingKey.currentState?.completeLoading();
        FFAppState().leariningpathchashBool = true;

        // Wait a moment for the completion animation
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          // Close bottom sheet and navigate
          Navigator.of(context).pop();
          context.pushNamed(LearnPathWidget.routeName);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create learning path: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (_isLoading) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: LoadingLearnPassWidget(
              key: _loadingKey,
              title: 'Creating your learning path...',
            ),
          ),
        ),
      );
    }

    return Padding(
      // Add bottom padding for keyboard to prevent it from covering input
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header with progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                if (_currentStep > 0)
                  IconButton(
                    onPressed: _previousStep,
                    icon: Icon(Icons.arrow_back_ios, color: theme.primary),
                  )
                else
                  const SizedBox(width: 48),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Create Learning Path',
                        style: theme.titleMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildProgressIndicator(theme),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: theme.secondaryText),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStep(theme),
              ),
            ),
          ),

          // Bottom button
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              top: 12,
            ),
            child: FFButtonWidget(
              onPressed: _canProceed()
                  ? () {
                      if (_currentStep == 3) {
                        _createLearningPath();
                      } else {
                        _nextStep();
                      }
                    }
                  : null,
              text: _currentStep == 3 ? 'Create Learning Path' : 'Continue',
              options: FFButtonOptions(
                width: double.infinity,
                height: 50,
                color: _canProceed() ? theme.primary : Colors.grey[300],
                textStyle: theme.titleSmall.override(
                  fontFamily: 'Andika New Basic',
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
      ), // Close Padding widget
    );
  }

  Widget _buildProgressIndicator(FlutterFlowTheme theme) {
    return Column(
      children: [
        // Progress dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final isActive = index == _currentStep;
            final isCompleted = index < _currentStep;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive || isCompleted
                      ? theme.primary
                      : theme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        // Show selected options summary
        if (_currentStep > 0) ...[
          const SizedBox(height: 12),
          _buildSelectionsSummary(theme),
        ],
      ],
    );
  }

  // Build a summary of selections made so far
  Widget _buildSelectionsSummary(FlutterFlowTheme theme) {
    List<Widget> items = [];

    // Helper to add arrow between items
    void addArrow() {
      if (items.isNotEmpty) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 10,
              color: theme.primary.withOpacity(0.5),
            ),
          ),
        );
      }
    }

    // Step 0 completed: Challenge
    if (_currentStep > 0 && _challengeController.text.isNotEmpty) {
      String challengeText = _challengeController.text;
      // Shorten for display
      if (challengeText.startsWith('My child needs help with ')) {
        challengeText = challengeText.substring(25);
      }
      if (challengeText.length > 15) {
        challengeText = '${challengeText.substring(0, 15)}...';
      }
      items.add(_buildSummaryChip(
        theme,
        Icons.lightbulb_outline,
        challengeText,
        0,
      ));
    }

    // Step 1 completed: Child
    if (_currentStep > 1 && _selectedChild != null) {
      addArrow();
      items.add(
        StreamBuilder<ChildernRecord>(
          stream: ChildernRecord.getDocument(_selectedChild!),
          builder: (context, snapshot) {
            final childName = snapshot.data?.name ?? 'Child';
            return _buildSummaryChip(
              theme,
              Icons.child_care,
              childName,
              1,
              childColor: snapshot.data?.selectedColor,
            );
          },
        ),
      );
    }

    // Step 2 completed: Frequency
    if (_currentStep > 2 && _selectedFrequency.isNotEmpty) {
      addArrow();
      items.add(_buildSummaryChip(
        theme,
        Icons.repeat,
        _selectedFrequency,
        2,
      ));
    }

    // Step 3: Time (only if on step 3 and time selected)
    if (_currentStep >= 3 && _selectedTime.isNotEmpty) {
      addArrow();
      items.add(_buildSummaryChip(
        theme,
        Icons.schedule,
        _selectedTime,
        3,
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: items,
      ),
    );
  }

  Widget _buildSummaryChip(
    FlutterFlowTheme theme,
    IconData icon,
    String label,
    int stepIndex, {
    Color? childColor,
  }) {
    return InkWell(
      onTap: () {
        // Allow tapping to go back to that step
        setState(() => _currentStep = stepIndex);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: theme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (childColor != null)
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: childColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              Icon(
                icon,
                size: 14,
                color: theme.primary,
              ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.bodySmall.override(
                fontFamily: 'Andika New Basic',
                color: theme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(FlutterFlowTheme theme) {
    switch (_currentStep) {
      case 0:
        return _buildChallengeStep(theme);
      case 1:
        return _buildChildStep(theme);
      case 2:
        return _buildFrequencyStep(theme);
      case 3:
        return _buildTimeStep(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Challenge description
  Widget _buildChallengeStep(FlutterFlowTheme theme) {
    return Column(
      key: const ValueKey('step0'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/321.png',
                width: 60,
                height: 66,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "What would you like to work on with your child?",
                style: theme.titleMedium.override(
                  fontFamily: 'Andika New Basic',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Choose a common challenge or describe your own:',
          style: theme.bodyMedium.override(
            fontFamily: 'Andika New Basic',
            color: theme.secondaryText,
          ),
        ),
        const SizedBox(height: 12),

        // Template chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _templateChallenges.map((challenge) {
            final isSelected = _challengeController.text.contains(challenge);
            return InkWell(
              onTap: () {
                _challengeController.text = 'My child needs help with $challenge';
                setState(() {});
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primary : theme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? theme.primary : theme.primary.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  challenge,
                  style: theme.bodySmall.override(
                    fontFamily: 'Andika New Basic',
                    color: isSelected ? Colors.white : theme.primary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Text input
        Container(
          decoration: BoxDecoration(
            color: theme.prim30,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFCBE3E0)),
          ),
          child: TextFormField(
            controller: _challengeController,
            focusNode: _challengeFocusNode,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Example: My child is struggling with counting numbers',
              hintStyle: theme.bodyMedium.override(
                fontFamily: 'Andika New Basic',
                color: theme.secondaryText,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: theme.bodyMedium.override(
              fontFamily: 'Andika New Basic',
            ),
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  // Step 2: Child selector
  Widget _buildChildStep(FlutterFlowTheme theme) {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/321.png',
                width: 60,
                height: 66,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Which child is experiencing this challenge?",
                style: theme.titleMedium.override(
                  fontFamily: 'Andika New Basic',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        StreamBuilder<List<ChildernRecord>>(
          stream: queryChildernRecord(
            queryBuilder: (childernRecord) => childernRecord.where(
              'userRef',
              isEqualTo: currentUserReference,
            ),
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(color: theme.primary),
              );
            }

            final children = snapshot.data!;
            if (children.isEmpty) {
              return Center(
                child: Text(
                  'No children added yet',
                  style: theme.bodyMedium,
                ),
              );
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: children.map((child) {
                final isSelected = _selectedChild == child.reference;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedChild = child.reference);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primary.withOpacity(0.1)
                          : const Color(0x1D52A097),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? theme.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: child.selectedColor ?? theme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: child.avatar.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    child.avatar,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    child.name.isNotEmpty ? child.name[0].toUpperCase() : 'C',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          child.name.isNotEmpty ? child.name : 'Child',
                          style: theme.bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // Step 3: Frequency selector
  Widget _buildFrequencyStep(FlutterFlowTheme theme) {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/321.png',
                width: 60,
                height: 66,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "How often would you like lessons?",
                style: theme.titleMedium.override(
                  fontFamily: 'Andika New Basic',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ...List.generate(_frequencyOptions.length, (index) {
          final option = _frequencyOptions[index];
          final isSelected = _selectedFrequency == option;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() => _selectedFrequency = option),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primary.withOpacity(0.1)
                      : const Color(0x1D52A097),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? theme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        color: theme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option,
                        style: theme.bodyLarge.override(
                          fontFamily: 'Andika New Basic',
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: theme.primary),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // Step 4: Time of day selector (improved!)
  Widget _buildTimeStep(FlutterFlowTheme theme) {
    // Find current time of day option
    final currentTimeOfDayOption = _timeOfDayOptions.firstWhere(
      (opt) => opt['label'] == _selectedTimeOfDay,
      orElse: () => _timeOfDayOptions[0],
    );
    final availableTimes = currentTimeOfDayOption['times'] as List<String>;

    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/321.png',
                width: 60,
                height: 66,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "What time works best for lessons?",
                style: theme.titleMedium.override(
                  fontFamily: 'Andika New Basic',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Time of day cards
        Text(
          'Choose a time of day:',
          style: theme.bodyMedium.override(
            fontFamily: 'Andika New Basic',
            color: theme.secondaryText,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: _timeOfDayOptions.map((option) {
            final isSelected = _selectedTimeOfDay == option['label'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTimeOfDay = option['label'] as String;
                      // Auto-select first time in range
                      final times = option['times'] as List<String>;
                      _selectedTime = times[0];
                    });
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (option['color'] as Color).withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? option['color'] as Color
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          option['icon'] as IconData,
                          color: option['color'] as Color,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          option['label'] as String,
                          style: theme.bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option['description'] as String,
                          style: theme.bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: theme.secondaryText,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Specific time picker
        Text(
          'Pick a specific time:',
          style: theme.bodyMedium.override(
            fontFamily: 'Andika New Basic',
            color: theme.secondaryText,
          ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableTimes.map((time) {
            final isSelected = _selectedTime == time;
            return InkWell(
              onTap: () => setState(() => _selectedTime = time),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primary
                      : theme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? theme.primary
                        : theme.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  time,
                  style: theme.bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: isSelected ? Colors.white : theme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, color: theme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Lessons will be scheduled for $_selectedTime, $_selectedFrequency',
                  style: theme.bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: theme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

/// Helper function to show the bottom sheet
Future<void> showCreateLearningPathBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    builder: (context) => const CreateLearningPathBottomSheet(),
  );
}

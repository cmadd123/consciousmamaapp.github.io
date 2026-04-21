import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class CreateSkillPathPreviewWidget extends StatefulWidget {
  const CreateSkillPathPreviewWidget({super.key});

  @override
  State<CreateSkillPathPreviewWidget> createState() =>
      _CreateSkillPathPreviewWidgetState();
}

class _CreateSkillPathPreviewWidgetState
    extends State<CreateSkillPathPreviewWidget> {
  int _currentStep = 0;

  // Step 1
  String _selectedSkill = '';

  // Step 2
  String _selectedGoal = 'build_projects';
  bool _handToolsOnly = true;
  bool _powerToolsOk = false;
  bool _fullWorkshop = false;
  String _timePerSession = '30-60';
  String _specificFocus = '';
  String _safetyLevel = 'maximum';

  // Step 3
  String _selectedExpert = 'paul_sellers';

  // Step 4 (generation)
  bool _isGenerating = false;
  double _generationProgress = 0.0;
  String _generationStatus = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: FlutterFlowTheme.of(context).primaryText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Skill Path - Step ${_currentStep + 1} of 4',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: FFAppState().currentFontFamily,
                color: const Color(0xFF5D4E60),
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: _buildCurrentStep(),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1WhatSkill();
      case 1:
        return _buildStep2Constraints();
      case 2:
        return _buildStep3ExpertSource();
      case 3:
        return _buildStep4Generating();
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1: What Skill?
  Widget _buildStep1WhatSkill() {
    final popularSkills = [
      {'name': 'Woodworking', 'icon': '🔨'},
      {'name': 'Cooking & Baking', 'icon': '👨‍🍳'},
      {'name': 'Photography', 'icon': '📷'},
      {'name': 'Gardening', 'icon': '🌱'},
      {'name': 'Music', 'icon': '🎸'},
      {'name': 'Sewing', 'icon': '🧵'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What skill do you want your child to learn?',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: const Color(0xFF5D4E60),
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 24.0),

          // Search box
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search or type...',
                hintStyle: TextStyle(
                  fontFamily: FFAppState().currentFontFamily,
                  color: const Color(0xFF9B8A9E),
                  fontSize: 16.0,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF9B8A9E),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16.0),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedSkill = value;
                });
              },
            ),
          ),

          const SizedBox(height: 32.0),

          Text(
            'Popular Skills:',
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: const Color(0xFF5D4E60),
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16.0),

          // Popular skills grid
          ...popularSkills.map((skill) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedSkill = skill['name']!;
                });
              },
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: _selectedSkill == skill['name']
                        ? const Color(0xFF9B8A9E)
                        : Colors.transparent,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      skill['icon']!,
                      style: const TextStyle(fontSize: 32.0),
                    ),
                    const SizedBox(width: 16.0),
                    Text(
                      skill['name']!,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF5D4E60),
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    if (_selectedSkill == skill['name'])
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF9B8A9E),
                        size: 24.0,
                      ),
                  ],
                ),
              ),
            ),
          )),

          const SizedBox(height: 32.0),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedSkill.isEmpty
                  ? null
                  : () {
                      setState(() {
                        _currentStep = 1;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B8A9E),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                disabledBackgroundColor: const Color(0xFFD0C5D3),
              ),
              child: Text(
                'Continue',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: FFAppState().currentFontFamily,
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: Constraints & Goals
  Widget _buildStep2Constraints() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_selectedSkill Skill Path',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: const Color(0xFF5D4E60),
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Customize the learning experience',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: const Color(0xFF9B8A9E),
                  fontSize: 16.0,
                ),
          ),
          const SizedBox(height: 32.0),

          // Goal selection
          _buildSectionTitle('What\'s your goal?'),
          const SizedBox(height: 12.0),
          _buildRadioOption(
            'Learn the basics',
            'basics',
            _selectedGoal,
            'Beginner-friendly introduction',
            (value) => setState(() => _selectedGoal = value!),
          ),
          _buildRadioOption(
            'Build real projects',
            'build_projects',
            _selectedGoal,
            'Practical skills with tangible results',
            (value) => setState(() => _selectedGoal = value!),
          ),
          _buildRadioOption(
            'Master advanced techniques',
            'master_advanced',
            _selectedGoal,
            'Long-term skill development',
            (value) => setState(() => _selectedGoal = value!),
          ),

          const SizedBox(height: 32.0),

          // Tools available
          _buildSectionTitle('Tools available:'),
          const SizedBox(height: 12.0),
          _buildCheckboxOption(
            'Hand tools only',
            _handToolsOnly,
            'Saws, hammers, chisels - safest for beginners',
            (value) => setState(() => _handToolsOnly = value!),
          ),
          _buildCheckboxOption(
            'Power tools okay',
            _powerToolsOk,
            'Drill, sander - with supervision',
            (value) => setState(() => _powerToolsOk = value!),
          ),
          _buildCheckboxOption(
            'Full workshop access',
            _fullWorkshop,
            'All tools available',
            (value) => setState(() => _fullWorkshop = value!),
          ),

          const SizedBox(height: 32.0),

          // Time per session
          _buildSectionTitle('Time per session:'),
          const SizedBox(height: 12.0),
          _buildRadioOption(
            '15-30 min',
            '15-30',
            _timePerSession,
            'Quick projects',
            (value) => setState(() => _timePerSession = value!),
          ),
          _buildRadioOption(
            '30-60 min',
            '30-60',
            _timePerSession,
            'Standard sessions',
            (value) => setState(() => _timePerSession = value!),
          ),
          _buildRadioOption(
            '1-2 hours',
            '60-120',
            _timePerSession,
            'Deep work sessions',
            (value) => setState(() => _timePerSession = value!),
          ),

          const SizedBox(height: 32.0),

          // Specific focus (optional)
          _buildSectionTitle('Specific focus (optional):'),
          const SizedBox(height: 12.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'e.g., "furniture building" or "toys & gifts"',
                hintStyle: TextStyle(
                  fontFamily: FFAppState().currentFontFamily,
                  color: const Color(0xFF9B8A9E),
                  fontSize: 14.0,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16.0),
              ),
              onChanged: (value) {
                setState(() {
                  _specificFocus = value;
                });
              },
            ),
          ),

          const SizedBox(height: 32.0),

          // Safety level
          _buildSectionTitle('Safety level:'),
          const SizedBox(height: 12.0),
          _buildRadioOption(
            'Maximum safety',
            'maximum',
            _safetyLevel,
            'Start with safest tools',
            (value) => setState(() => _safetyLevel = value!),
          ),
          _buildRadioOption(
            'Age-appropriate',
            'age_appropriate',
            _safetyLevel,
            'Follow expert guidelines',
            (value) => setState(() => _safetyLevel = value!),
          ),

          const SizedBox(height: 32.0),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 2;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              child: Text(
                'Continue',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: FFAppState().currentFontFamily,
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: Expert Source
  Widget _buildStep3ExpertSource() {
    final experts = [
      {
        'id': 'paul_sellers',
        'name': 'Paul Sellers Method',
        'subtitle': '"Hand tool skills first, power tools later. Traditional techniques for modern hobbyists."',
        'credentials': [
          '50+ years teaching experience',
          'Kid-friendly, safety-focused',
          'Proven beginner progression',
        ],
        'recommended': true,
      },
      {
        'id': 'nbss',
        'name': 'North Bennet Street School',
        'subtitle': '"Professional furniture making curriculum adapted for home use."',
        'credentials': [
          '145-year-old trade school',
          'Comprehensive, structured approach',
          'Emphasis on precision and mastery',
        ],
        'recommended': false,
      },
      {
        'id': 'blended',
        'name': 'Blended Expert Approach',
        'subtitle': '"Combines multiple expert sources for best practices"',
        'credentials': [
          'Paul Sellers + NBSS + German Meister curriculum',
          'Safety standards from OSHA guidelines',
        ],
        'recommended': false,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose teaching approach:',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: const Color(0xFF5D4E60),
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 24.0),

          ...experts.map((expert) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedExpert = expert['id'] as String;
                });
              },
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: _selectedExpert == expert['id']
                        ? const Color(0xFF9B8A9E)
                        : Colors.transparent,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          expert['name'] as String,
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                                fontFamily: FFAppState().currentFontFamily,
                                color: const Color(0xFF5D4E60),
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (expert['recommended'] == true) ...[
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9B8A9E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Text(
                              'Recommended',
                              style: TextStyle(
                                fontFamily: FFAppState().currentFontFamily,
                                color: Color(0xFF9B8A9E),
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Radio<String>(
                          value: expert['id'] as String,
                          groupValue: _selectedExpert,
                          onChanged: (value) {
                            setState(() {
                              _selectedExpert = value!;
                            });
                          },
                          activeColor: const Color(0xFF9B8A9E),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      expert['subtitle'] as String,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF5D4E60),
                            fontSize: 14.0,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    const SizedBox(height: 16.0),
                    ...(expert['credentials'] as List<String>).map((credential) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontFamily: FFAppState().currentFontFamily,
                              color: Color(0xFF9B8A9E),
                              fontSize: 14.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              credential,
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: const Color(0xFF9B8A9E),
                                    fontSize: 14.0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          )),

          const SizedBox(height: 32.0),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 3;
                  _startGeneration();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              child: Text(
                'Generate Skill Path',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: FFAppState().currentFontFamily,
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4: Generating
  Widget _buildStep4Generating() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Creating Your Skill Path',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: const Color(0xFF5D4E60),
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40.0),

            // Animated icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 2 * 3.14159,
                  child: const Text(
                    '🔨',
                    style: TextStyle(fontSize: 80.0),
                  ),
                );
              },
            ),

            const SizedBox(height: 40.0),

            Text(
              _generationStatus,
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: const Color(0xFF5D4E60),
                    fontSize: 16.0,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24.0),

            // Progress bar
            Container(
              width: double.infinity,
              height: 8.0,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F5F3),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _generationProgress,
                child: Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16.0),

            Text(
              '${(_generationProgress * 100).toInt()}%',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: const Color(0xFF9B8A9E),
                    fontSize: 14.0,
                  ),
            ),

            const SizedBox(height: 40.0),

            Text(
              'This takes about 30 seconds',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: const Color(0xFF9B8A9E),
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widgets
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: FlutterFlowTheme.of(context).bodyLarge.override(
            fontFamily: FFAppState().currentFontFamily,
            color: const Color(0xFF5D4E60),
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildRadioOption(
    String title,
    String value,
    String groupValue,
    String description,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: groupValue == value
                  ? const Color(0xFF9B8A9E)
                  : Colors.transparent,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: const Color(0xFF9B8A9E),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF5D4E60),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      description,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF9B8A9E),
                            fontSize: 13.0,
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
  }

  Widget _buildCheckboxOption(
    String title,
    bool value,
    String description,
    Function(bool?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: value
                  ? const Color(0xFF9B8A9E)
                  : Colors.transparent,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF9B8A9E),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF5D4E60),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      description,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF9B8A9E),
                            fontSize: 13.0,
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
  }

  // Simulate generation
  void _startGeneration() {
    setState(() {
      _isGenerating = true;
      _generationProgress = 0.0;
      _generationStatus = 'Retrieving expert curriculum sources...';
    });

    // Simulate progress updates
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _generationProgress = 0.2;
          _generationStatus = 'Analyzing age-appropriate progression...';
        });
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _generationProgress = 0.4;
          _generationStatus = 'Sequencing hand tool skills...';
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _generationProgress = 0.6;
          _generationStatus = 'Generating 15 milestone lessons...';
        });
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _generationProgress = 0.8;
          _generationStatus = 'Adding safety reminders and parent tips...';
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (mounted) {
        setState(() {
          _generationProgress = 1.0;
          _generationStatus = 'Complete! 🎉';
        });

        // Map skill name to icon
        final iconMap = {
          'Woodworking': '🔨',
          'Cooking & Baking': '👨‍🍳',
          'Photography': '📷',
          'Gardening': '🌱',
          'Music': '🎸',
          'Sewing': '🧵',
        };

        // Build tools list
        final tools = <String>[];
        if (_handToolsOnly) tools.add('hand_tools');
        if (_powerToolsOk) tools.add('power_tools');
        if (_fullWorkshop) tools.add('full_workshop');

        // Save to Firestore
        try {
          final data = createSkillPathRecordData(
            skillName: _selectedSkill,
            skillIcon: iconMap[_selectedSkill] ?? '🎨',
            userRef: currentUserReference,
            expertSource: _selectedExpert,
            generationGoal: _selectedGoal,
            timePerSession: _timePerSession,
            safetyLevel: _safetyLevel,
            totalMilestones: 15,
            completedMilestones: 0,
            totalSubMilestones: 45,
            completedSubMilestones: 0,
            progressPercentage: 0.0,
            startedDate: getCurrentTimestamp,
            lastUpdated: getCurrentTimestamp,
          );

          // Add tools_available as a separate field
          data['tools_available'] = tools;

          await SkillPathRecord.collection.add(data);

          // Show success dialog after a brief pause
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _showSuccessDialog();
            }
          });
        } catch (e) {
          // Handle error
          if (mounted) {
            setState(() {
              _generationStatus = 'Error saving skill path: $e';
            });
          }
        }
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 60.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Skill Path Created!',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: FFAppState().currentFontFamily,
                      color: const Color(0xFF5D4E60),
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Text(
                '$_selectedSkill Journey\nBased on ${_getExpertName()}',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: FFAppState().currentFontFamily,
                      color: const Color(0xFF5D4E60),
                      fontSize: 16.0,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F5F3),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Text(
                      '15 Progressive Milestones',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF5D4E60),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Estimated: 3-6 months at your pace',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF9B8A9E),
                            fontSize: 13.0,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to skills home
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'Start Learning',
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getExpertName() {
    switch (_selectedExpert) {
      case 'paul_sellers':
        return 'Paul Sellers Method';
      case 'nbss':
        return 'NBSS Curriculum';
      case 'blended':
        return 'Blended Expert Approach';
      default:
        return 'Expert Curriculum';
    }
  }
}

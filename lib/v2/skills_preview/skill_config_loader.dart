import 'dart:convert';
import 'package:flutter/services.dart';

/// Loads skill configurations and expert templates for Skills & Hobbies feature
class SkillConfigLoader {
  /// Load skill configuration (creation steps) for a specific skill
  static Future<Map<String, dynamic>> loadSkillConfig(String skillKey) async {
    final jsonString = await rootBundle.loadString(
      'assets/skill_templates/skill_configurations.json',
    );
    final Map<String, dynamic> allConfigs = jsonDecode(jsonString);

    if (!allConfigs.containsKey(skillKey)) {
      throw Exception('Skill configuration not found for: $skillKey');
    }

    return allConfigs[skillKey] as Map<String, dynamic>;
  }

  /// Load expert template (RAG context) for a specific skill
  static Future<Map<String, dynamic>> loadExpertTemplate(String skillKey) async {
    final jsonString = await rootBundle.loadString(
      'assets/skill_templates/${skillKey}_expert_template.json',
    );
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Get list of available skills
  static Future<List<SkillOption>> getAvailableSkills() async {
    final jsonString = await rootBundle.loadString(
      'assets/skill_templates/skill_configurations.json',
    );
    final Map<String, dynamic> allConfigs = jsonDecode(jsonString);

    return allConfigs.entries.map((entry) {
      final config = entry.value as Map<String, dynamic>;
      return SkillOption(
        key: entry.key,
        name: config['skill_name'] as String,
        icon: config['skill_icon'] as String,
      );
    }).toList();
  }
}

/// Represents a skill option in the picker
class SkillOption {
  final String key;
  final String name;
  final String icon;

  SkillOption({
    required this.key,
    required this.name,
    required this.icon,
  });
}

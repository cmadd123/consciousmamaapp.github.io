import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Puzzle themes with their emoji/icon representations
class PuzzleTheme {
  final String id;
  final String name;
  final String emoji;
  final Color primaryColor;
  final Color backgroundColor;
  final List<String> pieceEmojis; // 9 pieces for 3x3 grid

  const PuzzleTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.primaryColor,
    required this.backgroundColor,
    required this.pieceEmojis,
  });

  static const List<PuzzleTheme> themes = [
    PuzzleTheme(
      id: 'dinosaurs',
      name: 'Dinosaurs',
      emoji: '🦕',
      primaryColor: Color(0xFF4CAF50),
      backgroundColor: Color(0xFFE8F5E9),
      pieceEmojis: ['🦕', '🦖', '🥚', '🌿', '🌋', '🦴', '🪨', '☄️', '🦎'],
    ),
    PuzzleTheme(
      id: 'animals',
      name: 'Animals',
      emoji: '🐾',
      primaryColor: Color(0xFFFF9800),
      backgroundColor: Color(0xFFFFF3E0),
      pieceEmojis: ['🦁', '🐘', '🦒', '🐵', '🦓', '🐻', '🦊', '🐰', '🐼'],
    ),
    PuzzleTheme(
      id: 'space',
      name: 'Space',
      emoji: '🚀',
      primaryColor: Color(0xFF3F51B5),
      backgroundColor: Color(0xFFE8EAF6),
      pieceEmojis: ['🚀', '🌙', '⭐', '🪐', '👨‍🚀', '🛸', '🌍', '☀️', '🌌'],
    ),
    PuzzleTheme(
      id: 'ocean',
      name: 'Ocean',
      emoji: '🐠',
      primaryColor: Color(0xFF00BCD4),
      backgroundColor: Color(0xFFE0F7FA),
      pieceEmojis: ['🐠', '🐙', '🦀', '🐬', '🐳', '🦈', '🐚', '🌊', '🪸'],
    ),
    PuzzleTheme(
      id: 'vehicles',
      name: 'Vehicles',
      emoji: '🚗',
      primaryColor: Color(0xFFF44336),
      backgroundColor: Color(0xFFFFEBEE),
      pieceEmojis: ['🚗', '🚂', '✈️', '🚁', '🚀', '🚢', '🏎️', '🚲', '🛵'],
    ),
  ];

  static PuzzleTheme getTheme(String? themeId) {
    return themes.firstWhere(
      (t) => t.id == themeId,
      orElse: () => themes.first,
    );
  }
}

/// Widget that displays puzzle progress as a 3x3 grid
class PuzzleProgressWidget extends StatelessWidget {
  final String themeId;
  final int completedTasks;
  final int totalTasks;
  final double size;
  final bool showLabel;

  const PuzzleProgressWidget({
    super.key,
    required this.themeId,
    required this.completedTasks,
    required this.totalTasks,
    this.size = 200,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PuzzleTheme.getTheme(themeId);
    final ffTheme = FlutterFlowTheme.of(context);

    // Calculate how many pieces to show (map tasks to 9 pieces)
    final piecesToShow = totalTasks > 0
        ? ((completedTasks / totalTasks) * 9).floor().clamp(0, 9)
        : 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Puzzle grid
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                final isRevealed = index < piecesToShow;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  decoration: BoxDecoration(
                    color: isRevealed
                        ? theme.primaryColor.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isRevealed
                          ? theme.primaryColor.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isRevealed ? 1.0 : 0.2,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        scale: isRevealed ? 1.0 : 0.5,
                        child: Text(
                          theme.pieceEmojis[index],
                          style: TextStyle(
                            fontSize: size / 6,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        if (showLabel) ...[
          const SizedBox(height: 12),
          // Progress label
          Text(
            '$completedTasks of $totalTasks tasks',
            style: ffTheme.bodyMedium.override(
              fontFamily: 'Andika New Basic',
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          // Progress bar
          Container(
            width: size * 0.8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: totalTasks > 0 ? completedTasks / totalTasks : 0,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact puzzle preview for cards/lists
class PuzzleProgressPreview extends StatelessWidget {
  final String themeId;
  final int completedTasks;
  final int totalTasks;
  final double size;

  const PuzzleProgressPreview({
    super.key,
    required this.themeId,
    required this.completedTasks,
    required this.totalTasks,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PuzzleTheme.getTheme(themeId);
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background progress circle
          SizedBox(
            width: size - 8,
            height: size - 8,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: theme.primaryColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(theme.primaryColor),
            ),
          ),
          // Theme emoji
          Text(
            theme.emoji,
            style: TextStyle(fontSize: size * 0.4),
          ),
        ],
      ),
    );
  }
}

/// Theme picker for selecting puzzle theme during learning path creation
class PuzzleThemePicker extends StatelessWidget {
  final String? selectedThemeId;
  final ValueChanged<String> onThemeSelected;

  const PuzzleThemePicker({
    super.key,
    this.selectedThemeId,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ffTheme = FlutterFlowTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a reward theme:',
          style: ffTheme.bodyMedium.override(
            fontFamily: 'Andika New Basic',
            color: ffTheme.secondaryText,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: PuzzleTheme.themes.map((theme) {
            final isSelected = selectedThemeId == theme.id;
            return InkWell(
              onTap: () => onThemeSelected(theme.id),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primaryColor.withOpacity(0.15)
                      : theme.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? theme.primaryColor
                        : theme.primaryColor.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      theme.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.name,
                      style: ffTheme.bodySmall.override(
                        fontFamily: 'Andika New Basic',
                        color: theme.primaryColor,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

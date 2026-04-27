import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:resume_analyzer/features/ai_assistant/domain/entities/resume_analysis.dart';

class AnalysisBulletList extends StatelessWidget {
  final List<String> items;
  final Color color;
  final String label;
  final IconData icon;

  const AnalysisBulletList({
    super.key,
    required this.items,
    required this.color,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: color, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(item,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(height: 1.4))),
                ],
              ),
            )),
      ],
    );
  }
}

class AnalysisTagCloud extends StatelessWidget {
  final List<String> tags;
  final Color color;

  const AnalysisTagCloud({super.key, required this.tags, required this.color});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map((tag) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Text(tag,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: color, fontWeight: FontWeight.w500)),
              ))
          .toList(),
    );
  }
}

class AnalysisSkillChip extends StatelessWidget {
  final SkillItem skill;
  const AnalysisSkillChip({super.key, required this.skill});

  Color get _levelColor {
    switch (skill.level.toLowerCase()) {
      case 'expert':
        return AppColors.success;
      case 'advanced':
        return AppColors.primary;
      case 'intermediate':
        return AppColors.accentGold;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _levelColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _levelColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(skill.name,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textPrimary)),
          const SizedBox(width: 6),
          Container(
              width: 4,
              height: 4,
              decoration:
                  BoxDecoration(color: _levelColor, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}

class AnalysisScoreDisplay extends StatelessWidget {
  final int score;
  final String label;
  final Color color;

  const AnalysisScoreDisplay({
    super.key,
    required this.score,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$score%',
          style: AppTheme.mono(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color, fontSize: 10, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: color.withValues(alpha: 0.1),
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

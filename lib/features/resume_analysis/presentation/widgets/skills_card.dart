import 'package:flutter/material.dart';
import 'package:resume_analyzer/core/widgets/section_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/resume_analysis.dart';

class SkillsCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const SkillsCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Skills Detected',
      icon: Icons.code_rounded,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: analysis.skills.map((s) => _SkillChip(skill: s)).toList(),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final SkillItem skill;
  const _SkillChip({required this.skill});

  Color get _levelColor {
    switch (skill.level.toLowerCase()) {
      case 'expert': return AppColors.success;
      case 'advanced': return AppColors.primary;
      case 'intermediate': return AppColors.accentGold;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _levelColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _levelColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(width: 6),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: _levelColor, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

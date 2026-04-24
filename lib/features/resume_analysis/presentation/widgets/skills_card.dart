import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/resume_analysis.dart';

class SkillsCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const SkillsCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
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
        color: _levelColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _levelColor.withValues(alpha: 0.2)),
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

class _SectionContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionContainer({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

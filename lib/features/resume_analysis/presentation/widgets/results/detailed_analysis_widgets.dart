import 'package:flutter/material.dart';
import 'package:resume_analyzer/core/theme/app_theme.dart';
import '../../../domain/entities/resume_analysis.dart';

class SectionScoresCard extends StatelessWidget {
  final List<SectionScore> scores;
  const SectionScoresCard({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: 'Section Analysis',
      icon: Icons.analytics_rounded,
      iconColor: AppColors.accentGold,
      child: Column(
        children: scores.map((s) => _ScoreItem(score: s)).toList(),
      ),
    );
  }
}

class SkillsCard extends StatelessWidget {
  final List<SkillItem> skills;
  const SkillsCard({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: 'Skills Detected',
      icon: Icons.psychology_rounded,
      iconColor: AppColors.accent,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills.map((s) => _SkillChip(skill: s)).toList(),
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final SectionScore score;
  const _ScoreItem({required this.score});

  @override
  Widget build(BuildContext context) {
    final pct = score.score / 100.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(score.section,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Text('${score.score}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                  score.score > 70 ? AppColors.primary : AppColors.accentGold),
            ),
          ),
          if (score.feedback.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(score.feedback,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textMuted, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final SkillItem skill;
  const _SkillChip({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(skill.name,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4)),
            child: Text(skill.level,
                style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _BaseCard(
      {required this.title,
      required this.icon,
      required this.iconColor,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

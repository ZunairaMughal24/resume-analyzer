import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const features = [
      (Icons.score_rounded, 'Overall Score', 'Comprehensive 0–100 score with detailed section breakdown', AppColors.primary),
      (Icons.track_changes_rounded, 'ATS Check', 'How well your resume passes Applicant Tracking Systems', AppColors.accent),
      (Icons.lightbulb_outline_rounded, 'Smart Tips', 'Prioritized, actionable improvements to boost your score', AppColors.accentGold),
      (Icons.psychology_rounded, 'AI Insights', 'Deep analysis of strengths, gaps, and industry fit', AppColors.accentWarm),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("What you'll get", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 14),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 180,
          ),
          children: features.asMap().entries.map((e) {
            final f = e.value;
            return _FeatureCard(icon: f.$1, title: f.$2, desc: f.$3, color: f.$4)
                .animate().fadeIn(delay: (420 + e.key * 70).ms).slideY(begin: 0.1);
          }).toList(),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  final Color color;
  const _FeatureCard({required this.icon, required this.title, required this.desc, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 5),
          Text(desc, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45)),
        ],
      ),
    );
  }
}

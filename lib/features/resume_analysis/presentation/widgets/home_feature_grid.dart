import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:resume_analyzer/core/widgets/glass_container.dart';
import '../../../../core/theme/app_theme.dart';

class HomeFeatureGrid extends StatelessWidget {
  const HomeFeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const features = [
      (
        Icons.score_rounded,
        'Overall Score',
        'Comprehensive 0–100 score with detailed section breakdown',
        AppColors.primary
      ),
      (
        Icons.track_changes_rounded,
        'ATS Check',
        'How well your resume passes Applicant Tracking Systems',
        AppColors.accent
      ),
      (
        Icons.lightbulb_outline_rounded,
        'Smart Tips',
        'Prioritized, actionable improvements to boost your score',
        AppColors.accentGold
      ),
      (
        Icons.psychology_rounded,
        'AI Insights',
        'Deep analysis of strengths, gaps, and industry fit',
        AppColors.accentWarm
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What you'll get",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 175,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final f = features[index];
            return _FeatureCard(
                    icon: f.$1, title: f.$2, desc: f.$3, color: f.$4)
                .animate()
                .fadeIn(delay: (420 + index * 70).ms)
                .slideY(begin: 0.1);
          },
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  final Color color;
  const _FeatureCard(
      {required this.icon,
      required this.title,
      required this.desc,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(height: 1.4, color: AppColors.textSecondary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

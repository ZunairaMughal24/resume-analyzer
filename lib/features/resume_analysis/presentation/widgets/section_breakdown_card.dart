import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/resume_analysis.dart';

class SectionBreakdownCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const SectionBreakdownCard({super.key, required this.analysis});

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
              const Icon(Icons.bar_chart_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Section Breakdown', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 20),
          ...analysis.sectionScores.map((s) => _SectionRow(score: s)),
        ],
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  final SectionScore score;
  const _SectionRow({required this.score});

  Color get _color {
    if (score.score >= 75) return AppColors.success;
    if (score.score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(score.section, style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${score.score}%',
                style: GoogleFonts.geologica(
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: _color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score.score / 100,
              backgroundColor: _color.withValues(alpha: 0.12),
              color: _color,
              minHeight: 6,
            ),
          ),
          if (score.feedback.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              score.feedback,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

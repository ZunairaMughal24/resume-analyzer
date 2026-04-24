import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/resume_analysis.dart';

class ScoreHeroCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const ScoreHeroCard({super.key, required this.analysis});

  Color get _scoreColor {
    if (analysis.overallScore >= 75) return AppColors.success;
    if (analysis.overallScore >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String get _scoreLabel {
    if (analysis.overallScore >= 80) return 'Excellent';
    if (analysis.overallScore >= 65) return 'Good';
    if (analysis.overallScore >= 50) return 'Fair';
    return 'Needs Work';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardBg, _scoreColor.withValues(alpha: 0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _scoreColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 62,
            lineWidth: 8,
            percent: analysis.overallScore / 100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${analysis.overallScore}',
                  style: GoogleFonts.geologica(
                    textStyle: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: _scoreColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                        ),
                  ),
                ),
                Text(
                  '/ 100',
                  style: GoogleFonts.geologica(
                    textStyle: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            progressColor: _scoreColor,
            backgroundColor: _scoreColor.withValues(alpha: 0.12),
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1200,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _scoreLabel,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: _scoreColor),
                ),
                const SizedBox(height: 4),
                Text('Overall Resume Score', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                _ScorePill(label: 'ATS', value: '${analysis.atsScore}%', color: AppColors.accent),
                const SizedBox(height: 6),
                _ScorePill(label: 'Level', value: analysis.experienceLevel, color: AppColors.accentGold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ScorePill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.nunito(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: GoogleFonts.geologica(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

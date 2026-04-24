import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:resume_analyzer/core/theme/app_theme.dart';
import '../../../domain/entities/resume_analysis.dart';

class ScoreHeroCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const ScoreHeroCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final score = analysis.overallScore / 100.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 70.0,
            lineWidth: 12.0,
            percent: score,
            animation: true,
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            progressColor: Colors.white,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${analysis.overallScore}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800)),
                Text('OVERALL',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Colors.white70, letterSpacing: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(analysis.industry,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Industry Fit',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

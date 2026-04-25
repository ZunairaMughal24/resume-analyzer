import 'package:flutter/material.dart';
import 'package:resume_analyzer/core/widgets/section_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/resume_analysis.dart';

class AnalysisSummaryCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const AnalysisSummaryCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'AI Summary',
      icon: Icons.auto_awesome_rounded,
      child: Text(
        analysis.summary,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.7,
            ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/resume_analysis.dart';
import '../widgets/score_hero_card.dart';
import '../widgets/ats_card.dart';
import '../widgets/experience_card.dart';
import '../widgets/analysis_summary_card.dart';
import '../widgets/section_breakdown_card.dart';
import '../widgets/strengths_weaknesses_card.dart';
import '../widgets/suggestions_card.dart';
import '../widgets/skills_card.dart';
import '../widgets/keywords_card.dart';

class ResultsPage extends StatelessWidget {
  final ResumeAnalysis analysis;
  const ResultsPage({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ScoreHeroCard(analysis: analysis).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: AtsCard(analysis: analysis)),
                      const SizedBox(width: 12),
                      Expanded(child: ExperienceCard(analysis: analysis)),
                    ],
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  AnalysisSummaryCard(analysis: analysis).animate().fadeIn(delay: 280.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  SectionBreakdownCard(analysis: analysis).animate().fadeIn(delay: 360.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  StrengthsWeaknessesCard(analysis: analysis).animate().fadeIn(delay: 440.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  SuggestionsCard(analysis: analysis).animate().fadeIn(delay: 520.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  SkillsCard(analysis: analysis).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  KeywordsCard(analysis: analysis).animate().fadeIn(delay: 680.ms).slideY(begin: 0.1),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: AppColors.textPrimary),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Analysis Results', style: Theme.of(context).textTheme.titleLarge),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              analysis.industry,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary, fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

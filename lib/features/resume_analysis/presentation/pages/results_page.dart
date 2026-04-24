import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:resume_analyzer/features/resume_analysis/domain/entities/resume_analysis.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/results/score_hero_card.dart';
import '../widgets/results/analysis_summary_widgets.dart';
import '../widgets/results/detailed_analysis_widgets.dart';
import '../widgets/results/recommendations_widgets.dart';

class ResultsPage extends StatelessWidget {
  final ResumeAnalysis analysis;
  const ResultsPage({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 15, color: AppColors.textPrimary),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ScoreHeroCard(analysis: analysis)
                  .animate()
                  .fadeIn(delay: 100.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 20),
              _TwoColumnRow(
                left: InfoCard(
                  title: 'ATS Score',
                  value: '${analysis.atsScore}%',
                  icon: Icons.track_changes_rounded,
                  color: AppColors.accent,
                ),
                right: InfoCard(
                  title: 'Experience',
                  value: analysis.experienceLevel,
                  icon: Icons.work_outline_rounded,
                  color: AppColors.primary,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: 20),
              SummaryCard(summary: analysis.summary)
                  .animate()
                  .fadeIn(delay: 280.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 20),
              SectionScoresCard(scores: analysis.sectionScores)
                  .animate()
                  .fadeIn(delay: 360.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 20),
              StrengthsWeaknessesCard(
                strengths: analysis.strengths,
                weaknesses: analysis.weaknesses,
              ).animate().fadeIn(delay: 440.ms).slideY(begin: 0.1),
              const SizedBox(height: 20),
              SuggestionsCard(suggestions: analysis.suggestions)
                  .animate()
                  .fadeIn(delay: 520.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 20),
              SkillsCard(skills: analysis.skills)
                  .animate()
                  .fadeIn(delay: 600.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 20),
              _KeywordsCard(
                      keywordsFound: analysis.keywordsFound,
                      keywordsMissing: analysis.keywordsMissing)
                  .animate()
                  .fadeIn(delay: 680.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _TwoColumnRow extends StatelessWidget {
  final Widget left, right;
  const _TwoColumnRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }
}

class _KeywordsCard extends StatelessWidget {
  final List<String> keywordsFound;
  final List<String> keywordsMissing;
  const _KeywordsCard(
      {required this.keywordsFound, required this.keywordsMissing});

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
                    color: AppColors.accentWarm.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.key_rounded,
                    color: AppColors.accentWarm, size: 18),
              ),
              const SizedBox(width: 12),
              Text('Keyword Analysis',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 20),
          _KeywordSection(
              title: 'Found in Resume',
              items: keywordsFound,
              color: AppColors.primary),
          const SizedBox(height: 16),
          _KeywordSection(
              title: 'Missing Keywords',
              items: keywordsMissing,
              color: AppColors.accentGold),
        ],
      ),
    );
  }
}

class _KeywordSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;

  const _KeywordSection(
      {required this.title, required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items
              .map((tag) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withValues(alpha: 0.15)),
                    ),
                    child: Text(tag,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

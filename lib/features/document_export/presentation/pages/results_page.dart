import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:resume_analyzer/features/ai_assistant/domain/entities/resume_analysis.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/score_hero_card.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/ats_card.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/experience_card.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/analysis_summary_card.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/section_breakdown_card.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/strengths_weaknesses_card.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/suggestions_card.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/skills_card.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/keywords_card.dart';
import 'package:resume_analyzer/core/widgets/app_background.dart';
import 'package:resume_analyzer/features/resume_editor/presentation/pages/resume_editor_page.dart';

class ResultsPage extends StatelessWidget {
  final ResumeAnalysis analysis;
  final String resumeText;

  const ResultsPage({
    super.key,
    required this.analysis,
    required this.resumeText,
  });

  void _openEnhance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResumeEditorPage(
          resumeText: resumeText,
          fileName: 'My Resume',
          analysis: analysis,
          startTab: EditorStartTab.suggestions,
        ),
      ),
    );
  }

  void _openEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResumeEditorPage(
          resumeText: resumeText,
          fileName: 'My Resume',
          analysis: analysis,
          startTab: EditorStartTab.editor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 20, 14, 32),
                child: Column(
                  children: [
                    ScoreHeroCard(analysis: analysis)
                        .animate()
                        .fadeIn(delay: 100.ms)
                        .slideY(begin: 0.1),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: AtsCard(analysis: analysis)),
                        const SizedBox(width: 12),
                        Expanded(child: ExperienceCard(analysis: analysis)),
                      ],
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                    const SizedBox(height: 20),
                    AnalysisSummaryCard(analysis: analysis)
                        .animate()
                        .fadeIn(delay: 280.ms)
                        .slideY(begin: 0.1),
                    const SizedBox(height: 20),
                    SectionBreakdownCard(analysis: analysis)
                        .animate()
                        .fadeIn(delay: 360.ms)
                        .slideY(begin: 0.1),
                    const SizedBox(height: 20),
                    StrengthsWeaknessesCard(analysis: analysis)
                        .animate()
                        .fadeIn(delay: 440.ms)
                        .slideY(begin: 0.1),
                    const SizedBox(height: 20),
                    SuggestionsCard(analysis: analysis)
                        .animate()
                        .fadeIn(delay: 520.ms)
                        .slideY(begin: 0.1),
                    const SizedBox(height: 20),
                    SkillsCard(analysis: analysis)
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideY(begin: 0.1),
                    const SizedBox(height: 20),
                    KeywordsCard(analysis: analysis)
                        .animate()
                        .fadeIn(delay: 680.ms)
                        .slideY(begin: 0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.97),
          border:
              Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
        ),
        child: _buildActionButtons(context),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _ResultsButton(
            id: 'btn_enhance_with_ai',
            label: 'Enhance with AI',
            icon: Icons.auto_awesome_rounded,
            isPrimary: true,
            onTap: () => _openEnhance(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _ResultsButton(
            id: 'btn_edit_resume',
            label: 'Edit Resume',
            icon: Icons.edit_rounded,
            isPrimary: false,
            onTap: () => _openEdit(context),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 15, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Analysis Results',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(
              analysis.industry,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppColors.primary, fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultsButton extends StatelessWidget {
  final String id;
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ResultsButton({
    required this.id,
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey(id),
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark])
              : null,
          color: isPrimary ? null : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: AppColors.border),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isPrimary ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

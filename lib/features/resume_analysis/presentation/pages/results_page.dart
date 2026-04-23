import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/resume_analysis.dart';

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
                  _ScoreHeroCard(analysis: analysis).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  _TwoColumnRow(
                    left: _ATSCard(analysis: analysis),
                    right: _ExperienceCard(analysis: analysis),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  _SummaryCard(analysis: analysis).animate().fadeIn(delay: 280.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  _SectionScoresCard(analysis: analysis).animate().fadeIn(delay: 360.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  _StrengthsWeaknessesCard(analysis: analysis).animate().fadeIn(delay: 440.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  _SuggestionsCard(analysis: analysis).animate().fadeIn(delay: 520.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  _SkillsCard(analysis: analysis).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  _KeywordsCard(analysis: analysis).animate().fadeIn(delay: 680.ms).slideY(begin: 0.1),
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
      expandedHeight: 0,
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

// ── Score Hero Card ──────────────────────────────────────────────────────────
class _ScoreHeroCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const _ScoreHeroCard({required this.analysis});

  Color get _scoreColor {
    if (analysis.overallScore >= 75) return AppColors.success;
    if (analysis.overallScore >= 50) return AppColors.warning;
    return AppColors.error;
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
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: _scoreColor, fontWeight: FontWeight.w800, fontSize: 32,
                  ),
                ),
                Text('/ 100', style: Theme.of(context).textTheme.bodySmall),
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
                _ScorePill('ATS: ${analysis.atsScore}%', AppColors.accent),
                const SizedBox(height: 6),
                _ScorePill(analysis.experienceLevel, AppColors.accentGold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _scoreLabel {
    if (analysis.overallScore >= 80) return 'Excellent';
    if (analysis.overallScore >= 65) return 'Good';
    if (analysis.overallScore >= 50) return 'Fair';
    return 'Needs Work';
  }
}

class _ScorePill extends StatelessWidget {
  final String text;
  final Color color;
  const _ScorePill(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color, fontSize: 11),
      ),
    );
  }
}

// ── Two Column Row ───────────────────────────────────────────────────────────
class _TwoColumnRow extends StatelessWidget {
  final Widget left, right;
  const _TwoColumnRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

// ── ATS Card ─────────────────────────────────────────────────────────────────
class _ATSCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const _ATSCard({required this.analysis});

  Color get _color {
    if (analysis.atsScore >= 70) return AppColors.success;
    if (analysis.atsScore >= 45) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.track_changes_rounded,
      iconColor: _color,
      title: 'ATS Score',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${analysis.atsScore}%',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: _color, fontSize: 36, fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            analysis.atsCompatibility,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _color),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: analysis.atsScore / 100,
            backgroundColor: _color.withValues(alpha: 0.15),
            color: _color,
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}

// ── Experience Card ──────────────────────────────────────────────────────────
class _ExperienceCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const _ExperienceCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.workspace_premium_rounded,
      iconColor: AppColors.accentGold,
      title: 'Level',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            analysis.experienceLevel,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppColors.accentGold, fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(analysis.industry, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${analysis.keywordsFound.length} keywords',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.accentGold),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  const _InfoCard({required this.icon, required this.iconColor, required this.title, required this.child});

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
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Summary Card ─────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const _SummaryCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text('AI Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            analysis.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary, height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Scores ───────────────────────────────────────────────────────────
class _SectionScoresCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const _SectionScoresCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: 'Section Breakdown',
      icon: Icons.bar_chart_rounded,
      child: Column(
        children: analysis.sectionScores.map((s) => _SectionRow(score: s)).toList(),
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(score.section, style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${score.score}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: score.score / 100,
            backgroundColor: _color.withValues(alpha: 0.12),
            color: _color,
            borderRadius: BorderRadius.circular(4),
            minHeight: 5,
          ),
          if (score.feedback.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(score.feedback, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

// ── Strengths & Weaknesses ───────────────────────────────────────────────────
class _StrengthsWeaknessesCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const _StrengthsWeaknessesCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: 'Strengths & Weaknesses',
      icon: Icons.balance_rounded,
      child: Column(
        children: [
          _BulletList(
            items: analysis.strengths,
            color: AppColors.success,
            icon: Icons.check_circle_rounded,
            label: 'Strengths',
          ),
          if (analysis.weaknesses.isNotEmpty) ...[
            const SizedBox(height: 16),
            _BulletList(
              items: analysis.weaknesses,
              color: AppColors.error,
              icon: Icons.cancel_rounded,
              label: 'Weaknesses',
            ),
          ],
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  final Color color;
  final IconData icon;
  final String label;
  const _BulletList({required this.items, required this.color, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(item, style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
        )),
      ],
    );
  }
}

// ── Suggestions ──────────────────────────────────────────────────────────────
class _SuggestionsCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const _SuggestionsCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: 'Improvement Suggestions',
      icon: Icons.lightbulb_outline_rounded,
      child: Column(
        children: analysis.suggestions.map((s) => _SuggestionTile(suggestion: s)).toList(),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final Suggestion suggestion;
  const _SuggestionTile({required this.suggestion});

  Color get _color {
    switch (suggestion.priority) {
      case SuggestionPriority.high: return AppColors.error;
      case SuggestionPriority.medium: return AppColors.warning;
      case SuggestionPriority.low: return AppColors.success;
    }
  }

  String get _priorityLabel {
    switch (suggestion.priority) {
      case SuggestionPriority.high: return 'High';
      case SuggestionPriority.medium: return 'Medium';
      case SuggestionPriority.low: return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _priorityLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _color, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(suggestion.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(suggestion.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skills Card ──────────────────────────────────────────────────────────────
class _SkillsCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const _SkillsCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<SkillItem>>{};
    for (final s in analysis.skills) {
      grouped.putIfAbsent(s.category, () => []).add(s);
    }

    return _SectionContainer(
      title: 'Skills Detected',
      icon: Icons.code_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: grouped.entries.map((entry) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.key, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.value.map((s) => _SkillChip(skill: s)).toList(),
            ),
            const SizedBox(height: 14),
          ],
        )).toList(),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final SkillItem skill;
  const _SkillChip({required this.skill});

  Color get _levelColor {
    switch (skill.level.toLowerCase()) {
      case 'expert': return AppColors.success;
      case 'advanced': return AppColors.primary;
      case 'intermediate': return AppColors.accentGold;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _levelColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _levelColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(skill.name, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary)),
          const SizedBox(width: 6),
          Container(
            width: 5, height: 5,
            decoration: BoxDecoration(color: _levelColor, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

// ── Keywords Card ────────────────────────────────────────────────────────────
class _KeywordsCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const _KeywordsCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: 'Keywords',
      icon: Icons.tag_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (analysis.keywordsFound.isNotEmpty) ...[
            Text('Found', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.success)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: analysis.keywordsFound.map((k) => _Chip(k, AppColors.success)).toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (analysis.keywordsMissing.isNotEmpty) ...[
            Text('Missing', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.error)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: analysis.keywordsMissing.map((k) => _Chip(k, AppColors.error)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
    );
  }
}

// ── Section Container Helper ──────────────────────────────────────────────────
class _SectionContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionContainer({required this.title, required this.icon, required this.child});

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
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:resume_analyzer/core/widgets/section_container.dart';
import 'package:resume_analyzer/core/widgets/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/resume_analysis.dart';

class SuggestionsCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const SuggestionsCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Actionable Steps',
      icon: Icons.tips_and_updates_rounded,
      child: Column(
        children: analysis.suggestions
            .map((s) => _PremiumSuggestionCard(suggestion: s))
            .toList(),
      ),
    );
  }
}

class _PremiumSuggestionCard extends StatelessWidget {
  final Suggestion suggestion;
  const _PremiumSuggestionCard({required this.suggestion});

  Color get _color {
    switch (suggestion.priority) {
      case SuggestionPriority.high:
        return AppColors.error;
      case SuggestionPriority.medium:
        return AppColors.warning;
      case SuggestionPriority.low:
        return AppColors.success;
    }
  }

  String get _priorityLabel {
    switch (suggestion.priority) {
      case SuggestionPriority.high:
        return 'HIGH PRIORITY';
      case SuggestionPriority.medium:
        return 'MEDIUM';
      case SuggestionPriority.low:
        return 'TIP';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: 16,
        blur: 8,
        color: AppColors.surfaceElevated.withValues(alpha: 0.3),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: _color),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: _color.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              _priorityLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: _color,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 9,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textMuted, size: 18),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        suggestion.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 16, height: 1.2),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        suggestion.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

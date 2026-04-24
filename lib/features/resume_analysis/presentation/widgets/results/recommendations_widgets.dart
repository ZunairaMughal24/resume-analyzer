import 'package:flutter/material.dart';
import 'package:resume_analyzer/core/theme/app_theme.dart';
import '../../../domain/entities/resume_analysis.dart';

class StrengthsWeaknessesCard extends StatelessWidget {
  final List<String> strengths;
  final List<String> weaknesses;
  const StrengthsWeaknessesCard(
      {super.key, required this.strengths, required this.weaknesses});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _ListSection(
              title: 'Strengths',
              items: strengths,
              color: AppColors.primary,
              icon: Icons.check_circle_outline_rounded),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _ListSection(
              title: 'Gaps to Fix',
              items: weaknesses,
              color: AppColors.error,
              icon: Icons.error_outline_rounded),
        ],
      ),
    );
  }
}

class SuggestionsCard extends StatelessWidget {
  final List<Suggestion> suggestions;
  const SuggestionsCard({super.key, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('How to improve',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 12),
        ...suggestions.map((s) => _SuggestionItem(suggestion: s)).toList(),
      ],
    );
  }
}

class _ListSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  final IconData icon;

  const _ListSection(
      {required this.title,
      required this.items,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ...items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ',
                          style: TextStyle(
                              color: color, fontWeight: FontWeight.bold)),
                      Expanded(
                          child: Text(item,
                              style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  final Suggestion suggestion;
  const _SuggestionItem({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final isHigh = suggestion.priority == SuggestionPriority.high;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isHigh
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(suggestion.title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isHigh ? AppColors.error : AppColors.accentGold)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  suggestion.priority.name.toUpperCase(),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isHigh ? AppColors.error : AppColors.accentGold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(suggestion.description,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary, height: 1.4)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:resume_analyzer/core/widgets/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/editor_bloc.dart';
import '../../domain/entities/resume_analysis.dart';

class SuggestionPickerSection extends StatelessWidget {
  const SuggestionPickerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Summary pill
              _AcceptanceSummary(state: state),
              const SizedBox(height: 20),

              //Suggestions section
              if (state.suggestions.isNotEmpty) ...[
                _SectionHeader(
                  title: 'AI Suggestions',
                  icon: Icons.tips_and_updates_rounded,
                  count: state.acceptedSuggestionsCount,
                  total: state.suggestions.length,
                  onAcceptAll: () =>
                      context.read<EditorBloc>().add(const BulkUpdateSelection(isAccepted: true, type: SelectionType.suggestions)),
                  onRejectAll: () =>
                      context.read<EditorBloc>().add(const BulkUpdateSelection(isAccepted: false, type: SelectionType.suggestions)),
                ),
                const SizedBox(height: 10),
                ...state.suggestions.asMap().entries.map(
                      (entry) => _SuggestionTile(
                        index: entry.key,
                        selectable: entry.value,
                      )
                          .animate()
                          .fadeIn(delay: (80 * entry.key).ms)
                          .slideX(begin: 0.05),
                    ),
                const SizedBox(height: 28),
              ],

              //Missing keywords section
              if (state.missingKeywords.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Missing Keywords',
                  icon: Icons.key_rounded,
                  count: state.acceptedKeywordsCount,
                  total: state.missingKeywords.length,
                  onAcceptAll: () =>
                      context.read<EditorBloc>().add(const BulkUpdateSelection(isAccepted: true, type: SelectionType.keywords)),
                  onRejectAll: () =>
                      context.read<EditorBloc>().add(const BulkUpdateSelection(isAccepted: false, type: SelectionType.keywords)),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.missingKeywords
                      .asMap()
                      .entries
                      .map(
                        (entry) => _KeywordChip(
                          index: entry.key,
                          selectable: entry.value,
                        ),
                      )
                      .toList(),
                ),
              ],

              if (state.suggestions.isEmpty && state.missingKeywords.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 56,
                            color: AppColors.success.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No suggestions available',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Summary Bar ──

class _AcceptanceSummary extends StatelessWidget {
  final EditorState state;
  const _AcceptanceSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final accepted = state.totalAcceptedCount;
    final total = state.totalSelectableCount;

    return GlassContainer(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.accent.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$accepted',
                style: AppTheme.mono(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accepted == 0
                      ? 'No improvements selected'
                      : '$accepted of $total improvements selected',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  'Toggle items below, then tap "Polish with AI"',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Section Header ──

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final int total;
  final VoidCallback onAcceptAll;
  final VoidCallback onRejectAll;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.count,
    required this.total,
    required this.onAcceptAll,
    required this.onRejectAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 1.2,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: count > 0
                ? AppColors.success.withOpacity(0.1)
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$count/$total',
            style: AppTheme.mono(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: count > 0 ? AppColors.success : AppColors.textMuted,
            ),
          ),
        ),
        const Spacer(),
        _MiniButton(
          label: count == total ? 'Clear All' : 'Select All',
          onTap: count == total ? onRejectAll : onAcceptAll,
        ),
      ],
    );
  }
}

class _MiniButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MiniButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
        ),
      ),
    );
  }
}

// Suggestion Tile ─

class _SuggestionTile extends StatelessWidget {
  final int index;
  final SelectableSuggestion selectable;

  const _SuggestionTile({
    required this.index,
    required this.selectable,
  });

  Color _priorityColor(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.high:
        return AppColors.error;
      case SuggestionPriority.medium:
        return AppColors.warning;
      case SuggestionPriority.low:
        return AppColors.success;
    }
  }

  String _priorityLabel(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.high:
        return 'HIGH';
      case SuggestionPriority.medium:
        return 'MEDIUM';
      case SuggestionPriority.low:
        return 'TIP';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(selectable.suggestion.priority);
    final isAccepted = selectable.isAccepted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => context.read<EditorBloc>().add(ToggleSuggestion(index)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isAccepted
                ? AppColors.primary.withOpacity(0.06)
                : AppColors.surfaceElevated.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isAccepted
                  ? AppColors.primary.withOpacity(0.35)
                  : AppColors.border.withOpacity(0.5),
              width: isAccepted ? 1.5 : 1,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Priority stripe
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 3,
                  decoration: BoxDecoration(
                    color: isAccepted ? AppColors.primary : color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: color.withOpacity(0.2)),
                              ),
                              child: Text(
                                _priorityLabel(selectable.suggestion.priority),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 8,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ),
                            const Spacer(),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                isAccepted
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                key: ValueKey(isAccepted),
                                size: 22,
                                color: isAccepted
                                    ? AppColors.primary
                                    : AppColors.textMuted
                                        .withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          selectable.suggestion.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectable.suggestion.description,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                    fontSize: 12,
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
      ),
    );
  }
}

// Keyword Chip ─

class _KeywordChip extends StatelessWidget {
  final int index;
  final SelectableKeyword selectable;

  const _KeywordChip({
    required this.index,
    required this.selectable,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = selectable.isAccepted;

    return GestureDetector(
      onTap: () => context.read<EditorBloc>().add(ToggleKeyword(index)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isAccepted
              ? AppColors.primary.withOpacity(0.12)
              : AppColors.surfaceElevated.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isAccepted
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.border.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAccepted ? Icons.check_rounded : Icons.add_rounded,
              size: 14,
              color: isAccepted ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              selectable.keyword,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        isAccepted ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isAccepted ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

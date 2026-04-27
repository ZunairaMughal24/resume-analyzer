import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:resume_analyzer/core/widgets/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:resume_analyzer/features/resume_editor/presentation/bloc/editor_bloc.dart';
import 'package:resume_analyzer/features/ai_assistant/domain/entities/resume_analysis.dart';

class SuggestionPickerSection extends StatelessWidget {
  final VoidCallback onApplied;

  const SuggestionPickerSection({super.key, required this.onApplied});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditorBloc, EditorState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status &&
          curr.status == EditorStatus.loaded &&
          curr.isModified,
      listener: (_, __) {
        // AI finished polishing → navigate to Preview.
        onApplied();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Resume enhanced! Review in Preview tab.',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          backgroundColor: AppColors.primary.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ));
      },
      builder: (context, state) {
        final isPolishing = state.status == EditorStatus.polishing;

        return Column(
          children: [
            //list of suggestions
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary pill showing how many items are selected
                    _AcceptanceSummary(state: state),
                    const SizedBox(height: 20),

                    // AI Suggestions list
                    if (state.suggestions.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'AI Suggestions',
                        icon: Icons.tips_and_updates_rounded,
                        count: state.acceptedSuggestionsCount,
                        total: state.suggestions.length,
                        onAcceptAll: () => context.read<EditorBloc>().add(
                            const BulkUpdateSelection(
                                isAccepted: true,
                                type: SelectionType.suggestions)),
                        onRejectAll: () => context.read<EditorBloc>().add(
                            const BulkUpdateSelection(
                                isAccepted: false,
                                type: SelectionType.suggestions)),
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

                    // Missing Keywords chips
                    if (state.missingKeywords.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Missing Keywords',
                        icon: Icons.key_rounded,
                        count: state.acceptedKeywordsCount,
                        total: state.missingKeywords.length,
                        onAcceptAll: () => context.read<EditorBloc>().add(
                            const BulkUpdateSelection(
                                isAccepted: true,
                                type: SelectionType.keywords)),
                        onRejectAll: () => context.read<EditorBloc>().add(
                            const BulkUpdateSelection(
                                isAccepted: false,
                                type: SelectionType.keywords)),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.missingKeywords
                            .asMap()
                            .entries
                            .map((entry) => _KeywordChip(
                                  index: entry.key,
                                  selectable: entry.value,
                                ))
                            .toList(),
                      ),
                    ],

                    // Empty state
                    if (state.suggestions.isEmpty &&
                        state.missingKeywords.isEmpty)
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            //"Apply Suggestions" button
            _ApplySuggestionsBar(
              isPolishing: isPolishing,
              hasSelections: state.hasSelections,
            ),
          ],
        );
      },
    );
  }
}

class _ApplySuggestionsBar extends StatelessWidget {
  final bool isPolishing;
  final bool hasSelections;

  const _ApplySuggestionsBar({
    required this.isPolishing,
    required this.hasSelections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.97),
        border:
            Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
      ),
      child: GestureDetector(
        onTap: (isPolishing || !hasSelections)
            ? null
            : () => context.read<EditorBloc>().add(PolishWithAI()),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 52,
          decoration: BoxDecoration(
            gradient: hasSelections
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark])
                : null,
            color: hasSelections ? null : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            boxShadow: hasSelections
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: isPolishing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: hasSelections ? Colors.white : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hasSelections
                          ? 'Apply Suggestions'
                          : 'Select at least one item',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: hasSelections
                                ? Colors.white
                                : AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                    ),
                  ]),
          ),
        ),
      ),
    );
  }
}

// Summary pill

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
              gradient: LinearGradient(colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.accent.withOpacity(0.1),
              ]),
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
                  'Toggle items below, then tap "Apply Suggestions"',
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

// Section header with "Select All / Clear All"

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

// Suggestion tile

class _SuggestionTile extends StatelessWidget {
  final int index;
  final SelectableSuggestion selectable;

  const _SuggestionTile({required this.index, required this.selectable});

  Color _priorityColor(SuggestionPriority p) {
    switch (p) {
      case SuggestionPriority.high:
        return AppColors.error;
      case SuggestionPriority.medium:
        return AppColors.warning;
      case SuggestionPriority.low:
        return AppColors.success;
    }
  }

  String _priorityLabel(SuggestionPriority p) {
    switch (p) {
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
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: color.withOpacity(0.2)),
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
                                  : AppColors.textMuted.withOpacity(0.5),
                            ),
                          ),
                        ]),
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

// Keyword chip

class _KeywordChip extends StatelessWidget {
  final int index;
  final SelectableKeyword selectable;

  const _KeywordChip({required this.index, required this.selectable});

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

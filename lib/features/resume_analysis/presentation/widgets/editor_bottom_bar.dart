import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/editor_bloc.dart';

class EditorBottomBar extends StatelessWidget {
  final VoidCallback onSaveShare;
  const EditorBottomBar({super.key, required this.onSaveShare});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) {
        final isPolishing = state.status == EditorStatus.polishing;
        return Container(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.95),
            border: Border(
                top:
                    BorderSide(color: AppColors.border.withOpacity(0.5))),
          ),
          child: Row(children: [
            // Polish with AI button
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: (isPolishing || !state.hasSelections)
                    ? null
                    : () => context.read<EditorBloc>().add(PolishWithAI()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: state.hasSelections
                        ? const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark])
                        : null,
                    color:
                        state.hasSelections ? null : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: state.hasSelections
                        ? [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4))
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
                            Icon(Icons.auto_awesome_rounded,
                                size: 18,
                                color: state.hasSelections
                                    ? Colors.white
                                    : AppColors.textMuted),
                            const SizedBox(width: 8),
                            Text(
                              'Polish with AI',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: state.hasSelections
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
            ),
            const SizedBox(width: 10),
            // Save & Share button
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: onSaveShare,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.save_alt_rounded,
                          size: 18, color: AppColors.textPrimary),
                      const SizedBox(width: 8),
                      Text('Save & Share',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                    ]),
                  ),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

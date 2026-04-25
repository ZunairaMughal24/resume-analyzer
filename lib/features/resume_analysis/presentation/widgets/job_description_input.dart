import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:resume_analyzer/core/widgets/glass_container.dart';
import '../../../../core/theme/app_theme.dart';

class JobDescriptionInput extends StatefulWidget {
  final Function(String) onChanged;
  const JobDescriptionInput({super.key, required this.onChanged});

  @override
  State<JobDescriptionInput> createState() => _JobDescriptionInputState();
}

class _JobDescriptionInputState extends State<JobDescriptionInput> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 16,
      border: Border.all(
        color: _expanded 
            ? AppColors.primary.withValues(alpha: 0.5) 
            : Colors.white.withValues(alpha: 0.1),
        width: _expanded ? 1.5 : 1.0,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.work_outline_rounded, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Job Description', style: Theme.of(context).textTheme.titleMedium),
                        Text('Optional — improve match accuracy', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                maxLines: 6,
                onChanged: widget.onChanged,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Paste job description here to get tailored feedback...',
                  filled: true,
                  fillColor: AppColors.surfaceElevated.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ).animate().fadeIn().slideY(begin: -0.1),
        ],
      ),
    ).animate().fadeIn(delay: 380.ms).slideY(begin: 0.1);
  }
}

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:resume_analyzer/features/resume_editor/domain/entities/resume_data.dart';
import 'package:resume_analyzer/features/resume_editor/presentation/widgets/editor/editable_field.dart';

class EducationEditor extends StatelessWidget {
  final EducationEntry edu;
  final int index;
  final int total;
  final ValueChanged<EducationEntry> onSaved;

  const EducationEditor({
    super.key,
    required this.edu,
    required this.index,
    required this.total,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (total > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Entry ${index + 1} of $total',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
                color: AppColors.error,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Entry?'),
                      content: const Text('Are you sure you want to remove this entry?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true), 
                          child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    onSaved(const EducationEntry(degree: '__DELETE__', institution: '', dates: '', details: ''));
                  }
                },
              ),
            ],
          ),
        EditableField(
          label: 'Degree',
          value: edu.degree,
          onSaved: (v) => onSaved(edu.copyWith(degree: v)),
        ),
        EditableField(
          label: 'Institution',
          value: edu.institution,
          onSaved: (v) => onSaved(edu.copyWith(institution: v)),
        ),
        Row(
          children: [
            Expanded(
              child: EditableField(
                label: 'Dates',
                value: edu.dates,
                onSaved: (v) => onSaved(edu.copyWith(dates: v)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: EditableField(
                label: 'Details / GPA',
                value: edu.details,
                onSaved: (v) => onSaved(edu.copyWith(details: v)),
              ),
            ),
          ],
        ),
        if (index < total - 1)
          Divider(height: 20, color: AppColors.border.withOpacity(0.4)),
      ],
    );
  }
}

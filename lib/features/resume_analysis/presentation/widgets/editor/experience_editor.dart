import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/resume_data.dart';
import 'editable_field.dart';

class ExperienceEditor extends StatelessWidget {
  final ExperienceEntry exp;
  final int index;
  final int total;
  final ValueChanged<ExperienceEntry> onSaved;

  const ExperienceEditor({
    super.key,
    required this.exp,
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
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Position ${index + 1} of $total',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
            ),
          ),
        EditableField(
          label: 'Job Title',
          value: exp.title,
          onSaved: (v) => onSaved(exp.copyWith(title: v)),
        ),
        EditableField(
          label: 'Company',
          value: exp.company,
          onSaved: (v) => onSaved(exp.copyWith(company: v)),
        ),
        Row(
          children: [
            Expanded(
              child: EditableField(
                label: 'Dates',
                value: exp.dates,
                onSaved: (v) => onSaved(exp.copyWith(dates: v)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: EditableField(
                label: 'Location',
                value: exp.location,
                onSaved: (v) => onSaved(exp.copyWith(location: v)),
              ),
            ),
          ],
        ),
        EditableField(
          label: 'Bullets (one per line)',
          value: exp.bullets.join('\n'),
          maxLines: 5,
          onSaved: (v) {
            final bullets = v
                .split('\n')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            onSaved(exp.copyWith(bullets: bullets));
          },
        ),
        if (index < total - 1)
          Divider(
            height: 20,
            color: AppColors.border.withValues(alpha: 0.4),
          ),
      ],
    );
  }
}

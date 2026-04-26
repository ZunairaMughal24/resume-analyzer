import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/resume_data.dart';
import 'editable_field.dart';

class ProjectEditor extends StatelessWidget {
  final ProjectEntry proj;
  final int index;
  final int total;
  final ValueChanged<ProjectEntry> onSaved;

  const ProjectEditor({
    super.key,
    required this.proj,
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
              'Project ${index + 1} of $total',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
            ),
          ),
        EditableField(
          label: 'Project Name',
          value: proj.name,
          onSaved: (v) => onSaved(proj.copyWith(name: v)),
        ),
        EditableField(
          label: 'Description',
          value: proj.description,
          maxLines: 2,
          onSaved: (v) => onSaved(proj.copyWith(description: v)),
        ),
        EditableField(
          label: 'Link (Optional)',
          value: proj.link,
          onSaved: (v) => onSaved(proj.copyWith(link: v)),
        ),
        EditableField(
          label: 'Bullets (one per line)',
          value: proj.bullets.join('\n'),
          maxLines: 4,
          onSaved: (v) {
            final bullets = v
                .split('\n')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            onSaved(proj.copyWith(bullets: bullets));
          },
        ),
        if (index < total - 1)
          Divider(height: 20, color: AppColors.border.withOpacity(0.4)),
      ],
    );
  }
}

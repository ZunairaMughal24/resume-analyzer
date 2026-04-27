import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:resume_analyzer/features/resume_editor/domain/entities/resume_data.dart';
import 'package:resume_analyzer/features/resume_editor/presentation/widgets/editor/editable_field.dart';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
                color: AppColors.error,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Project?'),
                      content: const Text('Are you sure you want to remove this project?'),
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
                    onSaved(const ProjectEntry(name: '__DELETE__', description: '', link: '', bullets: []));
                  }
                },
              ),
            ],
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

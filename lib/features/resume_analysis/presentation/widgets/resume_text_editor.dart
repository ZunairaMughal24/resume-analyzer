import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/resume_data.dart';
import '../bloc/editor_bloc.dart';

class ResumeTextEditor extends StatefulWidget {
  const ResumeTextEditor({super.key});

  @override
  State<ResumeTextEditor> createState() => _ResumeTextEditorState();
}

class _ResumeTextEditorState extends State<ResumeTextEditor> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) {
        if (state.resumeData == null) {
          return _buildEmptyState(context);
        }
        return _buildEditor(context, state.resumeData!);
      },
    );
  }

  // Empty state (before polish)

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'No structured resume yet',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Go to the Suggestions tab, select improvements to apply, then tap "Polish with AI".\n\nThe AI will parse your resume into editable sections.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                context.read<EditorBloc>()
                  ..add(AcceptAllSuggestions())
                  ..add(AcceptAllKeywords())
                  ..add(PolishWithAI());
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Polish with AI',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section-based editor

  Widget _buildEditor(BuildContext context, ResumeData data) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header info
        _SectionCard(
          icon: Icons.person_rounded,
          title: 'Personal Info',
          children: [
            _EditableField(
              label: 'Full Name',
              value: data.fullName,
              onSaved: (v) => _update(context, data.copyWith(fullName: v)),
            ),
          ],
        ),
        _SectionCard(
          icon: Icons.contact_mail_rounded,
          title: 'Contact',
          children: [
            _EditableField(
              label: 'Email',
              value: data.contact.email,
              keyboardType: TextInputType.emailAddress,
              onSaved: (v) => _update(
                context,
                data.copyWith(contact: data.contact.copyWith(email: v)),
              ),
            ),
            _EditableField(
              label: 'Phone',
              value: data.contact.phone,
              keyboardType: TextInputType.phone,
              onSaved: (v) => _update(
                context,
                data.copyWith(contact: data.contact.copyWith(phone: v)),
              ),
            ),
            _EditableField(
              label: 'Location',
              value: data.contact.location,
              onSaved: (v) => _update(
                context,
                data.copyWith(contact: data.contact.copyWith(location: v)),
              ),
            ),
            _EditableField(
              label: 'LinkedIn',
              value: data.contact.linkedin,
              onSaved: (v) => _update(
                context,
                data.copyWith(contact: data.contact.copyWith(linkedin: v)),
              ),
            ),
            _EditableField(
              label: 'GitHub',
              value: data.contact.github,
              onSaved: (v) => _update(
                context,
                data.copyWith(contact: data.contact.copyWith(github: v)),
              ),
            ),
            _EditableField(
              label: 'Website',
              value: data.contact.website,
              onSaved: (v) => _update(
                context,
                data.copyWith(contact: data.contact.copyWith(website: v)),
              ),
            ),
          ],
        ),
        if (data.summary.isNotEmpty)
          _SectionCard(
            icon: Icons.notes_rounded,
            title: 'Summary',
            children: [
              _EditableField(
                label: 'Professional Summary',
                value: data.summary,
                maxLines: 5,
                onSaved: (v) => _update(context, data.copyWith(summary: v)),
              ),
            ],
          ),
        if (data.experience.isNotEmpty)
          _SectionCard(
            icon: Icons.work_rounded,
            title: 'Experience',
            children: data.experience.asMap().entries.map((entry) {
              final i = entry.key;
              final exp = entry.value;
              return _ExperienceEditor(
                exp: exp,
                index: i,
                total: data.experience.length,
                onSaved: (updated) {
                  final list = List<ExperienceEntry>.from(data.experience);
                  list[i] = updated;
                  _update(context, data.copyWith(experience: list));
                },
              );
            }).toList(),
          ),
        if (data.education.isNotEmpty)
          _SectionCard(
            icon: Icons.school_rounded,
            title: 'Education',
            children: data.education.asMap().entries.map((entry) {
              final i = entry.key;
              final edu = entry.value;
              return _EducationEditor(
                edu: edu,
                index: i,
                total: data.education.length,
                onSaved: (updated) {
                  final list = List<EducationEntry>.from(data.education);
                  list[i] = updated;
                  _update(context, data.copyWith(education: list));
                },
              );
            }).toList(),
          ),
        if (data.skills.isNotEmpty)
          _SectionCard(
            icon: Icons.psychology_rounded,
            title: 'Skills',
            children: [
              _EditableField(
                label: 'Skills (comma-separated)',
                value: data.skills.join(', '),
                maxLines: 3,
                onSaved: (v) {
                  final skills = v
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();
                  _update(context, data.copyWith(skills: skills));
                },
              ),
            ],
          ),
        if (data.projects.isNotEmpty)
          _SectionCard(
            icon: Icons.rocket_launch_rounded,
            title: 'Projects',
            children: data.projects.asMap().entries.map((entry) {
              final i = entry.key;
              final proj = entry.value;
              return _ProjectEditor(
                proj: proj,
                index: i,
                total: data.projects.length,
                onSaved: (updated) {
                  final list = List<ProjectEntry>.from(data.projects);
                  list[i] = updated;
                  _update(context, data.copyWith(projects: list));
                },
              );
            }).toList(),
          ),
        if (data.certifications.isNotEmpty)
          _SectionCard(
            icon: Icons.verified_rounded,
            title: 'Certifications',
            children: [
              _EditableField(
                label: 'Certifications (one per line)',
                value: data.certifications.join('\n'),
                maxLines: 4,
                onSaved: (v) {
                  final certs = v
                      .split('\n')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();
                  _update(context, data.copyWith(certifications: certs));
                },
              ),
            ],
          ),
        if (data.languages.isNotEmpty)
          _SectionCard(
            icon: Icons.language_rounded,
            title: 'Languages',
            children: [
              _EditableField(
                label: 'Languages (comma-separated)',
                value: data.languages.join(', '),
                onSaved: (v) {
                  final langs = v
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();
                  _update(context, data.copyWith(languages: langs));
                },
              ),
            ],
          ),
        const SizedBox(height: 80),
      ],
    );
  }

  void _update(BuildContext context, ResumeData updated) {
    context.read<EditorBloc>().add(UpdateResumeData(updated));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_rounded, color: Colors.white, size: 16),
        SizedBox(width: 8),
        Text('Changes saved'),
      ]),
      backgroundColor: AppColors.success.withValues(alpha: 0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }
}

//Reusable Widgets

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom:
                    BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
          // Fields
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableField extends StatefulWidget {
  final String label;
  final String value;
  final int maxLines;
  final TextInputType keyboardType;
  final ValueChanged<String> onSaved;

  const _EditableField({
    required this.label,
    required this.value,
    required this.onSaved,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<_EditableField> {
  late TextEditingController _ctrl;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_EditableField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_dirty) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _ctrl,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontSize: 13,
              height: 1.5,
            ),
        onChanged: (_) {
          if (!_dirty) setState(() => _dirty = true);
        },
        onEditingComplete: () {
          if (_dirty) {
            widget.onSaved(_ctrl.text.trim());
            setState(() => _dirty = false);
          }
        },
        onTapOutside: (_) {
          if (_dirty) {
            widget.onSaved(_ctrl.text.trim());
            setState(() => _dirty = false);
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textMuted, fontSize: 11),
          filled: true,
          fillColor: AppColors.surfaceElevated.withValues(alpha: 0.6),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          suffixIcon: _dirty
              ? GestureDetector(
                  onTap: () {
                    widget.onSaved(_ctrl.text.trim());
                    setState(() => _dirty = false);
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              : const Icon(Icons.check_circle_outline_rounded,
                  size: 16, color: AppColors.success),
        ),
        cursorColor: AppColors.primary,
      ),
    );
  }
}

// Experience editor

class _ExperienceEditor extends StatelessWidget {
  final ExperienceEntry exp;
  final int index;
  final int total;
  final ValueChanged<ExperienceEntry> onSaved;

  const _ExperienceEditor({
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
        _EditableField(
          label: 'Job Title',
          value: exp.title,
          onSaved: (v) => onSaved(exp.copyWith(title: v)),
        ),
        _EditableField(
          label: 'Company',
          value: exp.company,
          onSaved: (v) => onSaved(exp.copyWith(company: v)),
        ),
        Row(
          children: [
            Expanded(
              child: _EditableField(
                label: 'Dates',
                value: exp.dates,
                onSaved: (v) => onSaved(exp.copyWith(dates: v)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _EditableField(
                label: 'Location',
                value: exp.location,
                onSaved: (v) => onSaved(exp.copyWith(location: v)),
              ),
            ),
          ],
        ),
        _EditableField(
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

//Education editor

class _EducationEditor extends StatelessWidget {
  final EducationEntry edu;
  final int index;
  final int total;
  final ValueChanged<EducationEntry> onSaved;

  const _EducationEditor({
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
        _EditableField(
          label: 'Degree',
          value: edu.degree,
          onSaved: (v) => onSaved(edu.copyWith(degree: v)),
        ),
        _EditableField(
          label: 'Institution',
          value: edu.institution,
          onSaved: (v) => onSaved(edu.copyWith(institution: v)),
        ),
        Row(
          children: [
            Expanded(
              child: _EditableField(
                label: 'Dates',
                value: edu.dates,
                onSaved: (v) => onSaved(edu.copyWith(dates: v)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _EditableField(
                label: 'Details / GPA',
                value: edu.details,
                onSaved: (v) => onSaved(edu.copyWith(details: v)),
              ),
            ),
          ],
        ),
        if (index < total - 1)
          Divider(height: 20, color: AppColors.border.withValues(alpha: 0.4)),
      ],
    );
  }
}

// Project editor
class _ProjectEditor extends StatelessWidget {
  final ProjectEntry proj;
  final int index;
  final int total;
  final ValueChanged<ProjectEntry> onSaved;

  const _ProjectEditor({
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
        _EditableField(
          label: 'Project Name',
          value: proj.name,
          onSaved: (v) => onSaved(proj.copyWith(name: v)),
        ),
        _EditableField(
          label: 'Description',
          value: proj.description,
          maxLines: 2,
          onSaved: (v) => onSaved(proj.copyWith(description: v)),
        ),
        _EditableField(
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
          Divider(height: 20, color: AppColors.border.withValues(alpha: 0.4)),
      ],
    );
  }
}

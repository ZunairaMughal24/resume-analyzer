import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/resume_data.dart';
import '../bloc/editor_bloc.dart';
import 'editor/section_card.dart';
import 'editor/editable_field.dart';
import 'editor/experience_editor.dart';
import 'editor/education_editor.dart';
import 'editor/project_editor.dart';

class ResumeTextEditor extends StatelessWidget {
  final VoidCallback onPreviewTap;

  const ResumeTextEditor({super.key, required this.onPreviewTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) {
        return Column(
          children: [
            // ── Main content
            Expanded(
              child: switch (state.status) {
                EditorStatus.parsing => _ParsingLoader(),
                _ => state.resumeData == null
                    ? _EmptyState()
                    : _SectionEditor(resumeData: state.resumeData!),
              },
            ),

            //bottom action bar
            if (state.resumeData != null)
              _EditorActionBar(
                isPolishing: state.status == EditorStatus.polishing,
                hasSelections: state.hasSelections,
                onRefine: () => context.read<EditorBloc>().add(PolishWithAI()),
                onSaveChanges: onPreviewTap,
              ),
          ],
        );
      },
    );
  }
}

// Empty state — shown before any AI polish has been run.

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.edit_note_rounded,
                  color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Nothing to edit yet',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Go to the Suggestions tab, choose the improvements\nyou want, and tap "Apply Suggestions".\n\nYour resume will appear here ready for manual edits.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Parsing loader — shown while AI extracts data from raw resume text.

class _ParsingLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Extracting Resume Data…',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'AI is reading your resume and populating\nthe editor fields. This takes a few seconds.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Section-based structured editor

class _SectionEditor extends StatelessWidget {
  final ResumeData resumeData;
  const _SectionEditor({required this.resumeData});

  void _update(BuildContext context, ResumeData updated) {
    context.read<EditorBloc>().add(UpdateResumeData(updated));
  }

  @override
  Widget build(BuildContext context) {
    final data = resumeData;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        // Personal Info
        SectionCard(
          icon: Icons.person_rounded,
          title: 'Personal Info',
          children: [
            EditableField(
              label: 'Full Name',
              value: data.fullName,
              onSaved: (v) => _update(context, data.copyWith(fullName: v)),
            ),
          ],
        ),

        // Contact
        SectionCard(
          icon: Icons.contact_mail_rounded,
          title: 'Contact',
          children: [
            EditableField(
              label: 'Email',
              value: data.contact.email,
              keyboardType: TextInputType.emailAddress,
              onSaved: (v) => _update(context,
                  data.copyWith(contact: data.contact.copyWith(email: v))),
            ),
            EditableField(
              label: 'Phone',
              value: data.contact.phone,
              keyboardType: TextInputType.phone,
              onSaved: (v) => _update(context,
                  data.copyWith(contact: data.contact.copyWith(phone: v))),
            ),
            EditableField(
              label: 'Location',
              value: data.contact.location,
              onSaved: (v) => _update(context,
                  data.copyWith(contact: data.contact.copyWith(location: v))),
            ),
            EditableField(
              label: 'LinkedIn',
              value: data.contact.linkedin,
              onSaved: (v) => _update(context,
                  data.copyWith(contact: data.contact.copyWith(linkedin: v))),
            ),
            EditableField(
              label: 'GitHub',
              value: data.contact.github,
              onSaved: (v) => _update(context,
                  data.copyWith(contact: data.contact.copyWith(github: v))),
            ),
            EditableField(
              label: 'Website',
              value: data.contact.website,
              onSaved: (v) => _update(context,
                  data.copyWith(contact: data.contact.copyWith(website: v))),
            ),
          ],
        ),

        // Summary
        if (data.summary.isNotEmpty)
          SectionCard(
            icon: Icons.notes_rounded,
            title: 'Summary',
            children: [
              EditableField(
                label: 'Professional Summary',
                value: data.summary,
                maxLines: 5,
                onSaved: (v) => _update(context, data.copyWith(summary: v)),
              ),
            ],
          ),

        // Experience
        if (data.experience.isNotEmpty)
          SectionCard(
            icon: Icons.work_rounded,
            title: 'Experience',
            children: data.experience.asMap().entries.map((entry) {
              final i = entry.key;
              return ExperienceEditor(
                exp: entry.value,
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

        // Education
        if (data.education.isNotEmpty)
          SectionCard(
            icon: Icons.school_rounded,
            title: 'Education',
            children: data.education.asMap().entries.map((entry) {
              final i = entry.key;
              return EducationEditor(
                edu: entry.value,
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

        // Skills
        if (data.skills.isNotEmpty)
          SectionCard(
            icon: Icons.psychology_rounded,
            title: 'Skills',
            children: [
              EditableField(
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

        // Projects
        if (data.projects.isNotEmpty)
          SectionCard(
            icon: Icons.rocket_launch_rounded,
            title: 'Projects',
            children: data.projects.asMap().entries.map((entry) {
              final i = entry.key;
              return ProjectEditor(
                proj: entry.value,
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

        // Certifications
        if (data.certifications.isNotEmpty)
          SectionCard(
            icon: Icons.verified_rounded,
            title: 'Certifications',
            children: [
              EditableField(
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

        // Languages
        if (data.languages.isNotEmpty)
          SectionCard(
            icon: Icons.language_rounded,
            title: 'Languages',
            children: [
              EditableField(
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

        const SizedBox(height: 16),
      ],
    );
  }
}

class _EditorActionBar extends StatelessWidget {
  final bool isPolishing;
  final bool hasSelections;
  final VoidCallback onRefine;
  final VoidCallback onSaveChanges;

  const _EditorActionBar({
    required this.isPolishing,
    required this.hasSelections,
    required this.onRefine,
    required this.onSaveChanges,
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
      child: Row(children: [
        // "Refine with AI" — re-runs polish with current suggestion selections
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: isPolishing ? null : onRefine,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: isPolishing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Refine with AI',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
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

        //Save Changes
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: onSaveChanges,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check_rounded,
                      size: 18, color: AppColors.textPrimary),
                  const SizedBox(width: 8),
                  Text(
                    'Save Changes',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

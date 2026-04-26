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
        SectionCard(
          icon: Icons.contact_mail_rounded,
          title: 'Contact',
          children: [
            EditableField(
              label: 'Email',
              value: data.contact.email,
              keyboardType: TextInputType.emailAddress,
              onSaved: (v) => _update(
                context,
                data.copyWith(contact: data.contact.copyWith(email: v)),
              ),
            ),
            EditableField(
              label: 'Phone',
              value: data.contact.phone,
              keyboardType: TextInputType.phone,
              onSaved: (v) => _update(
                context,
                data.copyWith(contact: data.contact.copyWith(phone: v)),
              ),
            ),
            EditableField(
              label: 'Location',
              value: data.contact.location,
              onSaved: (v) => _update(
                context,
                data.copyWith(contact: data.contact.copyWith(location: v)),
              ),
            ),
            EditableField(
              label: 'LinkedIn',
              value: data.contact.linkedin,
              onSaved: (v) => _update(
                context,
                data.copyWith(contact: data.contact.copyWith(linkedin: v)),
              ),
            ),
            EditableField(
              label: 'GitHub',
              value: data.contact.github,
              onSaved: (v) => _update(
                context,
                data.copyWith(contact: data.contact.copyWith(github: v)),
              ),
            ),
            EditableField(
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
        if (data.experience.isNotEmpty)
          SectionCard(
            icon: Icons.work_rounded,
            title: 'Experience',
            children: data.experience.asMap().entries.map((entry) {
              final i = entry.key;
              final exp = entry.value;
              return ExperienceEditor(
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
          SectionCard(
            icon: Icons.school_rounded,
            title: 'Education',
            children: data.education.asMap().entries.map((entry) {
              final i = entry.key;
              final edu = entry.value;
              return EducationEditor(
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
        if (data.projects.isNotEmpty)
          SectionCard(
            icon: Icons.rocket_launch_rounded,
            title: 'Projects',
            children: data.projects.asMap().entries.map((entry) {
              final i = entry.key;
              final proj = entry.value;
              return ProjectEditor(
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

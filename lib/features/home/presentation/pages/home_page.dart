import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/bloc/resume_bloc.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/home_feature_grid.dart';

import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/upload_section.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/job_description_input.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/home_hero_banner.dart';

import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/loading_overlay.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/analyze_button.dart';

import 'package:resume_analyzer/core/widgets/app_background.dart';
import 'package:resume_analyzer/features/document_export/presentation/pages/results_page.dart';
import 'package:resume_analyzer/features/settings/presentation/pages/settings_page.dart';
import '../../../../core/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _resumeText = '';
  String _jobDescription = '';

  void _onAnalyze() {
    if (_resumeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please upload a resume first'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }
    context.read<ResumeBloc>().add(AnalyzeResumeEvent(
          resumeText: _resumeText,
          jobDescription: _jobDescription.isEmpty ? null : _jobDescription,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResumeBloc, ResumeState>(
      listener: (context, state) {
        if (state is ResumeSuccess) {
          final bloc = context.read<ResumeBloc>();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ResultsPage(
                    analysis: state.analysis, resumeText: _resumeText)),
          ).then((_) => bloc.add(ResetResumeEvent()));
        } else if (state is ResumeError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ));
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context),
        body: AppBackground(
          child: BlocBuilder<ResumeBloc, ResumeState>(
            builder: (context, state) {
              final isLoading = state is ResumeLoading;
              return Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const HomeHeroBanner(),
                              const SizedBox(height: 24),
                              UploadSection(
                                onResumeExtracted: (text) =>
                                    setState(() => _resumeText = text),
                                resumeText: _resumeText,
                              ),
                              const SizedBox(height: 2),
                              JobDescriptionInput(
                                  onChanged: (v) =>
                                      setState(() => _jobDescription = v)),
                              const SizedBox(height: 20),
                              AnalyzeButton(
                                onPressed: _onAnalyze,
                                isLoading: isLoading,
                                isActive: _resumeText.isNotEmpty,
                              ),
                              const SizedBox(height: 20),
                              const HomeFeatureGrid(),
                              const SizedBox(height: 48),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isLoading) const LoadingOverlay(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 15),
          ),
          const SizedBox(width: 10),
          const Text('ResumeAI'),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.settings_rounded,
                size: 17, color: Colors.white),
          ),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const SettingsPage())),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

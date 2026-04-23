import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/resume_bloc.dart';
import '../widgets/upload_section.dart';
import '../widgets/job_description_input.dart';
import 'results_page.dart';
import 'settings_page.dart';
import '../../../../core/theme/app_theme.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _resumeText = '';
  String _jobDescription = '';

  void _onResumeExtracted(String text) => setState(() => _resumeText = text);

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
            MaterialPageRoute(builder: (_) => ResultsPage(analysis: state.analysis)),
          ).then((_) => bloc.add(ResetResumeEvent()));
        } else if (state is ResumeError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 15),
              ),
              const SizedBox(width: 10),
              const Text('ResumeAI'),
            ],
          ),
          actions: [
            IconButton(
              icon: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.settings_rounded, size: 17, color: AppColors.textSecondary),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<ResumeBloc, ResumeState>(
          builder: (context, state) {
            final isLoading = state is ResumeLoading;
            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroBanner(context),
                            const SizedBox(height: 32),
                            UploadSection(
                              onResumeExtracted: _onResumeExtracted,
                              resumeText: _resumeText,
                            ),
                            const SizedBox(height: 16),
                            JobDescriptionInput(onChanged: (v) => setState(() => _jobDescription = v)),
                            const SizedBox(height: 28),
                            _buildAnalyzeButton(context, isLoading),
                            const SizedBox(height: 40),
                            _buildFeatureGrid(context),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoading) _LoadingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(100),
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Text('Powered by Google Gemini', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.accent, fontSize: 11)),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.05),
        const SizedBox(height: 18),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.textPrimary, Color(0xFFAA99FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Analyze Your\nResume with AI',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(height: 1.1, color: Colors.white),
          ),
        ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.08),
        const SizedBox(height: 14),
        Text(
          'Upload your resume and get instant AI-powered feedback\non ATS compatibility, skills, and actionable improvements.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.65),
        ).animate().fadeIn(delay: 260.ms),
      ],
    );
  }

  Widget _buildAnalyzeButton(BuildContext context, bool isLoading) {
    final active = _resumeText.isNotEmpty && !isLoading;
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
          color: active ? null : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 10))]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _onAnalyze,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 20),
              const SizedBox(width: 10),
              Text(
                'Analyze Resume',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.08);
  }

  Widget _buildFeatureGrid(BuildContext context) {
    const features = [
      (Icons.score_rounded, 'Overall Score', 'Comprehensive 0–100 score with detailed section breakdown', AppColors.primary),
      (Icons.track_changes_rounded, 'ATS Check', 'How well your resume passes Applicant Tracking Systems', AppColors.accent),
      (Icons.lightbulb_outline_rounded, 'Smart Tips', 'Prioritized, actionable improvements to boost your score', AppColors.accentGold),
      (Icons.psychology_rounded, 'AI Insights', 'Deep analysis of strengths, gaps, and industry fit', AppColors.accentWarm),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("What you'll get", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 14),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 180,
          ),
          children: features.asMap().entries.map((e) {
            final f = e.value;
            return _FeatureCard(icon: f.$1, title: f.$2, desc: f.$3, color: f.$4)
                .animate().fadeIn(delay: (420 + e.key * 70).ms).slideY(begin: 0.1);
          }).toList(),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  final Color color;
  const _FeatureCard({required this.icon, required this.title, required this.desc, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 5),
          Text(desc, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45)),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 40)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 30),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms, color: AppColors.primaryDark.withValues(alpha: 0.5)),
              const SizedBox(height: 24),
              Text('Analyzing Resume', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Gemini AI is reviewing your resume...',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 180,
                child: LinearProgressIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.border,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }
}

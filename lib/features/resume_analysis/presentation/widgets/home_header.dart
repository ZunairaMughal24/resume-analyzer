import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
}

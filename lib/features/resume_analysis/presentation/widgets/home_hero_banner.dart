import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class HomeHeroBanner extends StatelessWidget {
  const HomeHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.15),
                AppColors.accent.withOpacity(0.05),
              ],
            ),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.accent, size: 14),
              const SizedBox(width: 8),
              Text(
                'AI-POWERED ANALYSIS',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.accent,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.05),
        const SizedBox(height: 18),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFD1FAE5),
              AppColors.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Optimize Your\nCareer Path',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  height: 1.05,
                  fontWeight: FontWeight.w600,
                  fontSize: 42,
                  color: Colors.white,
                ),
          ),
        ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.05),
        const SizedBox(height: 12),
        Text(
          'Get industry-standard insights and ATS optimization\nrecommendations tailored for your next big role.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                fontSize: 15,
              ),
        ).animate().fadeIn(delay: 260.ms),
      ],
    );
  }
}

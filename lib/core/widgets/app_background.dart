import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: AppColors.background)),

        Positioned(
          top: -300,
          right: -150,
          child: _GlowBlob(
            color: AppColors.primary.withOpacity(0.18),
            size: 700,
          ).animate(onPlay: (c) => c.repeat(reverse: true)).move(
              begin: const Offset(-50, -30),
              end: const Offset(30, 50),
              duration: 10.seconds,
              curve: Curves.easeInOutSine),
        ),

        Positioned(
          bottom: -200,
          left: -200,
          child: _GlowBlob(
            color: AppColors.accent.withOpacity(0.15),
            size: 800,
          ).animate(onPlay: (c) => c.repeat(reverse: true)).move(
              begin: const Offset(50, 30),
              end: const Offset(-30, -50),
              duration: 12.seconds,
              curve: Curves.easeInOutSine),
        ),

        Positioned(
          top: 200,
          left: -120,
          child: _GlowBlob(
            color: AppColors.primaryGlow.withOpacity(0.15),
            size: 500,
          ).animate(onPlay: (c) => c.repeat(reverse: true)).move(
              begin: const Offset(0, 0),
              end: const Offset(80, -80),
              duration: 8.seconds,
              curve: Curves.easeInOutSine),
        ),

        Positioned(
          bottom: 150,
          right: -150,
          child: _GlowBlob(
            color: AppColors.accentGold.withOpacity(0.06),
            size: 600,
          ).animate(onPlay: (c) => c.repeat(reverse: true)).move(
              begin: const Offset(-40, 40),
              end: const Offset(40, -40),
              duration: 15.seconds,
              curve: Curves.easeInOutSine),
        ),

        // Fine Grain / Noise Layer (Optional but adds premium feel)
        Positioned.fill(
          child: Opacity(
            opacity: 0.03,
            child: Image.network(
              'https://www.transparenttextures.com/patterns/stardust.png',
              repeat: ImageRepeat.repeat,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
        ),

        Positioned.fill(child: child),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
          stops: const [0.2, 1.0],
        ),
      ),
    );
  }
}

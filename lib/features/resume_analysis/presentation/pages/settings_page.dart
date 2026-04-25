import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:resume_analyzer/core/widgets/app_background.dart';
import 'package:resume_analyzer/core/widgets/glass_container.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Settings'),
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 15, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 110, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(title: 'About'),
              const SizedBox(height: 16),
              const _AboutCard()
                  .animate()
                  .fadeIn(delay: 150.ms)
                  .slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1.2,
            fontSize: 11,
          ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Version', '1.0.0'),
      ('AI Model', 'Gemini 1.5 Flash (Firebase)'),
    ];
    return GlassContainer(
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.value.$1,
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text(e.value.$2,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 1,
                    color: AppColors.border,
                    indent: 20,
                    endIndent: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}

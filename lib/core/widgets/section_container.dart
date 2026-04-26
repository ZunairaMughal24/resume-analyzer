import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class SectionContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  
  const SectionContainer({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  letterSpacing: 1.2,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
          child: SizedBox(
            width: double.infinity,
            child: child,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:resume_analyzer/core/widgets/section_container.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:resume_analyzer/features/ai_assistant/domain/entities/resume_analysis.dart';

class StrengthsWeaknessesCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const StrengthsWeaknessesCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Strengths & Weaknesses',
      icon: Icons.balance_rounded,
      child: Column(
        children: [
          _BulletList(
            items: analysis.strengths,
            color: AppColors.success,
            icon: Icons.check_circle_rounded,
            label: 'Strengths',
          ),
          if (analysis.weaknesses.isNotEmpty) ...[
            const SizedBox(height: 16),
            _BulletList(
              items: analysis.weaknesses,
              color: AppColors.error,
              icon: Icons.cancel_rounded,
              label: 'Weaknesses',
            ),
          ],
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  final Color color;
  final IconData icon;
  final String label;
  const _BulletList({required this.items, required this.color, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(item, style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
        )),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:resume_analyzer/core/widgets/section_container.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:resume_analyzer/features/ai_assistant/domain/entities/resume_analysis.dart';

class KeywordsCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const KeywordsCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Keywords',
      icon: Icons.tag_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (analysis.keywordsFound.isNotEmpty) ...[
            Text('Found', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.success)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: analysis.keywordsFound.map((k) => _Chip(k, AppColors.success)).toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (analysis.keywordsMissing.isNotEmpty) ...[
            Text('Missing', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.error)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: analysis.keywordsMissing.map((k) => _Chip(k, AppColors.error)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:resume_analyzer/features/ai_assistant/domain/entities/resume_analysis.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/widgets/info_card.dart';

class ExperienceCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const ExperienceCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      icon: Icons.workspace_premium_rounded,
      iconColor: AppColors.accentGold,
      title: 'Level',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            analysis.experienceLevel,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.accentGold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            analysis.industry,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.nunito(
                  color: AppColors.accentGold,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: '${analysis.keywordsFound.length} ',
                    style: GoogleFonts.geologica(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: 'Keywords'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

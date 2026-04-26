import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/resume_analysis.dart';
import 'info_card.dart';

class AtsCard extends StatelessWidget {
  final ResumeAnalysis analysis;
  const AtsCard({super.key, required this.analysis});

  Color get _color {
    if (analysis.atsScore >= 70) return AppColors.success;
    if (analysis.atsScore >= 45) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      icon: Icons.track_changes_rounded,
      iconColor: _color,
      title: 'ATS Score',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${analysis.atsScore}%',
            style: GoogleFonts.geologica(
              textStyle: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: _color,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Text(
            'Compatibility',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _color, fontSize: 10),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: analysis.atsScore / 100,
              backgroundColor: _color.withOpacity(0.15),
              color: _color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/resume_storage.dart';

class OriginalPdfViewer extends StatelessWidget {
  const OriginalPdfViewer({super.key});

  @override
  Widget build(BuildContext context) {
    if (ResumeStorage.currentPdfPath == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_rounded, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'Original PDF not available.\nPlease upload a PDF instead of pasting text.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return SfPdfViewer.file(
      File(ResumeStorage.currentPdfPath!),
      canShowScrollHead: false,
      enableDoubleTapZooming: true,
      pageSpacing: 4,
    );
  }
}

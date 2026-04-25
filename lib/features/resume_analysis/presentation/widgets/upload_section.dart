import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:resume_analyzer/core/widgets/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import 'dart:io';

class UploadSection extends StatefulWidget {
  final Function(String) onResumeExtracted;
  final String resumeText;

  const UploadSection({
    super.key,
    required this.onResumeExtracted,
    required this.resumeText,
  });

  @override
  State<UploadSection> createState() => _UploadSectionState();
}

class _UploadSectionState extends State<UploadSection> {
  String? _fileName;
  bool _isProcessing = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _fileName = file.name;
        _isProcessing = true;
      });

      try {
        String text = '';
        if (file.path != null) {
          if (file.name.endsWith('.pdf')) {
            final bytes = File(file.path!).readAsBytesSync();

            text = String.fromCharCodes(bytes.where((b) => b >= 32 && b < 127));
            if (text.trim().isEmpty) {
              text =
                  'PDF content extracted from: ${file.name}\n[Note: For best results, paste resume text directly below]';
            }
          } else {
            text = File(file.path!).readAsStringSync();
          }
        } else if (file.bytes != null) {
          text = String.fromCharCodes(file.bytes!);
        }

        widget.onResumeExtracted(text);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error reading file: $e'),
                backgroundColor: AppColors.error),
          );
        }
      }

      setState(() => _isProcessing = false);
    }
  }

  void _pasteText() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PasteTextSheet(
        onSubmit: (text) {
          widget.onResumeExtracted(text);
          setState(() => _fileName = 'Pasted text');
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasResume = widget.resumeText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Resume',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'PDF or TXT file • or paste your resume text',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _isProcessing ? null : _pickFile,
          child: DottedBorder(
            color: hasResume ? AppColors.accent : AppColors.border,
            strokeWidth: 1.5,
            dashPattern: const [8, 5],
            borderType: BorderType.RRect,
            radius: const Radius.circular(20),
            child: GlassContainer(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              borderRadius: 20,
              child: _isProcessing
                  ? const Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 12),
                        Text('Reading file...',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    )
                  : hasResume
                      ? Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.description_rounded,
                                  color: AppColors.accent),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _fileName ?? 'Resume loaded',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${widget.resumeText.split(' ').length} words',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppColors.accent),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.accent),
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.upload_file_rounded,
                                  color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(height: 14),
                            Text('Tap to upload resume',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text('Supports PDF and TXT files',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Center(
          child: TextButton.icon(
            onPressed: _pasteText,
            icon: const Icon(Icons.content_paste_rounded,
                size: 17, color: AppColors.primary),
            label: Text(
              'Or paste resume text',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppColors.primary, fontSize: 15),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1);
  }
}

class _PasteTextSheet extends StatefulWidget {
  final Function(String) onSubmit;
  const _PasteTextSheet({required this.onSubmit});

  @override
  State<_PasteTextSheet> createState() => _PasteTextSheetState();
}

class _PasteTextSheetState extends State<_PasteTextSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Paste Resume',
                  style: Theme.of(context).textTheme.headlineMedium),
              const Spacer(),
              IconButton(
                icon:
                    const Icon(Icons.close_rounded, color: AppColors.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 12,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Paste your resume text here...',
              filled: true,
              fillColor: AppColors.surfaceElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  widget.onSubmit(_controller.text.trim());
                }
              },
              child: const Text('Use This Resume'),
            ),
          ),
        ],
      ),
    );
  }
}

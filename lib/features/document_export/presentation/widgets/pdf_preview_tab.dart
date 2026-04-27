import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:resume_analyzer/features/document_export/domain/utils/resume_exporter.dart';
import 'package:resume_analyzer/features/resume_editor/presentation/bloc/editor_bloc.dart';

class PdfPreviewTab extends StatefulWidget {
  const PdfPreviewTab({super.key});

  @override
  State<PdfPreviewTab> createState() => _PdfPreviewTabState();
}

class _PdfPreviewTabState extends State<PdfPreviewTab> {
  Uint8List? _pdfBytes;
  bool _isGenerating = false;
  String? _lastRenderedKey;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Schedule after first frame so context.read is safe.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _regenerate();
    });
  }

  Future<void> _regenerate() async {
    if (!mounted) return;

    final state = context.read<EditorBloc>().state;

    // Build a cache key from the current data + font size.
    final dataKey = state.resumeData != null
        ? state.resumeData.hashCode.toString()
        : 'empty';
    final cacheKey = '${dataKey}_${state.pdfFontSize}';

    // Skip if already showing the same content.
    if (cacheKey == _lastRenderedKey && _pdfBytes != null) return;

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final Uint8List bytes;

      if (state.resumeData != null) {
        bytes = await ResumeExporter.generatePdfBytesFromData(
          state.resumeData!,
          baseFontSize: state.pdfFontSize,
        );
      } else {
        // Show a helpful placeholder when no polish has run yet.
        bytes = await ResumeExporter.generatePdfBytes(
          'No polished resume yet.\n\n'
          'Go to the Suggestions tab, choose your improvements, '
          'and tap "Apply Suggestions".',
          baseFontSize: state.pdfFontSize,
        );
      }

      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _lastRenderedKey = cacheKey;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _errorMessage = 'Could not render PDF:\n$e';
        });
      }
    }
  }

  Future<void> _savePdf(EditorState state) async {
    try {
      final file = await ResumeExporter.exportAsPdf(
        state.fileName,
        data: state.resumeData,
        resumeText: state.currentResumeText,
      );
      if (mounted && file != null) {
        _snack('PDF saved to Downloads ✓', isError: false);
      }
    } catch (e) {
      if (mounted) _snack('Failed to save: $e', isError: true);
    }
  }

  Future<void> _saveTxt(EditorState state) async {
    try {
      final file = await ResumeExporter.exportAsTxt(
        state.fileName,
        data: state.resumeData,
        resumeText: state.currentResumeText,
      );
      if (mounted && file != null) {
        _snack('TXT saved to Downloads ✓', isError: false);
      }
    } catch (e) {
      if (mounted) _snack('Failed to save: $e', isError: true);
    }
  }

  void _showSaveOptions(BuildContext context, EditorState state) {
    final controller = TextEditingController(text: state.fileName);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20,
            MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Save Document',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'File Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                context.read<EditorBloc>().add(RenameResume(val));
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('Save as PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.pop(bottomSheetContext);
                _savePdf(state);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.text_snippet_rounded),
              label: const Text('Save as Text (.txt)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.pop(bottomSheetContext);
                _saveTxt(state);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sharePdf(EditorState state) async {
    try {
      final file = await ResumeExporter.generateTempPdf(
        state.fileName,
        data: state.resumeData,
        resumeText: state.currentResumeText,
      );
      await ResumeExporter.shareFile(file);
    } catch (e) {
      if (mounted) _snack('Failed to share: $e', isError: true);
    }
  }

  void _snack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? AppColors.error : AppColors.success.withOpacity(0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditorBloc, EditorState>(
      listenWhen: (prev, curr) =>
          prev.resumeData != curr.resumeData ||
          prev.pdfFontSize != curr.pdfFontSize ||
          (prev.status == EditorStatus.polishing &&
              curr.status == EditorStatus.loaded),
      listener: (_, __) => _regenerate(),
      child: BlocBuilder<EditorBloc, EditorState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(child: _buildViewerArea()),
              _FontSizeControl(state: state),
              _PreviewActionBar(
                hasResume: state.resumeData != null,
                onSave: () => _showSaveOptions(context, state),
                onShare: () => _sharePdf(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildViewerArea() {
    // Error state
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text(
                'Error rendering preview',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _regenerate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Text('Try Again',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: AppColors.primary)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Loading state
    if (_isGenerating || _pdfBytes == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
                strokeWidth: 2.5, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Generating PDF preview…',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    // PDF ready
    return SfPdfViewer.memory(
      _pdfBytes!,
      canShowScrollHead: false,
      enableDoubleTapZooming: true,
      pageSpacing: 4,
    );
  }
}

class _FontSizeControl extends StatelessWidget {
  final EditorState state;
  const _FontSizeControl({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: AppColors.border.withOpacity(0.5)),
          bottom: BorderSide(color: AppColors.border.withOpacity(0.3)),
        ),
      ),
      child: Row(children: [
        const Icon(Icons.format_size_rounded,
            size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          'Text Size',
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: state.pdfFontSize,
              min: 8.0,
              max: 14.0,
              divisions: 12,
              onChanged: (val) =>
                  context.read<EditorBloc>().add(UpdatePdfFontSize(val)),
            ),
          ),
        ),
        Text(
          '${state.pdfFontSize.toStringAsFixed(1)}pt',
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ]),
    );
  }
}

class _PreviewActionBar extends StatelessWidget {
  final bool hasResume;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const _PreviewActionBar({
    required this.hasResume,
    required this.onSave,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.97),
        border:
            Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
      ),
      child: Row(children: [
        // Save PDF button (primary, gradient)
        Expanded(
          child: GestureDetector(
            onTap: hasResume ? onSave : null,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: hasResume
                    ? const LinearGradient(colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ])
                    : null,
                color: hasResume ? null : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                boxShadow: hasResume
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.save_alt_rounded,
                      size: 18,
                      color: hasResume ? Colors.white : AppColors.textMuted),
                  const SizedBox(width: 8),
                  Text(
                    'Save PDF',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: hasResume ? Colors.white : AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                  ),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Share PDF button (secondary, outlined)
        Expanded(
          child: GestureDetector(
            onTap: hasResume ? onShare : null,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasResume
                      ? AppColors.border
                      : AppColors.border.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.share_rounded,
                      size: 18,
                      color: hasResume
                          ? AppColors.textPrimary
                          : AppColors.textMuted),
                  const SizedBox(width: 8),
                  Text(
                    'Share PDF',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: hasResume
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

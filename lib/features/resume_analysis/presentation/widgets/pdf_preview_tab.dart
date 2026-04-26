import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/resume_exporter.dart';
import '../bloc/editor_bloc.dart';

class PdfPreviewTab extends StatefulWidget {
  const PdfPreviewTab({super.key});

  @override
  State<PdfPreviewTab> createState() => _PdfPreviewTabState();
}

class _PdfPreviewTabState extends State<PdfPreviewTab> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _lastRenderedKey;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _regenerateIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditorBloc, EditorState>(
      listenWhen: (p, c) =>
          p.resumeData != c.resumeData ||
          p.originalResumeText != c.originalResumeText ||
          p.pdfFontSize != c.pdfFontSize,
      listener: (_, __) => _regenerateIfNeeded(),
      child: _buildBody(),
    );
  }

  Future<void> _regenerateIfNeeded() async {
    final state = context.read<EditorBloc>().state;

    final baseKey = state.resumeData != null
        ? state.resumeData.hashCode.toString()
        : state.originalResumeText.hashCode.toString();
    final cacheKey = '${baseKey}_${state.pdfFontSize}';

    if (cacheKey == _lastRenderedKey) {
      if (_isLoading && _pdfBytes != null) {
        setState(() => _isLoading = false);
      }
      return;
    }

    if (!_isLoading) setState(() => _isLoading = true);

    try {
      final Uint8List bytes;
      if (state.resumeData != null) {
        bytes = await ResumeExporter.generatePdfBytesFromData(
          state.resumeData!,
          baseFontSize: state.pdfFontSize,
        );
      } else {
        bytes = await ResumeExporter.generatePdfBytes(
          'No polished resume yet.\n\nGo to the Suggestions tab, accept improvements, then tap "Polish with AI" to generate your clean ATS resume.',
          baseFontSize: state.pdfFontSize,
        );
      }

      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _lastRenderedKey = cacheKey;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Widget _buildBody() {
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
            ],
          ),
        ),
      );
    }

    if (_isLoading || _pdfBytes == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
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

    return Stack(
      children: [
        SfPdfViewer.memory(
          _pdfBytes!,
          canShowScrollHead: false,
          enableDoubleTapZooming: true,
          pageSpacing: 4,
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: _buildFontSizeControl(),
        ),
      ],
    );
  }

  Widget _buildFontSizeControl() {
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.format_size_rounded,
                  size: 18, color: AppColors.textMuted),
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
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: state.pdfFontSize,
                    min: 8.0,
                    max: 14.0,
                    divisions: 12,
                    onChanged: (val) {
                      context.read<EditorBloc>().add(UpdatePdfFontSize(val));
                    },
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
            ],
          ),
        );
      },
    );
  }
}

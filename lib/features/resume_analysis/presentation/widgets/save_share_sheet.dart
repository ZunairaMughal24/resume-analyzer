import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/resume_exporter.dart';
import '../../domain/entities/resume_data.dart';

class SaveShareSheet extends StatefulWidget {
  final String resumeText;
  final ResumeData? resumeData;
  final String fileName;
  final ValueChanged<String> onRename;

  const SaveShareSheet({
    super.key,
    required this.resumeText,
    this.resumeData,
    required this.fileName,
    required this.onRename,
  });

  @override
  State<SaveShareSheet> createState() => _SaveShareSheetState();
}

class _SaveShareSheetState extends State<SaveShareSheet> {
  bool _isBusy = false;

  Future<void> _exportPdf() async {
    setState(() {
      _isBusy = true;
    });
    try {
      final file = await ResumeExporter.exportAsPdf(
        widget.fileName,
        data: widget.resumeData,
        resumeText: widget.resumeText,
      );
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
        if (file != null) _showSuccess('PDF saved successfully');
      }
    } catch (e, stacktrace) {
      debugPrint('ERROR in _exportPdf: $e\n$stacktrace');
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
        _showError('Failed to export PDF: $e');
      }
    }
  }

  Future<void> _exportTxt() async {
    setState(() {
      _isBusy = true;
    });
    try {
      final file = await ResumeExporter.exportAsTxt(
        widget.fileName,
        data: widget.resumeData,
        resumeText: widget.resumeText,
      );
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
        if (file != null) _showSuccess('TXT saved successfully');
      }
    } catch (e, stacktrace) {
      debugPrint('ERROR in _exportTxt: $e\n$stacktrace');
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
        _showError('Failed to export TXT: $e');
      }
    }
  }

  Future<void> _sharePdf() async {
    setState(() {
      _isBusy = true;
    });
    try {
      final file = await ResumeExporter.generateTempPdf(
        widget.fileName,
        data: widget.resumeData,
        resumeText: widget.resumeText,
      );
      await ResumeExporter.shareFile(file);
      if (mounted) {
        setState(() => _isBusy = false);
      }
    } catch (e, stacktrace) {
      debugPrint('ERROR in _sharePdf: $e\n$stacktrace');
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
        _showError('Failed to share: $e');
      }
    }
  }

  Future<void> _shareText() async {
    setState(() {
      _isBusy = true;
    });
    try {
      final text = widget.resumeData?.toPlainText() ?? widget.resumeText;
      await ResumeExporter.shareText(text);
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    } catch (e, stacktrace) {
      debugPrint('ERROR in _shareText: $e\n$stacktrace');
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
        _showError('Failed to share text: $e');
      }
    }
  }

  void _rename() {
    final controller = TextEditingController(text: widget.fileName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Rename Resume', style: Theme.of(ctx).textTheme.titleLarge),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: Theme.of(ctx)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter file name',
            filled: true,
            fillColor: AppColors.surfaceElevated,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2)),
          ),
          cursorColor: AppColors.primary,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                widget.onRename(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    controller.dispose;
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.success.withOpacity(0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 8, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle bar
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        // Title
        Row(children: [
          Text('Save & Share',
              style: Theme.of(context).textTheme.headlineMedium),
          const Spacer(),
          if (_isBusy)
            const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary)),
        ]),
        const SizedBox(height: 6),
        Text('Export your polished resume',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 24),
        // Action buttons
        _ActionTile(
            icon: Icons.picture_as_pdf_rounded,
            color: AppColors.error,
            title: 'Save as PDF',
            subtitle: 'Professional formatted document',
            onTap: _isBusy ? null : _exportPdf),
        const SizedBox(height: 10),
        _ActionTile(
            icon: Icons.text_snippet_rounded,
            color: AppColors.primary,
            title: 'Save as TXT',
            subtitle: 'Plain text file',
            onTap: _isBusy ? null : _exportTxt),
        const SizedBox(height: 10),
        _ActionTile(
            icon: Icons.share_rounded,
            color: AppColors.accent,
            title: 'Share as PDF',
            subtitle: 'Send via any app',
            onTap: _isBusy ? null : _sharePdf),
        const SizedBox(height: 10),
        _ActionTile(
            icon: Icons.text_fields_rounded,
            color: AppColors.accentGold,
            title: 'Share as Text',
            subtitle: 'Copy-paste friendly',
            onTap: _isBusy ? null : _shareText),
        const SizedBox(height: 10),
        _ActionTile(
            icon: Icons.drive_file_rename_outline_rounded,
            color: AppColors.accentWarm,
            title: 'Rename',
            subtitle: widget.fileName,
            onTap: _rename),
        const SizedBox(height: 16),
      ]),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionTile(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textMuted, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ])),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted.withOpacity(0.5), size: 20),
        ]),
      ),
    );
  }
}

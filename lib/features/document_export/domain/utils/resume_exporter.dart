import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:resume_analyzer/features/resume_editor/domain/entities/resume_data.dart';
import 'package:file_picker/file_picker.dart';
import 'package:resume_analyzer/features/document_export/domain/utils/pdf/pdf_generator.dart';

class ResumeExporter {
  /// Generates a clean ATS PDF from structured [ResumeData].
  static Future<Uint8List> generatePdfBytesFromData(
    ResumeData data, {
    double baseFontSize = 10.0,
  }) async {
    return PdfGenerator.generatePdfBytesFromData(data,
        baseFontSize: baseFontSize);
  }

  /// Legacy overload
  static Future<Uint8List> generatePdfBytes(String resumeText,
      {double baseFontSize = 10.0}) async {
    return PdfGenerator.generatePdfBytes(resumeText,
        baseFontSize: baseFontSize);
  }

  static Future<String?> _getDownloadPath() async {
    try {
      if (Platform.isIOS) {
        final dir = await getApplicationDocumentsDirectory();
        return dir.path;
      } else {
        // Try standard Android Downloads folder
        final dir = Directory('/storage/emulated/0/Download');
        if (await dir.exists()) return dir.path;

        final extDir = await getExternalStorageDirectory();
        return extDir?.path;
      }
    } catch (e) {
      return null;
    }
  }

  // File export
  static Future<File?> exportAsPdf(String fileName,
      {ResumeData? data, String? resumeText}) async {
    final Uint8List bytes;
    if (data != null) {
      bytes = await generatePdfBytesFromData(data);
    } else {
      bytes = await generatePdfBytes(resumeText ?? '');
    }

    final sanitizedName = fileName.replaceAll(RegExp(r'[^\w\s-]'), '');
    final path = await _getDownloadPath();
    if (path == null) {
      // Fallback to share if we can't get a save path
      final file =
          await generateTempPdf(fileName, data: data, resumeText: resumeText);
      await shareFile(file);
      return file;
    }

    final file = File('$path/$sanitizedName.pdf');
    await file.writeAsBytes(bytes);
    if (kDebugMode) print('📄 PDF saved directly to: ${file.path}');
    return file;
  }

  static Future<File> generateTempPdf(String fileName,
      {ResumeData? data, String? resumeText}) async {
    final Uint8List bytes;
    if (data != null) {
      bytes = await generatePdfBytesFromData(data);
    } else {
      bytes = await generatePdfBytes(resumeText ?? '');
    }
    final dir = await getTemporaryDirectory();
    final sanitizedName = fileName.replaceAll(RegExp(r'[^\w\s-]'), '');
    final file = File('${dir.path}/$sanitizedName.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Exports the resume as a plain TXT file
  static Future<File?> exportAsTxt(String fileName,
      {ResumeData? data, String? resumeText}) async {
    final text = data?.toPlainText() ?? resumeText ?? '';

    final sanitizedName = fileName.replaceAll(RegExp(r'[^\w\s-]'), '');
    final path = await _getDownloadPath();
    if (path == null) {
      // Fallback to share
      await shareText(text);
      return null;
    }

    final file = File('$path/$sanitizedName.txt');
    await file.writeAsString(text);
    if (kDebugMode) print('📝 TXT saved directly to: ${file.path}');
    return file;
  }

  /// Shares a file using the system share sheet.
  static Future<void> shareFile(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'My Polished Resume',
    );
  }

  /// Shares resume text directly without creating a file.
  static Future<void> shareText(String text) async {
    await Share.share(
      text,
      subject: 'My Polished Resume',
    );
  }
}

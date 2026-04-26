import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import '../../features/resume_analysis/domain/entities/resume_data.dart';
import 'package:file_picker/file_picker.dart';
import 'pdf/pdf_generator.dart';

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

  // ─── File export
  static Future<File?> exportAsPdf(String fileName,
      {ResumeData? data, String? resumeText}) async {
    final Uint8List bytes;
    if (data != null) {
      bytes = await generatePdfBytesFromData(data);
    } else {
      bytes = await generatePdfBytes(resumeText ?? '');
    }

    final sanitizedName = fileName.replaceAll(RegExp(r'[^\w\s-]'), '');
    final String? savePath = await FilePicker.saveFile(
      dialogTitle: 'Save Resume as PDF',
      fileName: '$sanitizedName.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (savePath == null) return null;

    final file = File(savePath);
    await file.writeAsBytes(bytes);
    if (kDebugMode) print('📄 PDF saved to: ${file.path}');
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
    final String? savePath = await FilePicker.saveFile(
      dialogTitle: 'Save Resume as TXT',
      fileName: '$sanitizedName.txt',
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (savePath == null) return null;

    final file = File(savePath);
    await file.writeAsString(text);
    if (kDebugMode) print('📝 TXT saved to: ${file.path}');
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

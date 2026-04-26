import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import '../../features/resume_analysis/domain/entities/resume_data.dart';

class ResumeExporter {
  // ─── Colour palette for the PDF
  static const PdfColor _black = PdfColors.black;
  static const PdfColor _grey600 = PdfColors.grey600;
  static const PdfColor _grey800 = PdfColors.grey800;
  static const PdfColor _sectionLine = PdfColors.grey400;

  /// Generates a clean ATS PDF from structured [ResumeData].
  static Future<Uint8List> generatePdfBytesFromData(
    ResumeData data, {
    double baseFontSize = 10.0,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.symmetric(horizontal: 52, vertical: 48),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
          italic: pw.Font.helveticaOblique(),
          boldItalic: pw.Font.helveticaBoldOblique(),
        ),
        build: (ctx) => _buildContent(data, baseFontSize),
      ),
    );
    return pdf.save();
  }

  /// Legacy overload
  static Future<Uint8List> generatePdfBytes(String resumeText,
      {double baseFontSize = 10.0}) async {
    final minimal = ResumeData(
      fullName: '',
      contact: const ResumeContact(),
      summary: resumeText,
    );
    return generatePdfBytesFromData(minimal, baseFontSize: baseFontSize);
  }

  // ─── PDF Content Builder
  static List<pw.Widget> _buildContent(ResumeData data, double baseFontSize) {
    final widgets = <pw.Widget>[];

    // ── Name
    if (data.fullName.isNotEmpty) {
      widgets.add(
        pw.Center(
          child: pw.Text(
            data.fullName.toUpperCase(),
            style: pw.TextStyle(
              fontSize: baseFontSize + 10,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1.5,
              color: _black,
            ),
          ),
        ),
      );
      widgets.add(pw.SizedBox(height: 4));
    }

    // ── Contact line
    final contactWidgets = <pw.Widget>[];

    void addContactItem(String text, {String? url}) {
      if (contactWidgets.isNotEmpty) {
        contactWidgets.add(
          pw.Text('  |  ',
              style: pw.TextStyle(fontSize: baseFontSize - 1, color: _grey800)),
        );
      }

      final textWidget = pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: baseFontSize - 1,
          color: url != null ? PdfColors.blue800 : _grey800,
          decoration: url != null
              ? pw.TextDecoration.underline
              : pw.TextDecoration.none,
        ),
      );

      if (url != null) {
        contactWidgets.add(pw.UrlLink(destination: url, child: textWidget));
      } else {
        contactWidgets.add(textWidget);
      }
    }

    if (data.contact.email.isNotEmpty) {
      addContactItem(data.contact.email,
          url: 'mailto:${data.contact.email.trim()}');
    }
    if (data.contact.phone.isNotEmpty) {
      addContactItem(data.contact.phone);
    }
    if (data.contact.location.isNotEmpty) {
      addContactItem(data.contact.location);
    }
    if (data.contact.linkedin.isNotEmpty) {
      addContactItem(data.contact.linkedin,
          url: _ensureHttps(data.contact.linkedin.trim()));
    }
    if (data.contact.github.isNotEmpty) {
      addContactItem(data.contact.github,
          url: _ensureHttps(data.contact.github.trim()));
    }
    if (data.contact.website.isNotEmpty) {
      addContactItem(data.contact.website,
          url: _ensureHttps(data.contact.website.trim()));
    }

    if (contactWidgets.isNotEmpty) {
      widgets.add(
        pw.Center(
          child: pw.Wrap(
            alignment: pw.WrapAlignment.center,
            crossAxisAlignment: pw.WrapCrossAlignment.center,
            children: contactWidgets,
          ),
        ),
      );
    }

    widgets.add(pw.SizedBox(height: 10));

    // ── Summary
    if (data.summary.isNotEmpty) {
      widgets.add(_sectionHeader('Professional Summary', baseFontSize));
      widgets.add(
        pw.Text(
          _sanitize(data.summary),
          style: pw.TextStyle(
              fontSize: baseFontSize, color: _grey800, lineSpacing: 2),
        ),
      );
      widgets.add(pw.SizedBox(height: 8));
    }

    // ── Experience
    if (data.experience.isNotEmpty) {
      widgets.add(_sectionHeader('Experience', baseFontSize));
      for (final exp in data.experience) {
        widgets.add(_experienceBlock(exp, baseFontSize));
      }
    }

    // ── Education
    if (data.education.isNotEmpty) {
      widgets.add(_sectionHeader('Education', baseFontSize));
      for (final edu in data.education) {
        widgets.add(_educationBlock(edu, baseFontSize));
      }
    }

    // ── Skills
    if (data.skills.isNotEmpty) {
      widgets.add(_sectionHeader('Skills', baseFontSize));

      final skillWidgets = data.skills
          .map((s) => pw.Padding(
              padding: const pw.EdgeInsets.only(right: 12, bottom: 4),
              child: pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
                pw.Container(
                  width: 3,
                  height: 3,
                  margin: const pw.EdgeInsets.only(right: 4, top: 1),
                  decoration: const pw.BoxDecoration(
                      color: _black, shape: pw.BoxShape.circle),
                ),
                pw.Text(_sanitize(s),
                    style:
                        pw.TextStyle(fontSize: baseFontSize, color: _grey800)),
              ])))
          .toList();

      widgets.add(
        pw.Wrap(
          children: skillWidgets,
        ),
      );
      widgets.add(pw.SizedBox(height: 8));
    }

    // ── Projects
    if (data.projects.isNotEmpty) {
      widgets.add(_sectionHeader('Projects', baseFontSize));
      for (final proj in data.projects) {
        widgets.add(_projectBlock(proj, baseFontSize));
      }
    }

    // ── Certifications
    if (data.certifications.isNotEmpty) {
      widgets.add(_sectionHeader('Certifications', baseFontSize));
      for (final cert in data.certifications) {
        widgets.add(_bulletRow(_sanitize(cert), baseFontSize));
      }
      widgets.add(pw.SizedBox(height: 8));
    }

    // ── Languages
    if (data.languages.isNotEmpty) {
      widgets.add(_sectionHeader('Languages', baseFontSize));

      final langWidgets = data.languages
          .map((l) => pw.Padding(
              padding: const pw.EdgeInsets.only(right: 12, bottom: 4),
              child: pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
                pw.Container(
                  width: 3,
                  height: 3,
                  margin: const pw.EdgeInsets.only(right: 4, top: 1),
                  decoration: const pw.BoxDecoration(
                      color: _black, shape: pw.BoxShape.circle),
                ),
                pw.Text(_sanitize(l),
                    style:
                        pw.TextStyle(fontSize: baseFontSize, color: _grey800)),
              ])))
          .toList();

      widgets.add(pw.Wrap(children: langWidgets));
    }

    return widgets;
  }

  // ─── Section helpers ─────────────────────────────────────────────────────

  static pw.Widget _sectionHeader(String title, double baseFontSize) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: _sectionLine, width: 0.75),
            ),
          ),
          padding: const pw.EdgeInsets.only(bottom: 2),
          margin: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: baseFontSize + 0.5,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.8,
              color: _black,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _experienceBlock(ExperienceEntry exp, double baseFontSize) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Title | Company row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  _sanitize(exp.title),
                  style: pw.TextStyle(
                    fontSize: baseFontSize + 0.5,
                    fontWeight: pw.FontWeight.bold,
                    color: _black,
                  ),
                ),
              ),
              if (exp.dates.isNotEmpty)
                pw.Text(
                  _sanitize(exp.dates),
                  style: pw.TextStyle(
                      fontSize: baseFontSize - 0.5,
                      color: _grey600,
                      fontStyle: pw.FontStyle.italic),
                ),
            ],
          ),
          // Company | Location row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                _sanitize(exp.company),
                style: pw.TextStyle(
                  fontSize: baseFontSize,
                  fontStyle: pw.FontStyle.italic,
                  color: _grey800,
                ),
              ),
              if (exp.location.isNotEmpty)
                pw.Text(
                  _sanitize(exp.location),
                  style:
                      pw.TextStyle(fontSize: baseFontSize - 1, color: _grey600),
                ),
            ],
          ),
          pw.SizedBox(height: 3),
          // Bullet points
          ...exp.bullets.map((b) => _bulletRow(_sanitize(b), baseFontSize)),
        ],
      ),
    );
  }

  static pw.Widget _educationBlock(EducationEntry edu, double baseFontSize) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  _sanitize(edu.degree),
                  style: pw.TextStyle(
                      fontSize: baseFontSize + 0.5,
                      fontWeight: pw.FontWeight.bold),
                ),
              ),
              if (edu.dates.isNotEmpty)
                pw.Text(
                  _sanitize(edu.dates),
                  style: pw.TextStyle(
                      fontSize: baseFontSize - 0.5,
                      color: _grey600,
                      fontStyle: pw.FontStyle.italic),
                ),
            ],
          ),
          pw.Text(
            _sanitize(edu.institution),
            style: pw.TextStyle(
                fontSize: baseFontSize,
                fontStyle: pw.FontStyle.italic,
                color: _grey800),
          ),
          if (edu.details.isNotEmpty)
            pw.Text(
              _sanitize(edu.details),
              style:
                  pw.TextStyle(fontSize: baseFontSize - 0.5, color: _grey600),
            ),
        ],
      ),
    );
  }

  static pw.Widget _projectBlock(ProjectEntry proj, double baseFontSize) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _sanitize(proj.name),
            style: pw.TextStyle(
                fontSize: baseFontSize + 0.5, fontWeight: pw.FontWeight.bold),
          ),
          if (proj.description.isNotEmpty)
            pw.Text(
              _sanitize(proj.description),
              style: pw.TextStyle(fontSize: baseFontSize, color: _grey800),
            ),
          ...proj.bullets.map((b) => _bulletRow(_sanitize(b), baseFontSize)),
        ],
      ),
    );
  }

  static pw.Widget _bulletRow(String text, double baseFontSize) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 10, bottom: 2, top: 1),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(right: 6, top: 4),
            child: pw.Container(
              width: 3,
              height: 3,
              decoration: const pw.BoxDecoration(
                color: _black,
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(
                  fontSize: baseFontSize, lineSpacing: 1.5, color: _grey800),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Text sanitization ────────────────────────────────────────────────────

  static String _sanitize(String text) {
    return text
        .replaceAll('\u00A0', ' ')
        .replaceAll('\u2014', '-')
        .replaceAll('\u2013', '-')
        .replaceAll('\u201C', '"')
        .replaceAll('\u201D', '"')
        .replaceAll('\u2018', "'")
        .replaceAll('\u2019', "'")
        .replaceAll('\u2022', '-')
        .replaceAll(RegExp(r'[^\x00-\x7F]+'), '');
  }

  static String _ensureHttps(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return 'https://$url';
  }

  // ─── File export
  static Future<File> exportAsPdf(String fileName,
      {ResumeData? data, String? resumeText}) async {
    final Uint8List bytes;
    if (data != null) {
      bytes = await generatePdfBytesFromData(data);
    } else {
      bytes = await generatePdfBytes(resumeText ?? '');
    }
    final dir = await getApplicationDocumentsDirectory();
    final sanitizedName = fileName.replaceAll(RegExp(r'[^\w\s-]'), '');
    final file = File('${dir.path}/$sanitizedName.pdf');
    await file.writeAsBytes(bytes);
    if (kDebugMode) print('📄 PDF saved to: ${file.path}');
    return file;
  }

  /// Exports the resume as a plain TXT file (uses ResumeData.toPlainText or raw string).
  static Future<File> exportAsTxt(String fileName,
      {ResumeData? data, String? resumeText}) async {
    final text = data?.toPlainText() ?? resumeText ?? '';
    final dir = await getApplicationDocumentsDirectory();
    final sanitizedName = fileName.replaceAll(RegExp(r'[^\w\s-]'), '');
    final file = File('${dir.path}/$sanitizedName.txt');
    await file.writeAsString(text);
    if (kDebugMode) print('📝 TXT saved to: ${file.path}');
    return file;
  }

  /// Shares a file using the system share sheet.
  static Future<void> shareFile(File file) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'My Polished Resume',
      ),
    );
  }

  /// Shares resume text directly without creating a file.
  static Future<void> shareText(String text) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: 'My Polished Resume',
      ),
    );
  }
}

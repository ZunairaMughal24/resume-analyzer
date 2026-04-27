import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:resume_analyzer/features/resume_editor/domain/entities/resume_data.dart';
import 'pdf_formatters.dart';
import 'pdf_components.dart';

class PdfGenerator {
  static const PdfColor _black = PdfColors.black;
  static const PdfColor _grey800 = PdfColors.grey800;

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

  static Future<Uint8List> generatePdfBytes(String resumeText,
      {double baseFontSize = 10.0}) async {
    final minimal = ResumeData(
      fullName: '',
      contact: const ResumeContact(),
      summary: resumeText,
    );
    return generatePdfBytesFromData(minimal, baseFontSize: baseFontSize);
  }

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
          url: PdfFormatters.ensureHttps(data.contact.linkedin.trim()));
    }
    if (data.contact.github.isNotEmpty) {
      addContactItem(data.contact.github,
          url: PdfFormatters.ensureHttps(data.contact.github.trim()));
    }
    if (data.contact.website.isNotEmpty) {
      addContactItem(data.contact.website,
          url: PdfFormatters.ensureHttps(data.contact.website.trim()));
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
      widgets.add(PdfComponents.sectionHeader('Professional Summary', baseFontSize));
      widgets.add(
        PdfFormatters.buildTextWithLinks(
          PdfFormatters.sanitize(data.summary),
          pw.TextStyle(
              fontSize: baseFontSize, color: _grey800, lineSpacing: 2),
        ),
      );
      widgets.add(pw.SizedBox(height: 8));
    }

    // ── Experience
    if (data.experience.isNotEmpty) {
      widgets.add(PdfComponents.sectionHeader('Experience', baseFontSize));
      for (final exp in data.experience) {
        widgets.add(PdfComponents.experienceBlock(exp, baseFontSize));
      }
    }

    // ── Education
    if (data.education.isNotEmpty) {
      widgets.add(PdfComponents.sectionHeader('Education', baseFontSize));
      for (final edu in data.education) {
        widgets.add(PdfComponents.educationBlock(edu, baseFontSize));
      }
    }

    // ── Skills
    if (data.skills.isNotEmpty) {
      widgets.add(PdfComponents.sectionHeader('Skills', baseFontSize));

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
                pw.Text(PdfFormatters.sanitize(s),
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
      widgets.add(PdfComponents.sectionHeader('Projects', baseFontSize));
      for (final proj in data.projects) {
        widgets.add(PdfComponents.projectBlock(proj, baseFontSize));
      }
    }

    // ── Certifications
    if (data.certifications.isNotEmpty) {
      widgets.add(PdfComponents.sectionHeader('Certifications', baseFontSize));
      for (final cert in data.certifications) {
        widgets.add(PdfComponents.bulletRow(PdfFormatters.sanitize(cert), baseFontSize));
      }
      widgets.add(pw.SizedBox(height: 8));
    }

    // ── Languages
    if (data.languages.isNotEmpty) {
      widgets.add(PdfComponents.sectionHeader('Languages', baseFontSize));

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
                pw.Text(PdfFormatters.sanitize(l),
                    style:
                        pw.TextStyle(fontSize: baseFontSize, color: _grey800)),
              ])))
          .toList();

      widgets.add(pw.Wrap(children: langWidgets));
    }

    return widgets;
  }
}

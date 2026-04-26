import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../features/resume_analysis/domain/entities/resume_data.dart';
import 'pdf_formatters.dart';

class PdfComponents {
  static const PdfColor _black = PdfColors.black;
  static const PdfColor _grey600 = PdfColors.grey600;
  static const PdfColor _grey800 = PdfColors.grey800;
  static const PdfColor _sectionLine = PdfColors.grey400;

  static pw.Widget sectionHeader(String title, double baseFontSize) {
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

  static pw.Widget experienceBlock(ExperienceEntry exp, double baseFontSize) {
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
                  PdfFormatters.sanitize(exp.title),
                  style: pw.TextStyle(
                    fontSize: baseFontSize + 0.5,
                    fontWeight: pw.FontWeight.bold,
                    color: _black,
                  ),
                ),
              ),
              if (exp.dates.isNotEmpty)
                pw.Text(
                  PdfFormatters.sanitize(exp.dates),
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
                PdfFormatters.sanitize(exp.company),
                style: pw.TextStyle(
                  fontSize: baseFontSize,
                  fontStyle: pw.FontStyle.italic,
                  color: _grey800,
                ),
              ),
              if (exp.location.isNotEmpty)
                pw.Text(
                  PdfFormatters.sanitize(exp.location),
                  style:
                      pw.TextStyle(fontSize: baseFontSize - 1, color: _grey600),
                ),
            ],
          ),
          pw.SizedBox(height: 3),
          // Bullet points
          ...exp.bullets.map((b) => bulletRow(PdfFormatters.sanitize(b), baseFontSize)),
        ],
      ),
    );
  }

  static pw.Widget educationBlock(EducationEntry edu, double baseFontSize) {
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
                  PdfFormatters.sanitize(edu.degree),
                  style: pw.TextStyle(
                      fontSize: baseFontSize + 0.5,
                      fontWeight: pw.FontWeight.bold),
                ),
              ),
              if (edu.dates.isNotEmpty)
                pw.Text(
                  PdfFormatters.sanitize(edu.dates),
                  style: pw.TextStyle(
                      fontSize: baseFontSize - 0.5,
                      color: _grey600,
                      fontStyle: pw.FontStyle.italic),
                ),
            ],
          ),
          pw.Text(
            PdfFormatters.sanitize(edu.institution),
            style: pw.TextStyle(
                fontSize: baseFontSize,
                fontStyle: pw.FontStyle.italic,
                color: _grey800),
          ),
          if (edu.details.isNotEmpty)
            PdfFormatters.buildTextWithLinks(
              PdfFormatters.sanitize(edu.details),
              pw.TextStyle(fontSize: baseFontSize - 0.5, color: _grey600),
            ),
        ],
      ),
    );
  }

  static pw.Widget projectBlock(ProjectEntry proj, double baseFontSize) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(
                child: pw.Text(
                  PdfFormatters.sanitize(proj.name),
                  style: pw.TextStyle(
                      fontSize: baseFontSize + 0.5, fontWeight: pw.FontWeight.bold),
                ),
              ),
              if (proj.link.isNotEmpty)
                pw.UrlLink(
                  destination: PdfFormatters.ensureHttps(proj.link.trim()),
                  child: pw.Text(
                    'Link',
                    style: pw.TextStyle(
                      fontSize: baseFontSize - 0.5,
                      color: PdfColors.blue800,
                      decoration: pw.TextDecoration.underline,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
          if (proj.description.isNotEmpty)
            PdfFormatters.buildTextWithLinks(
              PdfFormatters.sanitize(proj.description),
              pw.TextStyle(fontSize: baseFontSize, color: _grey800),
            ),
          ...proj.bullets.map((b) => bulletRow(PdfFormatters.sanitize(b), baseFontSize)),
        ],
      ),
    );
  }

  static pw.Widget bulletRow(String text, double baseFontSize) {
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
            child: PdfFormatters.buildTextWithLinks(
              text,
              pw.TextStyle(
                  fontSize: baseFontSize, lineSpacing: 1.5, color: _grey800),
            ),
          ),
        ],
      ),
    );
  }
}

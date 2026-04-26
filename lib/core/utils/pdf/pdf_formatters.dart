import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfFormatters {
  static pw.Widget buildTextWithLinks(String text, pw.TextStyle baseStyle) {
    // Matches http://, https://, www. and github.com/ / linkedin.com/
    final urlRegex = RegExp(
      r'(https?://[^\s()<>]+|www\.[^\s()<>]+|github\.com/[^\s()<>]+|linkedin\.com/in/[^\s()<>]+)',
      caseSensitive: false,
    );

    final matches = urlRegex.allMatches(text);
    if (matches.isEmpty) {
      return pw.Text(text, style: baseStyle);
    }

    final spans = <pw.InlineSpan>[];
    int currentPosition = 0;

    for (final match in matches) {
      if (match.start > currentPosition) {
        spans.add(
            pw.TextSpan(text: text.substring(currentPosition, match.start)));
      }
      final matchedUrl = match.group(0)!;
      // Strip trailing punctuation like commas or periods
      String cleanUrl = matchedUrl;
      if (cleanUrl.endsWith('.') ||
          cleanUrl.endsWith(',') ||
          cleanUrl.endsWith(';')) {
        cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
      }

      final url = cleanUrl.startsWith('http') ? cleanUrl : 'https://$cleanUrl';

      spans.add(
        pw.TextSpan(
          text: cleanUrl,
          style: baseStyle.copyWith(
              color: PdfColors.blue800,
              decoration: pw.TextDecoration.underline),
          annotation: pw.AnnotationUrl(url),
        ),
      );

      // If we stripped punctuation, add it back as normal text
      if (cleanUrl.length < matchedUrl.length) {
        spans.add(pw.TextSpan(text: matchedUrl.substring(cleanUrl.length)));
      }

      currentPosition = match.end;
    }

    if (currentPosition < text.length) {
      spans.add(pw.TextSpan(text: text.substring(currentPosition)));
    }

    return pw.RichText(text: pw.TextSpan(style: baseStyle, children: spans));
  }

  static String sanitize(String text) {
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

  static String ensureHttps(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return 'https://$url';
  }
}

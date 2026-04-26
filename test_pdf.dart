import 'package:syncfusion_flutter_pdf/pdf.dart';
void main() {
  final doc = PdfDocument();
  final ext = PdfTextExtractor(doc);
  // How to extract text with layout?
  ext.extractText(layoutText: true);
}

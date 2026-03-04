import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Extracts amount (DH) and reference code from receipt image using ML Kit.
/// Used on Android/iOS only; web uses stub.
Future<({double? amount, String? reference})> extractFromReceiptImage(
  String imagePath,
) async {
  try {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    final fullText = recognizedText.text;
    if (fullText.isEmpty) return (amount: null, reference: null);

    double? amount = _parseAmount(fullText);
    String? reference = _parseReference(fullText);
    return (amount: amount, reference: reference);
  } catch (e) {
    return (amount: null, reference: null);
  }
}

/// Find first number that looks like money (e.g. 500.00, 1 250,50).
double? _parseAmount(String text) {
  // Match 1-6 digits, optional space/dot/comma, optional 2 decimals
  final patterns = [
    RegExp(r'\b(\d{1,6}[.,]\d{2})\b'),
    RegExp(r'\b(\d{1,6})\s*(?:\.\d{2})?\s*(?:DH|د\.م|MAD)?\b', caseSensitive: false),
  ];
  for (final re in patterns) {
    final match = re.firstMatch(text);
    if (match != null) {
      final s = match.group(1)!.replaceAll(',', '.').replaceAll(' ', '');
      final v = double.tryParse(s);
      if (v != null && v > 0 && v < 1000000) return v;
    }
  }
  return null;
}

/// Find alphanumeric reference (e.g. WF123456, REF-ABC123).
String? _parseReference(String text) {
  // Match 6-20 char alphanumeric (often ref/code numbers)
  final re = RegExp(r'\b([A-Z0-9]{6,20})\b', caseSensitive: false);
  final matches = re.allMatches(text);
  for (final m in matches) {
    final s = m.group(1)!;
    // Prefer strings that look like refs (mix of letters and digits)
    if (s.contains(RegExp(r'[A-Za-z]')) && s.contains(RegExp(r'[0-9]'))) {
      return s;
    }
  }
  // Fallback: any long enough alphanumeric
  for (final m in matches) {
    final s = m.group(1)!;
    if (s.length >= 8) return s;
  }
  return null;
}

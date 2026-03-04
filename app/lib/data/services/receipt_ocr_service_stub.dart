/// Stub for receipt OCR — used on web where ML Kit is not available.
/// Returns null so UI falls back to manual entry or "Simulate OCR".
Future<({double? amount, String? reference})> extractFromReceiptImage(
  String imagePath,
) async {
  return (amount: null, reference: null);
}

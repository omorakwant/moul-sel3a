/// Receipt OCR: on mobile uses ML Kit; on web uses stub (returns null).
/// Payment declaration screen uses this after taking a photo; on web "Simulate OCR" remains.
import 'receipt_ocr_service_stub.dart'
    if (dart.library.io) 'receipt_ocr_service_mlkit.dart' as impl;

Future<({double? amount, String? reference})> extractFromReceiptImage(
  String imagePath,
) =>
    impl.extractFromReceiptImage(imagePath);

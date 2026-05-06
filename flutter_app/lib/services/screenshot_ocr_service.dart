import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// On-device OCR service using Google ML Kit. Reads a screenshot and returns
/// the raw, line-by-line text recognized in the image. Runs entirely on the
/// user's device — no network, no API key, no usage limit, no cost.
class ScreenshotOcrService {
  static final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  /// Recognize text in [file] and return a flat list of detected text lines
  /// preserving reading order. Returns an empty list if nothing is detected.
  static Future<List<String>> extractLines(File file) async {
    final inputImage = InputImage.fromFile(file);
    final RecognizedText recognized = await _recognizer.processImage(
      inputImage,
    );

    final lines = <String>[];
    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        final text = line.text.trim();
        if (text.isNotEmpty) lines.add(text);
      }
    }
    return lines;
  }

  /// Free underlying native resources. Call once on app shutdown.
  static Future<void> dispose() async {
    await _recognizer.close();
  }
}

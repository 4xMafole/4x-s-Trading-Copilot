import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../data/models.dart';

class AiService {
  static GenerativeModel get _model => GenerativeModel(
    model: 'gemini-3.1-flash-lite-preview',
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      temperature: 0.2, // Low temperature for highly analytical/logical output
    ),
  );

  /// ── System Persona ──
  static const String _systemPrompt = '''
You are an elite, ruthless proprietary trading performance and risk manager.
Your job is to read raw trading logs, calculate what works, and aggressively expose what doesn't.
The trader's absolute risk limit is \$125 per trade.
Rules:
1. Do NOT summarize the trades back to the user. They already know what they took.
2. Be objective, harsh, and heavily data-driven. Look for time-of-day leaks, specific pair failures, and sequence of return issues.
3. The response MUST be strictly formatted as JSON containing exactly three keys: 'strengths', 'leaks', and 'harsh_truth'.

JSON Schema:
{
  "strengths": ["string", "string"],      // 1-3 bullet points on what is working well.
  "leaks": ["string", "string"],          // 1-3 bullet points exposing exact mathematical flaws.
  "harsh_truth": "string"                 // A 2-3 sentence brutal, honest conclusion.
}
''';

  static Future<AiReport> generateEdgeReport(List<Trade> trades) async {
    if (trades.isEmpty) {
      throw Exception('No trading data available for analysis.');
    }

    if (dotenv.env['GEMINI_API_KEY'] == null ||
        dotenv.env['GEMINI_API_KEY']!.isEmpty) {
      throw Exception('Gemini API key is not configured in .env file.');
    }

    try {
      // Data Engineering: Compress objects into tiny tokens
      final data = _compressTrades(trades);

      final prompt = '$_systemPrompt\n\n=== RAW LOGS ===\n$data';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw Exception('AI returned an empty response.');
      }

      final jsonStr = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      return AiReport.fromJson(map);
    } catch (e) {
      debugPrint('AI Error: $e');
      throw Exception('Failed to analyze edge: $e');
    }
  }

  /// Minifies the trades to pure CSV-style strings to save tokens and speed up inference.
  static String _compressTrades(List<Trade> trades) {
    final s = StringBuffer();
    // Headers
    s.writeln('Date,Time,Sym,Dir,Lots,PnL,Violations,Hypothetical');
    for (final t in trades) {
      s.writeln(
        '${t.date},${t.time},${t.sym},${t.dir},${t.lots},${t.pnl},"${t.violations.join(';')}",${t.isHypothetical}',
      );
    }
    return s.toString();
  }
}

/// The structured output from the AI.
class AiReport {
  final List<String> strengths;
  final List<String> leaks;
  final String harshTruth;

  AiReport({
    required this.strengths,
    required this.leaks,
    required this.harshTruth,
  });

  factory AiReport.fromJson(Map<String, dynamic> json) {
    return AiReport(
      strengths: List<String>.from(json['strengths'] ?? []),
      leaks: List<String>.from(json['leaks'] ?? []),
      harshTruth: json['harsh_truth'] ?? 'No conclusion provided.',
    );
  }
}

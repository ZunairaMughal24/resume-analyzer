import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'ai_prompts.dart';
import 'ai_mock_data.dart';

class AiDatasource {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<Map<String, dynamic>> analyzeResume(
    String resumeText, {
    String? jobDescription,
  }) async {
    // Try models in order of confirmed success (2.5-flash works best)
    final List<String> modelsToTry = [
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-flash-latest',
      'gemini-1.5-flash',
    ];

    for (String modelName in modelsToTry) {
      final String url =
          'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent';

      try {
        if (kDebugMode) {
          print('🛰️ ATTEMPTING AI ANALYSIS WITH: $modelName...');
        }

        final response = await http
            .post(
              Uri.parse('$url?key=$_apiKey'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': AiPrompts.generateAnalysisPrompt(resumeText, jobDescription)}
                    ]
                  }
                ],
                'generationConfig': {
                  'temperature': 0.1,
                  'maxOutputTokens': 16384,
                  'responseMimeType': 'application/json',
                }
              }),
            )
            .timeout(const Duration(seconds: 90));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final String rawText =
              data['candidates'][0]['content']['parts'][0]['text'];
          if (kDebugMode) print('✅ SUCCESS WITH $modelName!');

          // Try parsing, with truncation repair fallback
          try {
            return jsonDecode(rawText) as Map<String, dynamic>;
          } catch (_) {
            if (kDebugMode) print('⚠️ JSON truncated, attempting repair...');
            final repaired = _repairTruncatedJson(rawText);
            return jsonDecode(repaired) as Map<String, dynamic>;
          }
        } else {
          if (kDebugMode) {
            print('❌ $modelName FAILED (${response.statusCode})');
          }
          continue;
        }
      } catch (e) {
        if (kDebugMode) print('⚠️ $modelName EXCEPTION: $e');
        continue;
      }
    }

    print('🛑 ALL MODELS FAILED. FALLING BACK TO MOCK DATA.');
    return AiMockData.getMockAnalysisData();
  }

  String _repairTruncatedJson(String jsonStr) {
    String repaired = jsonStr.trim();

    int openBraces = 0;
    int openBrackets = 0;
    bool inString = false;
    bool isEscaped = false;

    for (int i = 0; i < repaired.length; i++) {
      String char = repaired[i];
      if (char == '"' && !isEscaped) {
        inString = !inString;
      }
      if (!inString) {
        if (char == '{') openBraces++;
        if (char == '}') openBraces--;
        if (char == '[') openBrackets++;
        if (char == ']') openBrackets--;
      }
      isEscaped = (char == '\\' && !isEscaped);
    }

    if (inString) repaired += '"';
    while (openBrackets > 0) {
      repaired += ']';
      openBrackets--;
    }
    while (openBraces > 0) {
      repaired += '}';
      openBraces--;
    }
    return repaired;
  }

  Future<void> listAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey'),
      );
      debugPrint('--- Model Discovery (v1beta) ---');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Available Models: ${response.body}');
    } catch (e) {
      debugPrint('Failed to list models: $e');
    }
  }

  /// Sends resume text + accepted improvements to AI for polishing.
  /// Returns structured JSON matching the ResumeData schema.
  Future<Map<String, dynamic>> polishResume(
    String resumeText, {
    required List<String> acceptedSuggestions,
    required List<String> acceptedKeywords,
  }) async {
    final List<String> modelsToTry = [
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-flash-latest',
      'gemini-1.5-flash',
    ];

    for (String modelName in modelsToTry) {
      final String url =
          'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent';

      try {
        if (kDebugMode) {
          print('✨ ATTEMPTING AI POLISH WITH: $modelName...');
        }

        final response = await http
            .post(
              Uri.parse('$url?key=$_apiKey'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {
                        'text': AiPrompts.generatePolishPrompt(
                            resumeText, acceptedSuggestions, acceptedKeywords)
                      }
                    ]
                  }
                ],
                'generationConfig': {
                  'temperature': 0.2,
                  'maxOutputTokens': 16384,
                  'responseMimeType': 'application/json',
                }
              }),
            )
            .timeout(const Duration(seconds: 90));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final String rawText =
              data['candidates'][0]['content']['parts'][0]['text'];
          if (kDebugMode) print('✅ POLISH SUCCESS WITH $modelName!');

          try {
            return jsonDecode(rawText) as Map<String, dynamic>;
          } catch (_) {
            if (kDebugMode)
              print('⚠️ Polish JSON truncated, attempting repair...');
            final repaired = _repairTruncatedJson(rawText);
            return jsonDecode(repaired) as Map<String, dynamic>;
          }
        } else {
          if (kDebugMode) {
            print('❌ $modelName POLISH FAILED (${response.statusCode})');
          }
          continue;
        }
      } catch (e) {
        if (kDebugMode) print('⚠️ $modelName POLISH EXCEPTION: $e');
        continue;
      }
    }

    if (kDebugMode) {
      print('🛑 ALL POLISH MODELS FAILED. FALLING BACK TO MOCK RESUME DATA.');
    }
    return AiMockData.getMockPolishedResumeData(resumeText);
  }
}

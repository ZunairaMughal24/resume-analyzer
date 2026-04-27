import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'ai_prompts.dart';
import 'ai_mock_data.dart';

class AiDatasource {
  static final String _apiKey = dotenv.env['API_KEY'] ?? '';

  Future<Map<String, dynamic>> analyzeResume(
    String resumeText, {
    String? jobDescription,
  }) async {
    // Try models in order of cost/performance on OpenRouter
    final List<String> modelsToTry = [
      'google/gemini-2.5-flash',
      'anthropic/claude-3-haiku',
      'openai/gpt-4o-mini',
      'google/gemini-1.5-flash',
    ];

    const String url = 'https://openrouter.ai/api/v1/chat/completions';

    for (String modelName in modelsToTry) {
      try {
        if (kDebugMode) {
          print('🛰️ ATTEMPTING AI ANALYSIS WITH: $modelName...');
        }

        final response = await http
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_apiKey',
                // Optional OpenRouter headers
                'HTTP-Referer': 'https://resume-analyzer.app',
                'X-Title': 'Resume Analyzer',
              },
              body: jsonEncode({
                'model': modelName,
                'messages': [
                  {
                    'role': 'user',
                    'content': AiPrompts.generateAnalysisPrompt(
                        resumeText, jobDescription)
                  }
                ],
                'temperature': 0.1,
                'response_format': {'type': 'json_object'},
              }),
            )
            .timeout(const Duration(seconds: 90));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final String rawText = data['choices'][0]['message']['content'];
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
            print('Error details: ${response.body}');
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

    // Handle common case where AI wraps JSON in markdown block
    if (repaired.startsWith('```json')) {
      repaired = repaired.replaceFirst('```json', '').trim();
    }
    if (repaired.endsWith('```')) {
      repaired = repaired.substring(0, repaired.length - 3).trim();
    }

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
        Uri.parse('https://openrouter.ai/api/v1/models'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );
      debugPrint('--- Model Discovery (OpenRouter) ---');
      debugPrint('Status: ${response.statusCode}');
      // OpenRouter models list is huge, might not want to print it all in prod
      debugPrint('Available Models: ${response.body.substring(0, 500)}...');
    } catch (e) {
      debugPrint('Failed to list models: $e');
    }
  }

  Future<Map<String, dynamic>> polishResume(
    String resumeText, {
    required List<String> acceptedSuggestions,
    required List<String> acceptedKeywords,
    bool isMagicPolish = false,
  }) async {
    final List<String> modelsToTry = [
      'google/gemini-2.5-flash',
      'openai/gpt-4o-mini',
      'anthropic/claude-3-haiku',
      'google/gemini-1.5-flash',
    ];

    const String url = 'https://openrouter.ai/api/v1/chat/completions';

    for (String modelName in modelsToTry) {
      try {
        if (kDebugMode) {
          print('✨ ATTEMPTING AI POLISH WITH: $modelName...');
        }

        final response = await http
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_apiKey',
                'HTTP-Referer': 'https://resume-analyzer.app',
                'X-Title': 'Resume Analyzer',
              },
              body: jsonEncode({
                'model': modelName,
                'messages': [
                  {
                    'role': 'user',
                    'content': AiPrompts.generatePolishPrompt(
                      resumeText,
                      acceptedSuggestions,
                      acceptedKeywords,
                      isMagicPolish: isMagicPolish,
                    )
                  }
                ],
                'temperature': 0.2,
                'response_format': {'type': 'json_object'},
              }),
            )
            .timeout(const Duration(seconds: 90));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final String rawText = data['choices'][0]['message']['content'];
          if (kDebugMode) print('✅ POLISH SUCCESS WITH $modelName!');

          try {
            return jsonDecode(rawText) as Map<String, dynamic>;
          } catch (_) {
            if (kDebugMode) {
              print('⚠️ Polish JSON truncated, attempting repair...');
            }
            final repaired = _repairTruncatedJson(rawText);
            return jsonDecode(repaired) as Map<String, dynamic>;
          }
        } else {
          if (kDebugMode) {
            print('❌ $modelName POLISH FAILED (${response.statusCode})');
            print('Error details: ${response.body}');
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

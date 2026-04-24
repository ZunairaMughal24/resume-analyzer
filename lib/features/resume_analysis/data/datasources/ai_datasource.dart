import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiDatasource {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<Map<String, dynamic>> analyzeResume(
    String resumeText, {
    String? jobDescription,
  }) async {
    // 1. Try these models in order of confirmed success and quota availability
    final List<String> modelsToTry = [
      'gemini-flash-latest',
      'gemini-2.0-flash',
      'gemini-1.5-flash',
      'gemini-2.5-flash',
    ];

    for (String modelName in modelsToTry) {
      final String url = 'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent';
      
      try {
        if (kDebugMode) {
          print('🛰️ ATTEMPTING AI ANALYSIS WITH: $modelName...');
        }
        
        final response = await http.post(
          Uri.parse('$url?key=$_apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [{'parts': [{'text': _generatePrompt(resumeText, jobDescription)}]}],
            'generationConfig': {
              'temperature': 0.1,
              'maxOutputTokens': 8192,
              'responseMimeType': 'application/json',
            }
          }),
        ).timeout(const Duration(seconds: 45));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final String rawText = data['candidates'][0]['content']['parts'][0]['text'];
          if (kDebugMode) print('✅ SUCCESS WITH $modelName!');
          return jsonDecode(rawText) as Map<String, dynamic>;
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
    return _getMockData();
  }

  /// Call this manually for debugging if you need to see what models are available
  Future<void> listAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey'),
      );
      debugPrint('--- Model Discovery (v1beta) ---');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Available Models: ${response.body}');
    } catch (e) {
      debugPrint('Failed to list models: $e');
    }
  }

  String _generatePrompt(String resumeText, String? jobDescription) {
    final jobCtx = jobDescription != null ? '\n\nJob Description:\n$jobDescription' : '';
    return '''Analyze the resume and return a JSON object:
    {
      "overallScore": 0-100,
      "summary": "...",
      "experienceLevel": "...",
      "industry": "...",
      "atsScore": 0-100,
      "atsCompatibility": "...",
      "skills": [{"name": "...", "category": "...", "level": "..."}],
      "sectionScores": [{"section": "...", "score": 0-100, "feedback": "..."}],
      "strengths": ["..."],
      "weaknesses": ["..."],
      "suggestions": [{"title": "...", "description": "...", "priority": "..."}],
      "keywordsFound": ["..."],
      "keywordsMissing": ["..."]
    }
    Resume: $resumeText $jobCtx''';
  }

  Map<String, dynamic> _getMockData() {
    return {
      "overallScore": 82,
      "summary": "MOCK DATA: Mobile developer with strong Flutter skills.",
      "experienceLevel": "Mid-Level",
      "industry": "Tech",
      "atsScore": 75,
      "atsCompatibility": "Good",
      "skills": [{"name": "Flutter", "category": "Tech", "level": "Expert"}],
      "sectionScores": [{"section": "General", "score": 80, "feedback": "Good"}],
      "strengths": ["Code Quality"],
      "weaknesses": ["Testing"],
      "suggestions": [{"title": "Add Tests", "description": "Add unit tests", "priority": "high"}],
      "keywordsFound": ["Dart"],
      "keywordsMissing": ["Docker"]
    };
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiDatasource {
  // Using Gemini 1.5 Flash for speed and generous free tier
  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  final SharedPreferences prefs;

  AiDatasource({required this.prefs});

  Future<Map<String, dynamic>> analyzeResume(String resumeText, {String? jobDescription}) async {
    var apiKey = prefs.getString('api_key') ?? '';
    
    // Fallback to .env if not found in storage
    if (apiKey.isEmpty) {
      apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    }

    if (apiKey.isEmpty) throw Exception('API Key is missing. Please set it in Settings or .env file.');

    final jobCtx = jobDescription != null && jobDescription.isNotEmpty
        ? '\n\nJob Description to match against:\n$jobDescription'
        : '';

    final prompt = '''Analyze the following resume and provide a comprehensive, detailed analysis. 
Return the analysis as a JSON object with exactly this structure:

{
  "overallScore": 85,
  "summary": "Professional summary...",
  "experienceLevel": "Senior",
  "industry": "Software Engineering",
  "atsScore": 78,
  "atsCompatibility": "Good",
  "skills": [
    {"name": "Flutter", "category": "Technical", "level": "Expert"}
  ],
  "sectionScores": [
    {"section": "Experience", "score": 90, "feedback": "Strong relevant experience."}
  ],
  "strengths": ["Strong technical foundation", "Leadership"],
  "weaknesses": ["Missing certification X"],
  "suggestions": [
    {"title": "Add keywords", "description": "Include more cloud-related terms.", "priority": "high"}
  ],
  "keywordsFound": ["Dart", "Clean Architecture"],
  "keywordsMissing": ["Docker", "Kubernetes"]
}

Resume Text:
$resumeText$jobCtx''';

    final response = await http.post(
      Uri.parse('$_baseUrl?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error: ${response.statusCode} - ${response.body}');
    }

    final body = jsonDecode(response.body);
    
    try {
      final text = body['candidates'][0]['content']['parts'][0]['text'] as String;
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }
}


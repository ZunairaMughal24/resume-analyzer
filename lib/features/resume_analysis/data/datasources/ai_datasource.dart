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
                      {'text': _generatePrompt(resumeText, jobDescription)}
                    ]
                  }
                ],
                'generationConfig': {
                  'temperature': 0.1,
                  'maxOutputTokens': 8192,
                  'responseMimeType': 'application/json',
                }
              }),
            )
            .timeout(const Duration(seconds: 45));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final String rawText =
              data['candidates'][0]['content']['parts'][0]['text'];
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

  String _generatePrompt(String resumeText, String? jobDescription) {
    final jobCtx = jobDescription != null
        ? '\n\nTarget Job Description (for comparison and keyword gap analysis):\n$jobDescription'
        : '';

    return '''Act as an expert ATS (Applicant Tracking System) and professional resume consultant. 
    Perform a DEEP and COMPREHENSIVE analysis of the provided resume.
    
    CRITICAL INSTRUCTIONS:
    1. Extract ALL detectable technical and soft skills. Do not limit the list.
    2. Identify EVERY relevant keyword found and EVERY important keyword missing compared to industry standards (and the job description if provided).
    3. Provide detailed, actionable suggestions for improvement.
    4. Categorize skills by level (Expert, Advanced, Intermediate, Beginner).
    
    Return the result ONLY as a valid JSON object:
    {
      "overallScore": 0-100,
      "summary": "A professional, insightful 2-3 sentence overview",
      "experienceLevel": "e.g., Junior, Mid-Level, Senior, Executive",
      "industry": "Specific industry detected",
      "atsScore": 0-100 (based on formatting, keywords, and structure),
      "atsCompatibility": "Brief explanation of ATS performance",
      "skills": [{"name": "Skill Name", "category": "Tech/Soft/Tools", "level": "Expert/Advanced/Intermediate/Beginner"}],
      "sectionScores": [{"section": "e.g., Contact Info, Summary, Experience, Education, Skills", "score": 0-100, "feedback": "Specific feedback for this section"}],
      "strengths": ["List every major strength"],
      "weaknesses": ["List every major weakness or gap"],
      "suggestions": [{"title": "Actionable Title", "description": "Specific how-to advice", "priority": "high/medium/low"}],
      "keywordsFound": ["All matching keywords"],
      "keywordsMissing": ["All critical missing keywords"]
    }

    Resume Content:
    $resumeText
    $jobCtx''';
  }

  Map<String, dynamic> _getMockData() {
    return {
      "overallScore": 82,
      "summary":
          "This is sample data (AI offline). To get a real analysis, please ensure your API key is valid and you have an internet connection.",
      "experienceLevel": "Mid-Level",
      "industry": "Software Engineering",
      "atsScore": 78,
      "atsCompatibility": "Good structure but missing some industry keywords.",
      "skills": [
        {"name": "Flutter", "category": "Tech", "level": "Expert"},
        {"name": "Dart", "category": "Tech", "level": "Expert"},
        {"name": "Firebase", "category": "Tech", "level": "Advanced"},
        {"name": "REST APIs", "category": "Tech", "level": "Advanced"},
        {"name": "Git", "category": "Tools", "level": "Expert"},
        {"name": "UI/UX Design", "category": "Soft", "level": "Intermediate"},
        {"name": "Agile", "category": "Process", "level": "Advanced"}
      ],
      "sectionScores": [
        {
          "section": "Contact",
          "score": 100,
          "feedback": "All contact info present."
        },
        {
          "section": "Experience",
          "score": 85,
          "feedback": "Strong bullet points, use more metrics."
        },
        {"section": "Skills", "score": 90, "feedback": "Well categorized."}
      ],
      "strengths": [
        "Strong technical stack",
        "Clean structure",
        "Relevant experience"
      ],
      "weaknesses": [
        "Missing certification section",
        "Few quantified achievements"
      ],
      "suggestions": [
        {
          "title": "Quantify Achievements",
          "description": "Add metrics like 'Reduced latency by 20%'.",
          "priority": "high"
        },
        {
          "title": "Add Portfolio Link",
          "description": "Include a link to your GitHub or personal site.",
          "priority": "medium"
        }
      ],
      "keywordsFound": ["Flutter", "Dart", "Mobile", "Application"],
      "keywordsMissing": ["CI/CD", "Unit Testing", "State Management"]
    };
  }
}

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
                      {'text': _generatePrompt(resumeText, jobDescription)}
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
    return _getMockData();
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
                        'text': _generatePolishPrompt(
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
    return _getMockPolishedResumeData(resumeText);
  }

  /// Fallback mock that returns a ResumeData-compatible JSON structure.
  Map<String, dynamic> _getMockPolishedResumeData(String originalText) {
    return {
      'fullName': 'Your Name',
      'contact': {
        'email': 'email@example.com',
        'phone': '',
        'location': '',
        'linkedin': '',
        'github': '',
        'website': '',
      },
      'summary':
          'AI polish unavailable (API offline). This is mock data for UI testing. Your original resume text has been preserved in the experience section.',
      'experience': [
        {
          'title': 'See Original Resume',
          'company': 'Original Text Below',
          'dates': '',
          'location': '',
          'bullets': [
            originalText.substring(0, originalText.length.clamp(0, 500))
          ],
        }
      ],
      'education': [],
      'skills': ['See original resume for skills'],
      'certifications': [],
      'projects': [],
      'languages': [],
    };
  }

  String _generatePolishPrompt(
    String resumeText,
    List<String> acceptedSuggestions,
    List<String> acceptedKeywords,
  ) {
    final suggestionsBlock = acceptedSuggestions.isNotEmpty
        ? '\n\nAPPROVED IMPROVEMENTS TO APPLY:\n${acceptedSuggestions.map((s) => '• $s').join('\n')}'
        : '';

    final keywordsBlock = acceptedKeywords.isNotEmpty
        ? '\n\nMISSING KEYWORDS TO NATURALLY INCORPORATE:\n${acceptedKeywords.map((k) => '• $k').join('\n')}'
        : '';

    return '''You are an expert professional resume writer and ATS optimizer.

TASK: Extract and restructure all resume content from the raw text below, then apply the approved improvements. Return ONLY a valid JSON object — no markdown, no explanation.

CRITICAL RULES:
1. The input text was PDF-extracted and may be scattered. Parse it intelligently.
2. Do NOT invent information not present in the original or approved improvements.
3. Naturally incorporate the approved keywords where they fit contextually.
4. Write bullet points as strong, action-verb-led achievement statements.
5. Keep a professional, high-impact tone.
$suggestionsBlock
$keywordsBlock

Return this EXACT JSON structure:
{
  "fullName": "Full name of the candidate",
  "contact": {
    "email": "email address or empty string",
    "phone": "phone number or empty string",
    "location": "city, state/country or empty string",
    "linkedin": "LinkedIn URL or empty string",
    "github": "GitHub URL or empty string",
    "website": "portfolio/website URL or empty string"
  },
  "summary": "A polished 2-3 sentence professional summary",
  "experience": [
    {
      "title": "Job Title",
      "company": "Company Name",
      "dates": "Month Year – Month Year",
      "location": "City, State or empty string",
      "bullets": ["Achievement or responsibility 1", "Achievement 2"]
    }
  ],
  "education": [
    {
      "degree": "Degree Name",
      "institution": "University/School Name",
      "dates": "Year or Year–Year",
      "details": "GPA, honors, or relevant coursework or empty string"
    }
  ],
  "skills": ["Skill 1", "Skill 2", "Skill 3"],
  "certifications": ["Certification Name and Year"],
  "projects": [
    {
      "name": "Project Name",
      "description": "One sentence description or empty string",
      "bullets": ["Key achievement or tech used"]
    }
  ],
  "languages": ["Language (Proficiency)"]
}

ORIGINAL RESUME TEXT (may be scattered/messy — parse intelligently):
$resumeText''';
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

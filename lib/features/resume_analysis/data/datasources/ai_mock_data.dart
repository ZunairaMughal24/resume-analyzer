class AiMockData {
  static Map<String, dynamic> getMockAnalysisData() {
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

  static Map<String, dynamic> getMockPolishedResumeData(String originalText) {
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
}

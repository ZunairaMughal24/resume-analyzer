class AiPrompts {
  static String generateAnalysisPrompt(String resumeText, String? jobDescription) {
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

  static String generatePolishPrompt(
    String resumeText,
    List<String> acceptedSuggestions,
    List<String> acceptedKeywords, {
    bool isMagicPolish = false,
  }) {
    final suggestionsBlock = acceptedSuggestions.isNotEmpty
        ? '\n\nAPPROVED IMPROVEMENTS TO APPLY:\n${acceptedSuggestions.map((s) => '• $s').join('\n')}'
        : '';

    final keywordsBlock = acceptedKeywords.isNotEmpty
        ? '\n\nMISSING KEYWORDS TO NATURALLY INCORPORATE:\n${acceptedKeywords.map((k) => '• $k').join('\n')}'
        : '';

    final magicBlock = isMagicPolish
        ? '\n\nMAGIC POLISH ENABLED:\nProactively improve grammar, rewrite bullet points to be stronger and more impactful, and ensure professional phrasing throughout the entire resume.'
        : '';

    return '''You are an expert professional resume writer and ATS optimizer.

TASK: Extract and restructure all resume content from the raw text below, then apply the approved improvements. Return ONLY a valid JSON object — no markdown, no explanation.

CRITICAL RULES:
1. The input text was PDF-extracted and may be scattered. Parse it intelligently.
2. ${isMagicPolish ? 'You have creative freedom to rewrite and improve the text for maximum professional impact.' : 'Do NOT invent information not present in the original or approved improvements.'}
3. Naturally incorporate the approved keywords where they fit contextually.
4. Write bullet points as strong, action-verb-led achievement statements.
5. Keep a professional, high-impact tone.
$suggestionsBlock
$keywordsBlock
$magicBlock

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
      "link": "Project URL or empty string",
      "bullets": ["Key achievement or tech used"]
    }
  ],
  "languages": ["Language (Proficiency)"]
}

ORIGINAL RESUME TEXT (may be scattered/messy — parse intelligently):
$resumeText''';
  }
}

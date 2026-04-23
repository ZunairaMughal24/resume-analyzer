import '../../domain/entities/resume_analysis.dart';

class ResumeAnalysisModel extends ResumeAnalysis {
  const ResumeAnalysisModel({
    required super.overallScore,
    required super.summary,
    required super.skills,
    required super.sectionScores,
    required super.suggestions,
    required super.strengths,
    required super.weaknesses,
    required super.atsCompatibility,
    required super.atsScore,
    required super.experienceLevel,
    required super.keywordsFound,
    required super.keywordsMissing,
    required super.industry,
    required super.analyzedAt,
  });

  factory ResumeAnalysisModel.fromJson(Map<String, dynamic> json) {
    return ResumeAnalysisModel(
      overallScore: (json['overallScore'] as num?)?.toInt() ?? 0,
      summary: json['summary'] as String? ?? '',
      experienceLevel: json['experienceLevel'] as String? ?? 'Unknown',
      industry: json['industry'] as String? ?? 'General',
      atsScore: (json['atsScore'] as num?)?.toInt() ?? 0,
      atsCompatibility: json['atsCompatibility'] as String? ?? 'Unknown',
      skills: ((json['skills'] as List?) ?? [])
          .map((s) => SkillItem(
                name: s['name'] ?? '',
                category: s['category'] ?? 'Technical',
                level: s['level'] ?? 'Intermediate',
              ))
          .toList(),
      sectionScores: ((json['sectionScores'] as List?) ?? [])
          .map((s) => SectionScore(
                section: s['section'] ?? '',
                score: (s['score'] as num?)?.toInt() ?? 0,
                feedback: s['feedback'] ?? '',
              ))
          .toList(),
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      suggestions: ((json['suggestions'] as List?) ?? [])
          .map((s) => Suggestion(
                title: s['title'] ?? '',
                description: s['description'] ?? '',
                priority: _parsePriority(s['priority']),
              ))
          .toList(),
      keywordsFound: List<String>.from(json['keywordsFound'] ?? []),
      keywordsMissing: List<String>.from(json['keywordsMissing'] ?? []),
      analyzedAt: DateTime.now(),
    );
  }

  static SuggestionPriority _parsePriority(dynamic p) {
    switch (p?.toString().toLowerCase()) {
      case 'high': return SuggestionPriority.high;
      case 'low': return SuggestionPriority.low;
      default: return SuggestionPriority.medium;
    }
  }
}

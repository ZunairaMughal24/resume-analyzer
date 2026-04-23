import 'package:equatable/equatable.dart';

class ResumeAnalysis extends Equatable {
  final int overallScore;
  final String summary;
  final List<SkillItem> skills;
  final List<SectionScore> sectionScores;
  final List<Suggestion> suggestions;
  final List<String> strengths;
  final List<String> weaknesses;
  final String atsCompatibility;
  final int atsScore;
  final String experienceLevel;
  final List<String> keywordsFound;
  final List<String> keywordsMissing;
  final String industry;
  final DateTime analyzedAt;

  const ResumeAnalysis({
    required this.overallScore,
    required this.summary,
    required this.skills,
    required this.sectionScores,
    required this.suggestions,
    required this.strengths,
    required this.weaknesses,
    required this.atsCompatibility,
    required this.atsScore,
    required this.experienceLevel,
    required this.keywordsFound,
    required this.keywordsMissing,
    required this.industry,
    required this.analyzedAt,
  });

  @override
  List<Object?> get props => [
        overallScore,
        summary,
        skills,
        sectionScores,
        suggestions,
        strengths,
        weaknesses,
        atsCompatibility,
        atsScore,
        experienceLevel,
        keywordsFound,
        keywordsMissing,
        industry,
        analyzedAt,
      ];
}

class SkillItem extends Equatable {
  final String name;
  final String category;
  final String level;
  const SkillItem({required this.name, required this.category, required this.level});

  @override
  List<Object?> get props => [name, category, level];
}

class SectionScore extends Equatable {
  final String section;
  final int score;
  final String feedback;
  const SectionScore({required this.section, required this.score, required this.feedback});

  @override
  List<Object?> get props => [section, score, feedback];
}

class Suggestion extends Equatable {
  final String title;
  final String description;
  final SuggestionPriority priority;
  const Suggestion({required this.title, required this.description, required this.priority});

  @override
  List<Object?> get props => [title, description, priority];
}

enum SuggestionPriority { high, medium, low }


import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import 'package:resume_analyzer/features/ai_assistant/domain/entities/resume_analysis.dart';
import '../entities/resume_data.dart';

abstract class ResumeRepository {
  Future<Either<Failure, ResumeAnalysis>> analyzeResume(String resumeText, {String? jobDescription});

  Future<Either<Failure, ResumeData>> polishResume(
    String resumeText, {
    required List<String> acceptedSuggestions,
    required List<String> acceptedKeywords,
    bool isMagicPolish = false,
  });
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import 'package:resume_analyzer/features/ai_assistant/domain/entities/resume_analysis.dart';
import 'package:resume_analyzer/features/resume_editor/domain/repositories/resume_repository.dart';

class AnalyzeResumeUseCase {
  final ResumeRepository repository;

  AnalyzeResumeUseCase(this.repository);

  Future<Either<Failure, ResumeAnalysis>> call(
    String resumeText, {
    String? jobDescription,
  }) {
    return repository.analyzeResume(resumeText, jobDescription: jobDescription);
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/resume_analysis.dart';
import '../repositories/resume_repository.dart';

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

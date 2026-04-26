import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/resume_data.dart';
import '../repositories/resume_repository.dart';

class PolishResumeUseCase {
  final ResumeRepository repository;

  PolishResumeUseCase(this.repository);

  Future<Either<Failure, ResumeData>> call(
    String resumeText, {
    required List<String> acceptedSuggestions,
    required List<String> acceptedKeywords,
  }) {
    return repository.polishResume(
      resumeText,
      acceptedSuggestions: acceptedSuggestions,
      acceptedKeywords: acceptedKeywords,
    );
  }
}

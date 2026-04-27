import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import 'package:resume_analyzer/features/resume_editor/domain/entities/resume_data.dart';
import 'package:resume_analyzer/features/resume_editor/domain/repositories/resume_repository.dart';

class PolishResumeUseCase {
  final ResumeRepository repository;

  PolishResumeUseCase(this.repository);

  Future<Either<Failure, ResumeData>> call(
    String resumeText, {
    required List<String> acceptedSuggestions,
    required List<String> acceptedKeywords,
    bool isMagicPolish = false,
  }) {
    return repository.polishResume(
      resumeText,
      acceptedSuggestions: acceptedSuggestions,
      acceptedKeywords: acceptedKeywords,
      isMagicPolish: isMagicPolish,
    );
  }
}

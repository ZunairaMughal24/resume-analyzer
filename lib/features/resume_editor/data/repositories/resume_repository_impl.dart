import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import 'package:resume_analyzer/features/ai_assistant/domain/entities/resume_analysis.dart';
import 'package:resume_analyzer/features/resume_editor/domain/entities/resume_data.dart';
import 'package:resume_analyzer/features/resume_editor/domain/repositories/resume_repository.dart';
import 'package:resume_analyzer/features/ai_assistant/data/datasources/ai_datasource.dart';
import 'package:resume_analyzer/features/ai_assistant/data/models/resume_analysis_model.dart';

class ResumeRepositoryImpl implements ResumeRepository {
  final AiDatasource datasource;
  ResumeRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, ResumeAnalysis>> analyzeResume(
    String resumeText, {String? jobDescription}
  ) async {
    try {
      final json = await datasource.analyzeResume(resumeText, jobDescription: jobDescription);
      final model = ResumeAnalysisModel.fromJson(json);
      return Right(model);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ResumeData>> polishResume(
    String resumeText, {
    required List<String> acceptedSuggestions,
    required List<String> acceptedKeywords,
    bool isMagicPolish = false,
  }) async {
    try {
      final json = await datasource.polishResume(
        resumeText,
        acceptedSuggestions: acceptedSuggestions,
        acceptedKeywords: acceptedKeywords,
        isMagicPolish: isMagicPolish,
      );
      return Right(ResumeData.fromJson(json));
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(Object e) {
    final errorStr = e.toString().toLowerCase();
    if (errorStr.contains('quota') || errorStr.contains('429')) {
      return ServerFailure('AI service is currently busy. Please try again in a few moments.');
    } else if (errorStr.contains('network') || errorStr.contains('socket')) {
      return ServerFailure('Network error. Please check your connection.');
    }
    return ServerFailure('Analysis failed: ${e.toString()}');
  }
}


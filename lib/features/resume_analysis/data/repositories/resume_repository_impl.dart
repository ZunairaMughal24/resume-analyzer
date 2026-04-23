import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/resume_analysis.dart';
import '../../domain/repositories/resume_repository.dart';
import '../datasources/ai_datasource.dart';
import '../models/resume_analysis_model.dart';

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
      return Left(ServerFailure(e.toString()));
    }
  }
}


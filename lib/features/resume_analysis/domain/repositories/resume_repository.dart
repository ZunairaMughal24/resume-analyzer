import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/resume_analysis.dart';

abstract class ResumeRepository {
  Future<Either<Failure, ResumeAnalysis>> analyzeResume(String resumeText, {String? jobDescription});
}


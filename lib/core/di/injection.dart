import '../../features/resume_analysis/data/datasources/ai_datasource.dart';
import '../../features/resume_analysis/data/repositories/resume_repository_impl.dart';
import '../../features/resume_analysis/domain/repositories/resume_repository.dart';
import '../../features/resume_analysis/domain/usecases/analyze_resume_usecase.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final AiDatasource aiDatasource;
  late final ResumeRepository resumeRepository;
  late final AnalyzeResumeUseCase analyzeResumeUseCase;

  void init() {
    aiDatasource = AiDatasource();
    resumeRepository = ResumeRepositoryImpl(aiDatasource);
    analyzeResumeUseCase = AnalyzeResumeUseCase(resumeRepository);
  }
}

final sl = ServiceLocator();

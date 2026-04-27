import '../../features/ai_assistant/data/datasources/ai_datasource.dart';
import '../../features/resume_editor/data/repositories/resume_repository_impl.dart';
import '../../features/resume_editor/domain/repositories/resume_repository.dart';
import '../../features/resume_parser/domain/usecases/analyze_resume_usecase.dart';
import '../../features/ai_assistant/domain/usecases/polish_resume_usecase.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final AiDatasource aiDatasource;
  late final ResumeRepository resumeRepository;
  late final AnalyzeResumeUseCase analyzeResumeUseCase;
  late final PolishResumeUseCase polishResumeUseCase;

  void init() {
    aiDatasource = AiDatasource();
    resumeRepository = ResumeRepositoryImpl(aiDatasource);
    analyzeResumeUseCase = AnalyzeResumeUseCase(resumeRepository);
    polishResumeUseCase = PolishResumeUseCase(resumeRepository);
  }
}

final sl = ServiceLocator();


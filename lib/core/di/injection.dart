import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/resume_analysis/data/datasources/ai_datasource.dart';
import '../../features/resume_analysis/data/repositories/resume_repository_impl.dart';
import '../../features/resume_analysis/domain/repositories/resume_repository.dart';
import '../../features/resume_analysis/domain/usecases/analyze_resume_usecase.dart';
import '../../features/resume_analysis/presentation/bloc/resume_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Core
  // Network/HTTP client can be registered here if using Dio

  // Features - Resume Analysis

  // Datasources
  sl.registerLazySingleton<AiDatasource>(
    () => AiDatasource(prefs: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ResumeRepository>(
    () => ResumeRepositoryImpl(sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => AnalyzeResumeUseCase(sl()));

  // Blocs
  sl.registerFactory(() => ResumeBloc(sl()));
}

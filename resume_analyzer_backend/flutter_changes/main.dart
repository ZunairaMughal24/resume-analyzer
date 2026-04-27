import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resume_analyzer/core/theme/app_theme.dart';
import 'package:resume_analyzer/features/ai_assistant/presentation/bloc/resume_bloc.dart';
import 'package:resume_analyzer/features/home/presentation/pages/home_page.dart';
import 'package:resume_analyzer/features/resume_analysis/data/datasources/ai_datasource.dart';
import 'package:resume_analyzer/features/resume_analysis/data/repositories/resume_repository_impl.dart';
import 'package:resume_analyzer/features/resume_parser/domain/usecases/analyze_resume_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ResumeAnalyzerApp());
}

class ResumeAnalyzerApp extends StatelessWidget {
  const ResumeAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final datasource = AiDatasource();
    final repository = ResumeRepositoryImpl(datasource);
    final useCase = AnalyzeResumeUseCase(repository);

    return BlocProvider(
      create: (_) => ResumeBloc(useCase),
      child: MaterialApp(
        title: 'ResumeAI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomePage(),
      ),
    );
  }
}

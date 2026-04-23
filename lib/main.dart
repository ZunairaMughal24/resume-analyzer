import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'features/resume_analysis/presentation/bloc/resume_bloc.dart';
import 'features/resume_analysis/presentation/pages/home_page.dart';
import 'features/resume_analysis/presentation/pages/api_key_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await dotenv.load(fileName: ".env");
  
  final prefs = sl<SharedPreferences>();
  var apiKey = prefs.getString('api_key') ?? '';
  
  // Professional fallback: If SharedPreferences is empty, check .env
  if (apiKey.isEmpty) {
    apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  }
  
  runApp(ResumeAnalyzerApp(initialApiKey: apiKey));
}

class ResumeAnalyzerApp extends StatefulWidget {
  final String initialApiKey;
  const ResumeAnalyzerApp({super.key, required this.initialApiKey});

  @override
  State<ResumeAnalyzerApp> createState() => _ResumeAnalyzerAppState();
}

class _ResumeAnalyzerAppState extends State<ResumeAnalyzerApp> {
  late String _apiKey;

  @override
  void initState() {
    super.initState();
    _apiKey = widget.initialApiKey;
  }

  void _onKeySet() async {
    final prefs = sl<SharedPreferences>();
    setState(() => _apiKey = prefs.getString('api_key') ?? '');
    
    // In a production app, you might want to re-register the datasource with the new key,
    // or better, pass the key with the request. For now, since sl is lazy singleton,
    // we should ideally clear it or use a token provider if we update the key on the fly.
    // For simplicity, we keep the existing structure but use DI.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resume Analyzer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: _apiKey.isEmpty
          ? ApiKeyPage(onKeySet: _onKeySet)
          : _buildBlocProviders(),
    );
  }

  Widget _buildBlocProviders() {
    return BlocProvider(
      create: (_) => sl<ResumeBloc>(),
      child: const HomePage(),
    );
  }
}

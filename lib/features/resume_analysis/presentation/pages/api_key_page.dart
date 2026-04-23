import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';


class ApiKeyPage extends StatefulWidget {
  final VoidCallback onKeySet;
  const ApiKeyPage({super.key, required this.onKeySet});

  @override
  State<ApiKeyPage> createState() => _ApiKeyPageState();
}

class _ApiKeyPageState extends State<ApiKeyPage> {
  final _controller = TextEditingController();
  bool _obscure = true;

  Future<void> _saveKey() async {
    final key = _controller.text.trim();
    if (key.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key', key);
    widget.onKeySet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 30),
              ).animate().scale(delay: 100.ms),
              const SizedBox(height: 32),
              Text(
                'Welcome to\nResume Analyzer',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(height: 1.15),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              Text(
                'Enter your Gemini API key from Google AI Studio to get started. It\'s free and stays on your device.',
                style: Theme.of(context).textTheme.bodyLarge,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 40),
              TextField(
                controller: _controller,
                obscureText: _obscure,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'sk-ant-...',
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  prefixIcon: const Icon(Icons.key_rounded, color: AppColors.textMuted, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.textMuted, size: 18,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 20, offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _saveKey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Get Started',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Get your free key at aistudio.google.com',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ).animate().fadeIn(delay: 600.ms),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resume_analyzer/features/ai_assistant/domain/entities/resume_analysis.dart';
import 'package:resume_analyzer/features/resume_parser/domain/usecases/analyze_resume_usecase.dart';

// Events
abstract class ResumeEvent extends Equatable {
  const ResumeEvent();
  @override
  List<Object?> get props => [];
}

class AnalyzeResumeEvent extends ResumeEvent {
  final String resumeText;
  final String? jobDescription;
  const AnalyzeResumeEvent({required this.resumeText, this.jobDescription});
  @override
  List<Object?> get props => [resumeText, jobDescription];
}

class ResetResumeEvent extends ResumeEvent {}

// States
abstract class ResumeState extends Equatable {
  const ResumeState();
  @override
  List<Object?> get props => [];
}

class ResumeInitial extends ResumeState {}
class ResumeLoading extends ResumeState {}

class ResumeSuccess extends ResumeState {
  final ResumeAnalysis analysis;
  const ResumeSuccess(this.analysis);
  @override
  List<Object?> get props => [analysis];
}

class ResumeError extends ResumeState {
  final String message;
  const ResumeError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class ResumeBloc extends Bloc<ResumeEvent, ResumeState> {
  final AnalyzeResumeUseCase useCase;

  ResumeBloc(this.useCase) : super(ResumeInitial()) {
    on<AnalyzeResumeEvent>(_onAnalyze);
    on<ResetResumeEvent>((_, emit) => emit(ResumeInitial()));
  }

  Future<void> _onAnalyze(AnalyzeResumeEvent event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await useCase(event.resumeText, jobDescription: event.jobDescription);
    result.fold(
      (failure) => emit(ResumeError(failure.message)),
      (analysis) => emit(ResumeSuccess(analysis)),
    );
  }
}


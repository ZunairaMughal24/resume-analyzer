import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/resume_data.dart';
import '../../domain/usecases/polish_resume_usecase.dart';
import 'editor_event.dart';
import 'editor_state.dart';

export 'editor_event.dart';
export 'editor_state.dart';

class EditorBloc extends Bloc<EditorEvent, EditorState> {
  final PolishResumeUseCase polishUseCase;

  EditorBloc(this.polishUseCase) : super(const EditorState()) {
    on<InitializeEditor>(_onInitialize);
    on<ToggleSuggestion>(_onToggleSuggestion);
    on<ToggleKeyword>(_onToggleKeyword);
    on<AcceptAllSuggestions>(_onAcceptAllSuggestions);
    on<RejectAllSuggestions>(_onRejectAllSuggestions);
    on<AcceptAllKeywords>(_onAcceptAllKeywords);
    on<RejectAllKeywords>(_onRejectAllKeywords);
    on<UpdateResumeData>(_onUpdateResumeData);
    on<UpdateResumeText>(_onUpdateResumeText);
    on<UpdatePdfFontSize>(_onUpdatePdfFontSize);
    on<PolishWithAI>(_onPolish);
    on<RenameResume>(_onRename);
    on<UndoEdit>(_onUndo);
  }

  void _onInitialize(InitializeEditor event, Emitter<EditorState> emit) {
    final selectableSuggestions = event.analysis.suggestions
        .map((s) => SelectableSuggestion(suggestion: s))
        .toList();

    final selectableKeywords = event.analysis.keywordsMissing
        .map((k) => SelectableKeyword(keyword: k))
        .toList();

    emit(EditorState(
      originalResumeText: event.resumeText,
      resumeData: null, // No structured data yet user must polish first
      fileName: event.fileName,
      analysis: event.analysis,
      suggestions: selectableSuggestions,
      missingKeywords: selectableKeywords,
      status: EditorStatus.loaded,
    ));
  }

  void _onToggleSuggestion(ToggleSuggestion event, Emitter<EditorState> emit) {
    final updated = List<SelectableSuggestion>.from(state.suggestions);
    updated[event.index] = updated[event.index].copyWith(
      isAccepted: !updated[event.index].isAccepted,
    );
    emit(state.copyWith(suggestions: updated));
  }

  void _onToggleKeyword(ToggleKeyword event, Emitter<EditorState> emit) {
    final updated = List<SelectableKeyword>.from(state.missingKeywords);
    updated[event.index] = updated[event.index].copyWith(
      isAccepted: !updated[event.index].isAccepted,
    );
    emit(state.copyWith(missingKeywords: updated));
  }

  void _onAcceptAllSuggestions(
      AcceptAllSuggestions event, Emitter<EditorState> emit) {
    final updated =
        state.suggestions.map((s) => s.copyWith(isAccepted: true)).toList();
    emit(state.copyWith(suggestions: updated));
  }

  void _onRejectAllSuggestions(
      RejectAllSuggestions event, Emitter<EditorState> emit) {
    final updated =
        state.suggestions.map((s) => s.copyWith(isAccepted: false)).toList();
    emit(state.copyWith(suggestions: updated));
  }

  void _onAcceptAllKeywords(
      AcceptAllKeywords event, Emitter<EditorState> emit) {
    final updated =
        state.missingKeywords.map((k) => k.copyWith(isAccepted: true)).toList();
    emit(state.copyWith(missingKeywords: updated));
  }

  void _onRejectAllKeywords(
      RejectAllKeywords event, Emitter<EditorState> emit) {
    final updated = state.missingKeywords
        .map((k) => k.copyWith(isAccepted: false))
        .toList();
    emit(state.copyWith(missingKeywords: updated));
  }

  void _onUpdateResumeData(UpdateResumeData event, Emitter<EditorState> emit) {
    // Push current snapshot to undo stack before replacing
    final newStack = state.resumeData != null
        ? [...state.undoStack, state.resumeData!]
        : state.undoStack;
    emit(state.copyWith(resumeData: event.resumeData, undoStack: newStack));
  }

  // Legacy: converts plain text back to a minimal ResumeData for backward compat
  void _onUpdateResumeText(UpdateResumeText event, Emitter<EditorState> emit) {
    final newStack = state.resumeData != null
        ? [...state.undoStack, state.resumeData!]
        : state.undoStack;
    // Build a minimal ResumeData from plain text
    final minimalData = ResumeData(
      fullName: state.resumeData?.fullName ?? '',
      contact: state.resumeData?.contact ?? const ResumeContact(),
      summary: event.text,
    );
    emit(state.copyWith(resumeData: minimalData, undoStack: newStack));
  }

  void _onUpdatePdfFontSize(
      UpdatePdfFontSize event, Emitter<EditorState> emit) {
    emit(state.copyWith(pdfFontSize: event.fontSize));
  }

  Future<void> _onPolish(PolishWithAI event, Emitter<EditorState> emit) async {
    if (!state.hasSelections) return;

    emit(state.copyWith(status: EditorStatus.polishing));

    final acceptedSuggestions = state.suggestions
        .where((s) => s.isAccepted)
        .map((s) => s.toPromptString())
        .toList();

    final acceptedKeywords = state.missingKeywords
        .where((k) => k.isAccepted)
        .map((k) => k.keyword)
        .toList();

    final result = await polishUseCase(
      state.originalResumeText,
      acceptedSuggestions: acceptedSuggestions,
      acceptedKeywords: acceptedKeywords,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: EditorStatus.error,
        errorMessage: failure.message,
      )),
      (polishedData) {
        // Push current snapshot to undo stack
        final newStack = state.resumeData != null
            ? [...state.undoStack, state.resumeData!]
            : state.undoStack;
        emit(state.copyWith(
          resumeData: polishedData,
          undoStack: newStack,
          status: EditorStatus.loaded,
        ));
      },
    );
  }

  void _onRename(RenameResume event, Emitter<EditorState> emit) {
    emit(state.copyWith(fileName: event.newName));
  }

  void _onUndo(UndoEdit event, Emitter<EditorState> emit) {
    if (state.undoStack.isEmpty) return;

    final newStack = List<ResumeData>.from(state.undoStack);
    final previousData = newStack.removeLast();

    emit(state.copyWith(
      resumeData: previousData,
      undoStack: newStack,
    ));
  }
}

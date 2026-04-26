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
    on<BulkUpdateSelection>(_onBulkUpdateSelection);
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
      resumeData: null,
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

  void _onBulkUpdateSelection(
      BulkUpdateSelection event, Emitter<EditorState> emit) {
    List<SelectableSuggestion>? updatedSuggestions;
    List<SelectableKeyword>? updatedKeywords;

    if (event.type == SelectionType.suggestions ||
        event.type == SelectionType.all) {
      updatedSuggestions = state.suggestions
          .map((s) => s.copyWith(isAccepted: event.isAccepted))
          .toList();
    }

    if (event.type == SelectionType.keywords ||
        event.type == SelectionType.all) {
      updatedKeywords = state.missingKeywords
          .map((k) => k.copyWith(isAccepted: event.isAccepted))
          .toList();
    }

    emit(state.copyWith(
      suggestions: updatedSuggestions,
      missingKeywords: updatedKeywords,
    ));
  }

  void _onUpdateResumeData(UpdateResumeData event, Emitter<EditorState> emit) {
    emit(_stateWithUndo(state.copyWith(resumeData: event.resumeData)));
  }

  void _onUpdateResumeText(UpdateResumeText event, Emitter<EditorState> emit) {
    final minimalData = ResumeData(
      fullName: state.resumeData?.fullName ?? '',
      contact: state.resumeData?.contact ?? const ResumeContact(),
      summary: event.text,
    );
    emit(_stateWithUndo(state.copyWith(resumeData: minimalData)));
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
        emit(_stateWithUndo(state.copyWith(
          resumeData: polishedData,
          status: EditorStatus.loaded,
        )));
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

  /// Helper to manage undo stack automatically when updating data
  EditorState _stateWithUndo(EditorState newState) {
    if (state.resumeData == null) return newState;
    return newState.copyWith(
      undoStack: [...state.undoStack, state.resumeData!],
    );
  }
}

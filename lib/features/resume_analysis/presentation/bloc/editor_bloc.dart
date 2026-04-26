import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/resume_analysis.dart';
import '../../domain/entities/resume_data.dart';
import '../../domain/usecases/polish_resume_usecase.dart';

class SelectableSuggestion {
  final Suggestion suggestion;
  final bool isAccepted;

  const SelectableSuggestion(
      {required this.suggestion, this.isAccepted = false});

  SelectableSuggestion copyWith({bool? isAccepted}) {
    return SelectableSuggestion(
      suggestion: suggestion,
      isAccepted: isAccepted ?? this.isAccepted,
    );
  }

  //Formats suggestion as a single string for the AI prompt.
  String toPromptString() => '${suggestion.title}: ${suggestion.description}';
}

//Wraps a missing keyword string with mutable selection state.
class SelectableKeyword {
  final String keyword;
  final bool isAccepted;

  const SelectableKeyword({required this.keyword, this.isAccepted = false});

  SelectableKeyword copyWith({bool? isAccepted}) {
    return SelectableKeyword(
      keyword: keyword,
      isAccepted: isAccepted ?? this.isAccepted,
    );
  }
}

//Events

abstract class EditorEvent extends Equatable {
  const EditorEvent();
  @override
  List<Object?> get props => [];
}

//Initializes the editor with resume text and analysis results.
class InitializeEditor extends EditorEvent {
  final String resumeText;
  final String fileName;
  final ResumeAnalysis analysis;

  const InitializeEditor({
    required this.resumeText,
    required this.fileName,
    required this.analysis,
  });

  @override
  List<Object?> get props => [resumeText, fileName, analysis];
}

//Toggles a specific suggestion's accepted state.
class ToggleSuggestion extends EditorEvent {
  final int index;
  const ToggleSuggestion(this.index);
  @override
  List<Object?> get props => [index];
}

//Toggles a specific keyword's accepted state.
class ToggleKeyword extends EditorEvent {
  final int index;
  const ToggleKeyword(this.index);
  @override
  List<Object?> get props => [index];
}

//Accept all suggestions at once.
class AcceptAllSuggestions extends EditorEvent {}

//Reject (clear) all suggestions.
class RejectAllSuggestions extends EditorEvent {}

//Accept all missing keywords at once.
class AcceptAllKeywords extends EditorEvent {}

//Reject (clear) all keywords.
class RejectAllKeywords extends EditorEvent {}

/// Updates the structured ResumeData (from section-based editor).
class UpdateResumeData extends EditorEvent {
  final ResumeData resumeData;
  const UpdateResumeData(this.resumeData);
  @override
  List<Object?> get props => [resumeData];
}

//Legacy event — updates a specific plain-text field via key.
class UpdateResumeText extends EditorEvent {
  final String text;
  const UpdateResumeText(this.text);
  @override
  List<Object?> get props => [text];
}

//Trigger AI polish using accepted suggestions & keywords.
class PolishWithAI extends EditorEvent {}

//Rename the resume file.
class RenameResume extends EditorEvent {
  final String newName;
  const RenameResume(this.newName);
  @override
  List<Object?> get props => [newName];
}

/// Undo to the previous ResumeData version.
class UndoEdit extends EditorEvent {}

//Update the base font size for the PDF export.
class UpdatePdfFontSize extends EditorEvent {
  final double fontSize;
  const UpdatePdfFontSize(this.fontSize);
  @override
  List<Object?> get props => [fontSize];
}

// State

enum EditorStatus { initial, loaded, polishing, error }

class EditorState extends Equatable {
  final String originalResumeText;
  final ResumeData? resumeData;
  final String fileName;
  final ResumeAnalysis? analysis;
  final List<SelectableSuggestion> suggestions;
  final List<SelectableKeyword> missingKeywords;
  final List<ResumeData> undoStack;
  final double pdfFontSize;
  final EditorStatus status;
  final String? errorMessage;

  const EditorState({
    this.originalResumeText = '',
    this.resumeData,
    this.fileName = 'My Resume',
    this.analysis,
    this.suggestions = const [],
    this.missingKeywords = const [],
    this.undoStack = const [],
    this.pdfFontSize = 10.0,
    this.status = EditorStatus.initial,
    this.errorMessage,
  });

  //Convenience: current resume as plain text for AI input and legacy text export.
  String get currentResumeText =>
      resumeData?.toPlainText() ?? originalResumeText;

  /// Number of accepted suggestions.
  int get acceptedSuggestionsCount =>
      suggestions.where((s) => s.isAccepted).length;

  /// Number of accepted keywords.
  int get acceptedKeywordsCount =>
      missingKeywords.where((k) => k.isAccepted).length;

  /// Total selectable items count.
  int get totalSelectableCount => suggestions.length + missingKeywords.length;

  /// Total accepted count.
  int get totalAcceptedCount =>
      acceptedSuggestionsCount + acceptedKeywordsCount;

  /// Whether undo is available.
  bool get canUndo => undoStack.isNotEmpty;

  /// Whether there's anything selected to polish.
  bool get hasSelections => totalAcceptedCount > 0;

  /// Whether the resume has been polished/modified.
  bool get isModified => resumeData != null;

  EditorState copyWith({
    String? originalResumeText,
    ResumeData? resumeData,
    String? fileName,
    ResumeAnalysis? analysis,
    List<SelectableSuggestion>? suggestions,
    List<SelectableKeyword>? missingKeywords,
    List<ResumeData>? undoStack,
    double? pdfFontSize,
    EditorStatus? status,
    String? errorMessage,
    bool clearResumeData = false,
  }) {
    return EditorState(
      originalResumeText: originalResumeText ?? this.originalResumeText,
      resumeData: clearResumeData ? null : (resumeData ?? this.resumeData),
      fileName: fileName ?? this.fileName,
      analysis: analysis ?? this.analysis,
      suggestions: suggestions ?? this.suggestions,
      missingKeywords: missingKeywords ?? this.missingKeywords,
      undoStack: undoStack ?? this.undoStack,
      pdfFontSize: pdfFontSize ?? this.pdfFontSize,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        originalResumeText,
        resumeData,
        fileName,
        analysis,
        suggestions,
        missingKeywords,
        undoStack,
        pdfFontSize,
        status,
        errorMessage,
      ];
}

// ─── Bloc
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
      resumeData: null, // No structured data yet — user must polish first
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

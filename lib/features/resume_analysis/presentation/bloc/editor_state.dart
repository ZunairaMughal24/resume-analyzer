import 'package:equatable/equatable.dart';
import '../../domain/entities/resume_analysis.dart';
import '../../domain/entities/resume_data.dart';

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
  String toPromptString() => '\${suggestion.title}: \${suggestion.description}';
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

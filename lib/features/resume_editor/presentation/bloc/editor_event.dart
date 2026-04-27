import 'package:equatable/equatable.dart';
import 'package:resume_analyzer/features/ai_assistant/domain/entities/resume_analysis.dart';
import 'package:resume_analyzer/features/resume_editor/domain/entities/resume_data.dart';

abstract class EditorEvent extends Equatable {
  const EditorEvent();
  @override
  List<Object?> get props => [];
}

//Initializes the editor with resume text and analysis results
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

//Toggles a specific suggestion's accepted state
class ToggleSuggestion extends EditorEvent {
  final int index;
  const ToggleSuggestion(this.index);
  @override
  List<Object?> get props => [index];
}

//Toggles a specific keyword's accepted state
class ToggleKeyword extends EditorEvent {
  final int index;
  const ToggleKeyword(this.index);
  @override
  List<Object?> get props => [index];
}

enum SelectionType { suggestions, keywords, all }

//Bulk update for suggestions or keywords.
class BulkUpdateSelection extends EditorEvent {
  final bool isAccepted;
  final SelectionType type;
  const BulkUpdateSelection({required this.isAccepted, required this.type});
  @override
  List<Object?> get props => [isAccepted, type];
}

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

class ParseResumeForEditing extends EditorEvent {}

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

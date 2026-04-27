import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/resume_analysis.dart';
import '../bloc/editor_bloc.dart';
import '../widgets/suggestion_picker_section.dart';
import '../widgets/resume_text_editor.dart';
import '../widgets/pdf_preview_tab.dart';

enum EditorStartTab { suggestions, editor }

class ResumeEditorPage extends StatelessWidget {
  final String resumeText;
  final String fileName;
  final ResumeAnalysis analysis;

  final EditorStartTab startTab;

  const ResumeEditorPage({
    super.key,
    required this.resumeText,
    required this.fileName,
    required this.analysis,
    this.startTab = EditorStartTab.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditorBloc(sl.polishResumeUseCase)
        ..add(InitializeEditor(
          resumeText: resumeText,
          fileName: fileName,
          analysis: analysis,
        )),
      child: _EditorPageBody(startTab: startTab),
    );
  }
}

class _EditorPageBody extends StatefulWidget {
  final EditorStartTab startTab;
  const _EditorPageBody({required this.startTab});

  @override
  State<_EditorPageBody> createState() => _EditorPageBodyState();
}

class _EditorPageBodyState extends State<_EditorPageBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const int _tabSuggestions = 0;
  static const int _tabEditor = 1;
  static const int _tabPreview = 2;

  @override
  void initState() {
    super.initState();
    final initialIndex =
        widget.startTab == EditorStartTab.editor ? _tabEditor : _tabSuggestions;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialIndex,
    );

    if (widget.startTab == EditorStartTab.editor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<EditorBloc>().add(ParseResumeForEditing());
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onPolishComplete() {
    _tabController.animateTo(_tabPreview);
  }

  void _goToPreview() {
    _tabController.animateTo(_tabPreview);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditorBloc, EditorState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status || prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.status == EditorStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: Column(children: [
          _buildTabBar(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SuggestionPickerSection(onApplied: _onPolishComplete),
                ResumeTextEditor(onPreviewTap: _goToPreview),
                const PdfPreviewTab(),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 15, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: BlocBuilder<EditorBloc, EditorState>(
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.fileName,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 16),
            ),
            if (state.isModified)
              Text(
                'Modified',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.accentWarm, fontSize: 10),
              ),
          ],
        ),
      ),
      actions: [
        BlocBuilder<EditorBloc, EditorState>(
          builder: (context, state) => Row(
            children: [
              if (state.canUndo)
                IconButton(
                  icon: const Icon(Icons.undo_rounded,
                      size: 20, color: AppColors.textSecondary),
                  onPressed: () => context.read<EditorBloc>().add(UndoEdit()),
                  tooltip: 'Undo last edit',
                ),
              if (state.status == EditorStatus.polishing)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
            bottom: BorderSide(color: AppColors.border.withOpacity(0.5))),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
        tabs: const [
          Tab(
              text: 'Suggestions',
              icon: Icon(Icons.checklist_rounded, size: 20)),
          Tab(text: 'Editor', icon: Icon(Icons.edit_rounded, size: 20)),
          Tab(
              text: 'Preview',
              icon: Icon(Icons.picture_as_pdf_rounded, size: 20)),
        ],
      ),
    );
  }
}

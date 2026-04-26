import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/resume_analysis.dart';
import '../bloc/editor_bloc.dart';
import '../widgets/suggestion_picker_section.dart';
import '../widgets/resume_text_editor.dart';
import '../widgets/editor_bottom_bar.dart';
import '../widgets/save_share_sheet.dart';
import '../widgets/pdf_preview_tab.dart';

class ResumeEditorPage extends StatelessWidget {
  final String resumeText;
  final String fileName;
  final ResumeAnalysis analysis;

  const ResumeEditorPage({
    super.key,
    required this.resumeText,
    required this.fileName,
    required this.analysis,
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
      child: const _EditorPageBody(),
    );
  }
}

class _EditorPageBody extends StatefulWidget {
  const _EditorPageBody();
  @override
  State<_EditorPageBody> createState() => _EditorPageBodyState();
}

class _EditorPageBodyState extends State<_EditorPageBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSaveShareSheet() {
    final state = context.read<EditorBloc>().state;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SaveShareSheet(
        resumeText: state.currentResumeText,
        resumeData: state.resumeData,
        fileName: state.fileName,
        onRename: (name) => context.read<EditorBloc>().add(RenameResume(name)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditorBloc, EditorState>(
      listenWhen: (p, c) => p.status != c.status,
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
        // After polish completes, switch to editor tab to show the result
        if (state.status == EditorStatus.loaded && state.isModified) {
          _tabController.animateTo(1);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Row(children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Resume polished successfully!'),
            ]),
            backgroundColor: AppColors.primary.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ));
        }
      },
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: false,
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context, state),
          body: Column(children: [
            // Tab bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                    bottom: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.5))),
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
            ),
            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  SuggestionPickerSection(),
                  ResumeTextEditor(),
                  PdfPreviewTab(),
                ],
              ),
            ),
          ]),
          bottomNavigationBar:
              EditorBottomBar(onSaveShare: _showSaveShareSheet),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, EditorState state) {
    return AppBar(
      backgroundColor: AppColors.background,
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(state.fileName,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 16)),
          if (state.isModified)
            Text('Modified',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.accentWarm, fontSize: 10)),
        ],
      ),
      actions: [
        if (state.canUndo)
          IconButton(
            icon: const Icon(Icons.undo_rounded,
                size: 20, color: AppColors.textSecondary),
            onPressed: () => context.read<EditorBloc>().add(UndoEdit()),
            tooltip: 'Undo',
          ),
        if (state.status == EditorStatus.polishing)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
                child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary))),
          ),
        const SizedBox(width: 4),
      ],
    );
  }
}

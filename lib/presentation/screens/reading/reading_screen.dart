import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pagepilot/core/constants/app_constants.dart';
import 'package:pagepilot/core/theme/app_theme.dart';
import 'package:pagepilot/data/database/app_database.dart';
import 'package:pagepilot/domain/engines/discipline_engine.dart';
import 'package:pagepilot/presentation/providers/database_provider.dart';
import 'package:pagepilot/presentation/providers/book_providers.dart';
import 'package:pagepilot/presentation/providers/reading_providers.dart';
import 'package:pagepilot/presentation/providers/settings_provider.dart';
import 'package:pagepilot/presentation/screens/reading/widgets/notes_panel.dart';
import 'package:pagepilot/presentation/screens/reading/widgets/highlight_panel.dart';
import 'package:pagepilot/presentation/screens/reading/widgets/ai_panel.dart';
import 'package:pagepilot/presentation/screens/reading/widgets/focus_timer_widget.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  final int bookId;

  const ReadingScreen({super.key, required this.bookId});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  PdfViewerController? _pdfController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    setState(() => _currentPage = details.newPageNumber);
    // Persist progress on every page change
    ref.read(readingProgressNotifierProvider.notifier).updateProgress(
          bookId: widget.bookId,
          currentPage: details.newPageNumber,
          scrollOffset: 0,
        );
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) async {
    // Document loaded — restore last position
    // Restore last read position
    final progress = await ref.read(databaseProvider).getProgress(widget.bookId);
    if (!mounted) return;
    if (progress != null && progress.currentPage > 1) {
      _pdfController?.jumpToPage(progress.currentPage);
      setState(() => _currentPage = progress.currentPage);
    }
  }

  Future<void> _handleMarkComplete(Book book) async {
    final settings = ref.read(settingsProvider);

    final result = DisciplineEngine.handleMarkComplete(
      book: book,
      currentPage: _currentPage,
      extraReadingMode: settings.extraReadingMode,
      missedDayMode: settings.missedDayMode,
    );

    await ref.read(bookNotifierProvider.notifier).updateCompletedPages(
          widget.bookId,
          result.newCompletedPages,
        );

    // Refresh the book data
    ref.invalidate(bookByIdProvider(widget.bookId));

    if (!mounted) return;

    // Show message based on interaction level
    final interactionLevel = settings.interactionLevel;
    String message = result.message;

    if (interactionLevel == AppConstants.interactionMotivational &&
        result.daysAhead > 0) {
      message += '\n🎉 Outstanding discipline!';
    }

    // Show as bottom message (not popup)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: AppTheme.surfaceLight,
      ),
    );

    // Check if book is now completed
    if (result.newCompletedPages >= book.totalPages) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📚 Book completed! Congratulations!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  void _openNotesPanel(Book book) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notes',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.centerRight,
        child: NotesPanel(
          bookId: widget.bookId,
          currentPage: _currentPage,
        ),
      ),
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  void _openHighlightPanel(Book book) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Highlights',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.centerRight,
        child: HighlightPanel(
          bookId: widget.bookId,
          currentPage: _currentPage,
        ),
      ),
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  void _openAiPanel() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'AI Assistant',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.centerRight,
        child: AiPanel(
          pageText: '', // User must enter text manually due to PDF text extraction limitations
        ),
      ),
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookByIdProvider(widget.bookId));
    final settings = ref.watch(settingsProvider);

    return bookAsync.when(
      data: (book) => _buildReadingView(book, settings),
      loading: () => const Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accentBlue),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        body: Center(
          child: Text('Error: $e',
              style: const TextStyle(color: AppTheme.error)),
        ),
      ),
    );
  }

  Widget _buildReadingView(Book book, AppSettings settings) {
    final range = DisciplineEngine.calculateTodayRange(
      book: book,
      missedDayMode: settings.missedDayMode,
    );

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: SafeArea(
        child: Column(
          children: [
            // ─── TOP BAR (15%) ─────────────────────
            _buildTopBar(book, range, settings),

            // ─── PDF VIEWER (70%) ──────────────────
            Expanded(
              flex: 70,
              child: _buildPdfViewer(book),
            ),

            // ─── BOTTOM BAR (15%) ──────────────────
            _buildBottomBar(book, range),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
    Book book,
    ({int startPage, int endPage, int effectivePagesPerDay}) range,
    AppSettings settings,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.primaryNavy,
        border: Border(bottom: BorderSide(color: AppTheme.divider)),
      ),
      child: Column(
        children: [
          // First row: back + title + timer + AI
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppTheme.textPrimary, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              FocusTimerWidget(
                bookId: widget.bookId,
                currentCompletedPages: book.completedPages,
              ),
              if (settings.aiEnabled)
                IconButton(
                  icon: const Icon(Icons.psychology_rounded,
                      color: AppTheme.accentBlue, size: 22),
                  onPressed: _openAiPanel,
                  tooltip: 'AI Assistant',
                ),
            ],
          ),
          // Second row: page range info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12),
                    children: [
                      const TextSpan(
                        text: "Today's range: ",
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                      TextSpan(
                        text: 'p.${range.startPage}–${range.endPage}',
                        style: const TextStyle(
                          color: AppTheme.accentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Page $_currentPage / ${book.totalPages}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.accentBlue,
                      fontWeight: FontWeight.w500,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildPdfViewer(Book book) {
    final file = File(book.filePath);
    if (!file.existsSync()) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppTheme.error, size: 48),
            SizedBox(height: 12),
            Text(
              'PDF file not found.\nThe file may have been moved or deleted.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return SfPdfViewer.file(
      file,
      controller: _pdfController,
      onPageChanged: _onPageChanged,
      onDocumentLoaded: _onDocumentLoaded,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      enableDoubleTapZooming: true,
      pageSpacing: 4,
    );
  }

  Widget _buildBottomBar(
    Book book,
    ({int startPage, int endPage, int effectivePagesPerDay}) range,
  ) {
    final progress = book.totalPages > 0
        ? (book.completedPages / book.totalPages).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.primaryNavy,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicator
          Row(
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: AppTheme.surfaceLight,
                    color: AppTheme.accentBlue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${book.completedPages}/${book.totalPages}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BottomButton(
                icon: Icons.note_alt_rounded,
                label: 'Notes',
                onTap: () => _openNotesPanel(book),
              ),
              _BottomButton(
                icon: Icons.highlight_rounded,
                label: 'Highlight',
                onTap: () => _openHighlightPanel(book),
              ),
              _BottomButton(
                icon: Icons.check_circle_outline_rounded,
                label: 'Mark Complete',
                onTap: () => _handleMarkComplete(book),
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _BottomButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary
          ? AppTheme.accentBlue.withValues(alpha: 0.15)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isPrimary ? AppTheme.accentBlue : AppTheme.textSecondary,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color:
                      isPrimary ? AppTheme.accentBlue : AppTheme.textSecondary,
                  fontWeight:
                      isPrimary ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

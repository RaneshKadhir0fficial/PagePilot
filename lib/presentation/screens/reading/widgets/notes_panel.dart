import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pagepilot/core/theme/app_theme.dart';
import 'package:pagepilot/data/database/app_database.dart';
import 'package:pagepilot/presentation/providers/note_providers.dart';

/// Right-side slide panel for notes — does NOT navigate away.
class NotesPanel extends ConsumerStatefulWidget {
  final int bookId;
  final int currentPage;

  const NotesPanel({
    super.key,
    required this.bookId,
    required this.currentPage,
  });

  @override
  ConsumerState<NotesPanel> createState() => _NotesPanelState();
}

class _NotesPanelState extends ConsumerState<NotesPanel> {
  final _noteController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int? _editingNoteId;

  @override
  void dispose() {
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    final notifier = ref.read(noteNotifierProvider.notifier);

    if (_editingNoteId != null) {
      await notifier.updateNote(noteId: _editingNoteId!, content: text);
      setState(() => _editingNoteId = null);
    } else {
      await notifier.addNote(
        bookId: widget.bookId,
        pageNumber: widget.currentPage,
        content: text,
      );
    }
    _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesForBookProvider(widget.bookId));

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      color: AppTheme.surfaceDark,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppTheme.primaryNavy,
                border: Border(
                  bottom: BorderSide(color: AppTheme.divider),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note_alt_rounded,
                      color: AppTheme.accentBlue, size: 22),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    'Page ${widget.currentPage}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.accentBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: AppTheme.surfaceCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Notes list
            Expanded(
              child: notesAsync.when(
                data: (notes) {
                  final filtered = _searchQuery.isEmpty
                      ? notes
                      : notes
                          .where((n) =>
                              n.content.toLowerCase().contains(_searchQuery))
                          .toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No notes yet.\nAdd a note below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final note = filtered[index];
                      return _NoteCard(
                        note: note,
                        onEdit: () {
                          setState(() {
                            _editingNoteId = note.id;
                            _noteController.text = note.content;
                          });
                        },
                        onDelete: () {
                          ref
                              .read(noteNotifierProvider.notifier)
                              .deleteNote(note.id);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentBlue),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: AppTheme.error)),
                ),
              ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceCard,
                border: Border(top: BorderSide(color: AppTheme.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 14),
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: _editingNoteId != null
                            ? 'Edit note...'
                            : 'Add a note for page ${widget.currentPage}...',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _saveNote,
                    icon: Icon(
                      _editingNoteId != null ? Icons.check : Icons.send_rounded,
                      color: AppTheme.accentBlue,
                    ),
                  ),
                  if (_editingNoteId != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _editingNoteId = null;
                          _noteController.clear();
                        });
                      },
                      icon: const Icon(Icons.close, color: AppTheme.textMuted),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'p.${note.pageNumber}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(onTap: onEdit, child: const Icon(Icons.edit, size: 16, color: AppTheme.textMuted)),
              const SizedBox(width: 8),
              InkWell(onTap: onDelete, child: const Icon(Icons.delete_outline, size: 16, color: AppTheme.error)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            note.content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

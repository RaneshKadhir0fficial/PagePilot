import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:pagepilot/data/database/app_database.dart';
import 'package:pagepilot/presentation/providers/database_provider.dart';

/// Stream provider for notes of a specific book.
final notesForBookProvider =
    StreamProvider.family<List<Note>, int>((ref, bookId) {
  final db = ref.watch(databaseProvider);
  return db.watchNotesForBook(bookId);
});

/// Stream provider for notes on a specific page.
final notesForPageProvider = StreamProvider.family<List<Note>, ({int bookId, int page})>(
    (ref, params) {
  final db = ref.watch(databaseProvider);
  return db.watchNotesForPage(params.bookId, params.page);
});

/// Note operations notifier.
class NoteNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  NoteNotifier(this._db) : super(const AsyncValue.data(null));

  Future<int> addNote({
    required int bookId,
    required int pageNumber,
    required String content,
  }) async {
    return await _db.insertNote(
      NotesCompanion.insert(
        bookId: bookId,
        pageNumber: pageNumber,
        content: content,
      ),
    );
  }

  Future<void> updateNote({
    required int noteId,
    required String content,
  }) async {
    await _db.updateNote(
      NotesCompanion(
        id: Value(noteId),
        content: Value(content),
      ),
    );
  }

  Future<void> deleteNote(int noteId) async {
    await _db.deleteNote(noteId);
  }
}

final noteNotifierProvider =
    StateNotifierProvider<NoteNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return NoteNotifier(db);
});

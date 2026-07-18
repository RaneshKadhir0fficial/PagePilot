import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:pagepilot/data/database/app_database.dart';
import 'package:pagepilot/presentation/providers/database_provider.dart';

/// Stream provider for all books.
final allBooksProvider = StreamProvider<List<Book>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllBooks();
});

/// Stream provider for books in progress.
final booksInProgressProvider = StreamProvider<List<Book>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchBooksInProgress();
});

/// Stream provider for completed books.
final completedBooksProvider = StreamProvider<List<Book>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCompletedBooks();
});

/// Provider for a single book by ID.
final bookByIdProvider =
    FutureProvider.family<Book, int>((ref, bookId) {
  final db = ref.watch(databaseProvider);
  return db.getBookById(bookId);
});

/// Notifier for book mutations.
class BookNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  BookNotifier(this._db) : super(const AsyncValue.data(null));

  Future<int> addBook({
    required String title,
    required String filePath,
    required int totalPages,
    required int pagesPerDay,
    required DateTime startDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final id = await _db.insertBook(
        BooksCompanion.insert(
          title: title,
          filePath: filePath,
          totalPages: totalPages,
          pagesPerDay: pagesPerDay,
          startDate: startDate,
        ),
      );
      // Also create initial reading progress
      await _db.upsertProgress(
        ReadingProgressCompanion(
          bookId: Value(id),
          currentPage: const Value(1),
          scrollOffset: const Value(0.0),
          lastReadAt: Value(DateTime.now()),
        ),
      );
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateCompletedPages(int bookId, int pages) async {
    await _db.updateCompletedPages(bookId, pages);
    final book = await _db.getBookById(bookId);
    if (book.completedPages >= book.totalPages) {
      await _db.markBookCompleted(bookId);
    }
  }

  Future<void> deleteBook(int bookId) async {
    await _db.deleteBook(bookId);
  }
}

final bookNotifierProvider =
    StateNotifierProvider<BookNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return BookNotifier(db);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:pagepilot/data/database/app_database.dart';
import 'package:pagepilot/presentation/providers/database_provider.dart';

/// Stream provider for reading progress of a specific book.
final readingProgressProvider =
    StreamProvider.family<ReadingProgressData?, int>((ref, bookId) {
  final db = ref.watch(databaseProvider);
  return db.watchProgress(bookId);
});

/// Notifier for updating reading progress.
class ReadingProgressNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  ReadingProgressNotifier(this._db) : super(const AsyncValue.data(null));

  /// Persist current page and scroll offset on every page change.
  Future<void> updateProgress({
    required int bookId,
    required int currentPage,
    double scrollOffset = 0.0,
  }) async {
    try {
      await _db.upsertProgress(
        ReadingProgressCompanion(
          bookId: Value(bookId),
          currentPage: Value(currentPage),
          scrollOffset: Value(scrollOffset),
          lastReadAt: Value(DateTime.now()),
        ),
      );
    } catch (e) {
      // Silently handle — reading should never be interrupted by save errors
    }
  }
}

final readingProgressNotifierProvider =
    StateNotifierProvider<ReadingProgressNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return ReadingProgressNotifier(db);
});

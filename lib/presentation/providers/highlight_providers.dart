import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:pagepilot/data/database/app_database.dart';
import 'package:pagepilot/presentation/providers/database_provider.dart';

/// Stream provider for highlights of a specific book.
final highlightsForBookProvider =
    StreamProvider.family<List<Highlight>, int>((ref, bookId) {
  final db = ref.watch(databaseProvider);
  return db.watchHighlightsForBook(bookId);
});

/// Highlight operations notifier.
class HighlightNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  HighlightNotifier(this._db) : super(const AsyncValue.data(null));

  Future<int> addHighlight({
    required int bookId,
    required int pageNumber,
    required String highlightedText,
    required String color,
  }) async {
    return await _db.insertHighlight(
      HighlightsCompanion.insert(
        bookId: bookId,
        pageNumber: pageNumber,
        highlightedText: highlightedText,
        color: Value(color),
      ),
    );
  }

  Future<void> deleteHighlight(int highlightId) async {
    await _db.deleteHighlight(highlightId);
  }
}

final highlightNotifierProvider =
    StateNotifierProvider<HighlightNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return HighlightNotifier(db);
});

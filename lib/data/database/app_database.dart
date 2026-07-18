// GENERATED CODE - DO NOT MODIFY BY HAND
// Database and table definitions for PagePilot
// Run: dart run build_runner build

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ─── TABLES ─────────────────────────────────────────────

class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get filePath => text()();
  IntColumn get totalPages => integer()();
  IntColumn get pagesPerDay => integer()();
  DateTimeColumn get startDate => dateTime()();
  IntColumn get completedPages => integer().withDefault(const Constant(0))();
  TextColumn get status =>
      text().withDefault(const Constant('in_progress'))(); // in_progress, completed
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class ReadingProgress extends Table {
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get currentPage => integer().withDefault(const Constant(1))();
  RealColumn get scrollOffset =>
      real().withDefault(const Constant(0.0))();
  DateTimeColumn get lastReadAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {bookId};
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get pageNumber => integer()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Highlights extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get pageNumber => integer()();
  TextColumn get highlightedText => text()();
  TextColumn get color =>
      text().withDefault(const Constant('#FFEB3B'))(); // yellow default
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class FocusSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  IntColumn get durationMinutes => integer()();
  IntColumn get pagesCovered => integer().withDefault(const Constant(0))();
}

// ─── DATABASE ───────────────────────────────────────────

@DriftDatabase(tables: [Books, ReadingProgress, Notes, Highlights, FocusSessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ─── BOOK OPERATIONS ──────────────────────────

  Future<List<Book>> getAllBooks() => select(books).get();

  Stream<List<Book>> watchAllBooks() => select(books).watch();

  Stream<List<Book>> watchBooksInProgress() {
    return (select(books)..where((b) => b.status.equals('in_progress'))).watch();
  }

  Stream<List<Book>> watchCompletedBooks() {
    return (select(books)..where((b) => b.status.equals('completed'))).watch();
  }

  Future<Book> getBookById(int id) {
    return (select(books)..where((b) => b.id.equals(id))).getSingle();
  }

  Future<int> insertBook(BooksCompanion entry) {
    return into(books).insert(entry);
  }

  Future<bool> updateBook(BooksCompanion entry) {
    return (update(books)..where((b) => b.id.equals(entry.id.value)))
        .write(entry)
        .then((rows) => rows > 0);
  }

  Future<int> deleteBook(int id) {
    return (delete(books)..where((b) => b.id.equals(id))).go();
  }

  Future<void> markBookCompleted(int bookId) {
    return (update(books)..where((b) => b.id.equals(bookId))).write(
      const BooksCompanion(status: Value('completed')),
    );
  }

  Future<void> updateCompletedPages(int bookId, int pages) {
    return (update(books)..where((b) => b.id.equals(bookId))).write(
      BooksCompanion(completedPages: Value(pages)),
    );
  }

  // ─── READING PROGRESS OPERATIONS ─────────────

  Future<ReadingProgressData?> getProgress(int bookId) {
    return (select(readingProgress)
          ..where((r) => r.bookId.equals(bookId)))
        .getSingleOrNull();
  }

  Stream<ReadingProgressData?> watchProgress(int bookId) {
    return (select(readingProgress)
          ..where((r) => r.bookId.equals(bookId)))
        .watchSingleOrNull();
  }

  Future<void> upsertProgress(ReadingProgressCompanion entry) {
    return into(readingProgress).insertOnConflictUpdate(entry);
  }

  // ─── NOTE OPERATIONS ─────────────────────────

  Future<List<Note>> getNotesForBook(int bookId) {
    return (select(notes)
          ..where((n) => n.bookId.equals(bookId))
          ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]))
        .get();
  }

  Stream<List<Note>> watchNotesForBook(int bookId) {
    return (select(notes)
          ..where((n) => n.bookId.equals(bookId))
          ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]))
        .watch();
  }

  Future<List<Note>> getNotesForPage(int bookId, int pageNumber) {
    return (select(notes)
          ..where(
              (n) => n.bookId.equals(bookId) & n.pageNumber.equals(pageNumber)))
        .get();
  }

  Stream<List<Note>> watchNotesForPage(int bookId, int pageNumber) {
    return (select(notes)
          ..where(
              (n) => n.bookId.equals(bookId) & n.pageNumber.equals(pageNumber)))
        .watch();
  }

  Future<int> insertNote(NotesCompanion entry) {
    return into(notes).insert(entry);
  }

  Future<bool> updateNote(NotesCompanion entry) {
    return (update(notes)..where((n) => n.id.equals(entry.id.value)))
        .write(entry)
        .then((rows) => rows > 0);
  }

  Future<int> deleteNote(int id) {
    return (delete(notes)..where((n) => n.id.equals(id))).go();
  }

  // ─── HIGHLIGHT OPERATIONS ────────────────────

  Future<List<Highlight>> getHighlightsForBook(int bookId) {
    return (select(highlights)
          ..where((h) => h.bookId.equals(bookId))
          ..orderBy([(h) => OrderingTerm.asc(h.pageNumber)]))
        .get();
  }

  Stream<List<Highlight>> watchHighlightsForBook(int bookId) {
    return (select(highlights)
          ..where((h) => h.bookId.equals(bookId))
          ..orderBy([(h) => OrderingTerm.asc(h.pageNumber)]))
        .watch();
  }

  Future<List<Highlight>> getHighlightsForPage(int bookId, int pageNumber) {
    return (select(highlights)
          ..where((h) =>
              h.bookId.equals(bookId) & h.pageNumber.equals(pageNumber)))
        .get();
  }

  Future<int> insertHighlight(HighlightsCompanion entry) {
    return into(highlights).insert(entry);
  }

  Future<int> deleteHighlight(int id) {
    return (delete(highlights)..where((h) => h.id.equals(id))).go();
  }

  // ─── FOCUS SESSION OPERATIONS ────────────────

  Future<List<FocusSession>> getAllFocusSessions() {
    return (select(focusSessions)
          ..orderBy([(f) => OrderingTerm.desc(f.date)]))
        .get();
  }

  Future<List<FocusSession>> getFocusSessionsForBook(int bookId) {
    return (select(focusSessions)
          ..where((f) => f.bookId.equals(bookId))
          ..orderBy([(f) => OrderingTerm.desc(f.date)]))
        .get();
  }

  Stream<List<FocusSession>> watchAllFocusSessions() {
    return (select(focusSessions)
          ..orderBy([(f) => OrderingTerm.desc(f.date)]))
        .watch();
  }

  Future<int> insertFocusSession(FocusSessionsCompanion entry) {
    return into(focusSessions).insert(entry);
  }

  Future<double> getTotalFocusHours() async {
    final sessions = await select(focusSessions).get();
    final totalMinutes =
        sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    return totalMinutes / 60.0;
  }

  Future<int> getPagesReadThisWeek() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final sessions = await (select(focusSessions)
          ..where((f) => f.date.isBiggerOrEqualValue(startOfWeek)))
        .get();
    return sessions.fold<int>(0, (sum, s) => sum + s.pagesCovered);
  }
}

// ─── CONNECTION ─────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pagepilot.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

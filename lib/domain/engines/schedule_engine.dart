import 'package:pagepilot/data/database/app_database.dart';

/// Schedule Engine — calculates dynamic completion dates and schedule info.
/// No dates are stored — everything is computed on the fly.
class ScheduleEngine {
  ScheduleEngine._();

  /// Calculate the estimated completion date for a book.
  static DateTime estimatedCompletionDate(Book book) {
    final remaining = book.totalPages - book.completedPages;
    if (remaining <= 0) return DateTime.now();

    final remainingDays = (remaining / book.pagesPerDay).ceil();
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .add(Duration(days: remainingDays));
  }

  /// Get remaining pages.
  static int remainingPages(Book book) {
    return (book.totalPages - book.completedPages).clamp(0, book.totalPages);
  }

  /// Get remaining days based on current progress.
  static int remainingDays(Book book) {
    final remaining = remainingPages(book);
    if (remaining <= 0 || book.pagesPerDay <= 0) return 0;
    return (remaining / book.pagesPerDay).ceil();
  }

  /// Get reading progress as a fraction (0.0 - 1.0).
  static double progressFraction(Book book) {
    if (book.totalPages <= 0) return 0.0;
    return (book.completedPages / book.totalPages).clamp(0.0, 1.0);
  }
}

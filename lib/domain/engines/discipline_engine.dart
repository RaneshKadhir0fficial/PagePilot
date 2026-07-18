import 'package:pagepilot/core/constants/app_constants.dart';
import 'package:pagepilot/data/database/app_database.dart';

/// Core Discipline Engine — handles reading schedule calculation,
/// mark complete logic, and extra reading block computation.
///
/// All completion dates are DYNAMICALLY calculated. Nothing is stored.
class DisciplineEngine {
  DisciplineEngine._();

  /// Calculate today's assigned page range for a book.
  ///
  /// [missedDayMode] affects how remainingPages and pagesPerDay interact.
  /// [extraReadingMode] does NOT affect range calculation — only mark-complete.
  static ({int startPage, int endPage, int effectivePagesPerDay}) calculateTodayRange({
    required Book book,
    required String missedDayMode,
  }) {
    final remaining = book.totalPages - book.completedPages;
    if (remaining <= 0) {
      return (
        startPage: book.totalPages,
        endPage: book.totalPages,
        effectivePagesPerDay: 0,
      );
    }

    int effectivePpd = book.pagesPerDay;

    switch (missedDayMode) {
      case AppConstants.missedDayAdaptive:
        // Recalculate pagesPerDay based on remaining schedule
        final now = DateTime.now();
        final todayNorm = DateTime(now.year, now.month, now.day);
        final startNorm = DateTime(
          book.startDate.year,
          book.startDate.month,
          book.startDate.day,
        );

        // Expected completion date based on original schedule
        final originalTotalDays =
            (book.totalPages / book.pagesPerDay).ceil();
        final originalEnd = startNorm.add(Duration(days: originalTotalDays));

        final daysLeft = originalEnd.difference(todayNorm).inDays;
        if (daysLeft > 0 && remaining > 0) {
          effectivePpd = (remaining / daysLeft).ceil();
          // Don't go below original if ahead of schedule
          if (effectivePpd < book.pagesPerDay) {
            effectivePpd = book.pagesPerDay;
          }
        }
        break;

      case AppConstants.missedDayCarryForward:
        // Calculate missed pages and add to today
        final now = DateTime.now();
        final todayNorm = DateTime(now.year, now.month, now.day);
        final startNorm = DateTime(
          book.startDate.year,
          book.startDate.month,
          book.startDate.day,
        );

        final daysSinceStart = todayNorm.difference(startNorm).inDays;
        final expectedPages = daysSinceStart * book.pagesPerDay;
        final missedPages = expectedPages - book.completedPages;

        if (missedPages > 0) {
          effectivePpd = book.pagesPerDay + missedPages;
        }
        break;

      case AppConstants.missedDayAutoShift:
      default:
        // Default: just resume from where user left off
        effectivePpd = book.pagesPerDay;
        break;
    }

    final startPage = book.completedPages + 1;
    int endPage = book.completedPages + effectivePpd;
    // Clamp to total pages
    if (endPage > book.totalPages) {
      endPage = book.totalPages;
    }

    return (
      startPage: startPage,
      endPage: endPage,
      effectivePagesPerDay: effectivePpd,
    );
  }

  /// Handle "Mark Complete" action.
  ///
  /// If user is at or past endPage:
  /// - In Auto-Advance mode: calculate blocks completed
  /// - In Strict mode: mark only today's block
  ///
  /// Returns the new completedPages value and optional message.
  static ({int newCompletedPages, String message, int daysAhead}) handleMarkComplete({
    required Book book,
    required int currentPage,
    required String extraReadingMode,
    required String missedDayMode,
  }) {
    final range = calculateTodayRange(
      book: book,
      missedDayMode: missedDayMode,
    );

    if (currentPage < range.endPage) {
      return (
        newCompletedPages: book.completedPages,
        message: 'Read to page ${range.endPage} to complete today\'s target.',
        daysAhead: 0,
      );
    }

    // Guard against edge case where no pages are assigned (book complete)
    if (range.effectivePagesPerDay <= 0) {
      return (
        newCompletedPages: book.completedPages,
        message: 'No pages assigned today.',
        daysAhead: 0,
      );
    }

    // User has reached or exceeded endPage
    final pagesRead = currentPage - book.completedPages;

    if (extraReadingMode == AppConstants.extraReadingStrict) {
      // Strict mode: only mark today's assignment
      final newCompleted = book.completedPages + range.effectivePagesPerDay;
      final clamped =
          newCompleted > book.totalPages ? book.totalPages : newCompleted;
      return (
        newCompletedPages: clamped,
        message: 'Today\'s reading complete.',
        daysAhead: 0,
      );
    }

    // Auto-Advance mode: calculate how many full blocks completed
    final blocksCompleted = pagesRead ~/ range.effectivePagesPerDay;
    final pagesMarked = blocksCompleted * range.effectivePagesPerDay;

    int newCompleted = book.completedPages + pagesMarked;
    if (newCompleted > book.totalPages) {
      newCompleted = book.totalPages;
    }

    final daysAhead = blocksCompleted > 1 ? blocksCompleted - 1 : 0;
    final message = daysAhead > 0
        ? 'You\'re $daysAhead day${daysAhead > 1 ? 's' : ''} ahead!'
        : 'Today\'s reading complete.';

    return (
      newCompletedPages: newCompleted,
      message: message,
      daysAhead: daysAhead,
    );
  }

  /// Calculate completion percentage.
  static double completionPercentage(Book book) {
    if (book.totalPages == 0) return 0.0;
    return (book.completedPages / book.totalPages).clamp(0.0, 1.0);
  }

  /// Check if book is completed.
  static bool isBookCompleted(Book book) {
    return book.completedPages >= book.totalPages;
  }
}

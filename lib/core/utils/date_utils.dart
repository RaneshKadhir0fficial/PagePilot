import 'package:intl/intl.dart';

/// Utility functions for date calculations used throughout PagePilot.
class AppDateUtils {
  AppDateUtils._();

  /// Calculate remaining days to complete a book.
  static int calculateRemainingDays(int remainingPages, int pagesPerDay) {
    if (pagesPerDay <= 0) return 0;
    return (remainingPages / pagesPerDay).ceil();
  }

  /// Calculate the estimated completion date for a book.
  /// This is DYNAMICALLY recalculated — never stored.
  static DateTime calculateCompletionDate({
    required int totalPages,
    required int completedPages,
    required int pagesPerDay,
    DateTime? fromDate,
  }) {
    final now = fromDate ?? DateTime.now();
    final remainingPages = totalPages - completedPages;
    if (remainingPages <= 0) return now;
    final remainingDays = calculateRemainingDays(remainingPages, pagesPerDay);
    return DateTime(now.year, now.month, now.day)
        .add(Duration(days: remainingDays));
  }

  /// Format a date as "MMM dd, yyyy"
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format a date as "MMM dd"
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  /// Calculate current reading streak from a list of reading dates.
  /// A streak is consecutive days with at least one reading session.
  static int calculateCurrentStreak(List<DateTime> readingDates) {
    if (readingDates.isEmpty) return 0;

    // Normalize to date-only and remove duplicates
    final uniqueDates = readingDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    // Check if user read today or yesterday (grace)
    if (uniqueDates.first.difference(todayNorm).inDays < -1) return 0;

    int streak = 1;
    for (int i = 0; i < uniqueDates.length - 1; i++) {
      final diff = uniqueDates[i].difference(uniqueDates[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Calculate longest streak from a list of reading dates.
  static int calculateLongestStreak(List<DateTime> readingDates) {
    if (readingDates.isEmpty) return 0;

    final uniqueDates = readingDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    int longest = 1;
    int current = 1;
    for (int i = 1; i < uniqueDates.length; i++) {
      final diff = uniqueDates[i].difference(uniqueDates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  /// Check if a date is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get the number of days between two dates.
  static int daysBetween(DateTime from, DateTime to) {
    final fromNorm = DateTime(from.year, from.month, from.day);
    final toNorm = DateTime(to.year, to.month, to.day);
    return toNorm.difference(fromNorm).inDays;
  }
}

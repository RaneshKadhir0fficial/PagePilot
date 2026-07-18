import 'package:pagepilot/data/database/app_database.dart';

/// Momentum Engine — calculates the Momentum Score (0-100).
///
/// Based on:
/// - % daily targets completed
/// - Extra reading blocks
/// - Focus consistency
/// - Missed days penalty
class MomentumEngine {
  MomentumEngine._();

  /// Calculate the Momentum Score for a user.
  ///
  /// Takes all books and focus sessions to compute a holistic score.
  static double calculateMomentumScore({
    required List<Book> books,
    required List<FocusSession> focusSessions,
  }) {
    if (books.isEmpty) return 0.0;

    // Component 1: Target completion rate (40% weight)
    double targetCompletionScore = _calculateTargetCompletion(books);

    // Component 2: Extra reading bonus (15% weight)
    double extraReadingScore = _calculateExtraReadingBonus(books);

    // Component 3: Focus consistency (25% weight)
    double focusConsistencyScore =
        _calculateFocusConsistency(focusSessions);

    // Component 4: Missed days penalty (20% weight)
    double missedDaysPenalty = _calculateMissedDaysPenalty(focusSessions);

    double momentum = (targetCompletionScore * 0.40) +
        (extraReadingScore * 0.15) +
        (focusConsistencyScore * 0.25) +
        ((100 - missedDaysPenalty) * 0.20);

    return momentum.clamp(0.0, 100.0);
  }

  /// Calculate target completion rate across all active books.
  static double _calculateTargetCompletion(List<Book> books) {
    final activeBooks = books
        .where((b) => b.status == 'in_progress')
        .toList();
    if (activeBooks.isEmpty) {
      // If only completed books, award full score
      return books.any((b) => b.status == 'completed') ? 100.0 : 0.0;
    }

    double totalScore = 0;
    for (final book in activeBooks) {
      final now = DateTime.now();
      final todayNorm = DateTime(now.year, now.month, now.day);
      final startNorm = DateTime(
        book.startDate.year,
        book.startDate.month,
        book.startDate.day,
      );

      final daysSinceStart = todayNorm.difference(startNorm).inDays;
      if (daysSinceStart <= 0) {
        totalScore += 100.0; // Just started
        continue;
      }

      final expectedPages = daysSinceStart * book.pagesPerDay;
      if (expectedPages <= 0) {
        totalScore += 100.0;
        continue;
      }

      final ratio = book.completedPages / expectedPages;
      totalScore += (ratio * 100).clamp(0.0, 100.0);
    }

    return totalScore / activeBooks.length;
  }

  /// Calculate extra reading bonus based on pages ahead of schedule.
  static double _calculateExtraReadingBonus(List<Book> books) {
    final activeBooks = books
        .where((b) => b.status == 'in_progress')
        .toList();
    if (activeBooks.isEmpty) return 50.0;

    double totalBonus = 0;
    for (final book in activeBooks) {
      final now = DateTime.now();
      final todayNorm = DateTime(now.year, now.month, now.day);
      final startNorm = DateTime(
        book.startDate.year,
        book.startDate.month,
        book.startDate.day,
      );

      final daysSinceStart = todayNorm.difference(startNorm).inDays;
      final expectedPages =
          daysSinceStart <= 0 ? 0 : daysSinceStart * book.pagesPerDay;
      final extraPages = book.completedPages - expectedPages;

      if (extraPages > 0) {
        final extraBlocks = extraPages ~/ book.pagesPerDay;
        totalBonus += (extraBlocks * 20.0).clamp(0.0, 100.0);
      }
    }

    return (totalBonus / activeBooks.length).clamp(0.0, 100.0);
  }

  /// Calculate focus consistency based on session frequency in last 7 days.
  static double _calculateFocusConsistency(List<FocusSession> sessions) {
    if (sessions.isEmpty) return 0.0;

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final recentSessions = sessions
        .where((s) => s.date.isAfter(weekAgo))
        .toList();

    if (recentSessions.isEmpty) return 0.0;

    // Count unique days with sessions in last 7 days
    final uniqueDays = recentSessions
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet()
        .length;

    // 7/7 days = 100%, scaled
    return (uniqueDays / 7 * 100).clamp(0.0, 100.0);
  }

  /// Calculate missed days penalty.
  static double _calculateMissedDaysPenalty(List<FocusSession> sessions) {
    if (sessions.isEmpty) return 50.0; // Heavy penalty if no sessions ever

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final recentSessions = sessions
        .where((s) => s.date.isAfter(weekAgo))
        .toList();

    final activeDays = recentSessions
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet()
        .length;

    final missedDays = 7 - activeDays;
    // Each missed day = ~14 penalty points
    return (missedDays * 14.0).clamp(0.0, 100.0);
  }
}

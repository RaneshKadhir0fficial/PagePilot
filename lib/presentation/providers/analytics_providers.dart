import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pagepilot/core/utils/date_utils.dart';
import 'package:pagepilot/domain/engines/momentum_engine.dart';
import 'package:pagepilot/presentation/providers/database_provider.dart';

/// Analytics data class.
class AnalyticsData {
  final int currentStreak;
  final int longestStreak;
  final double totalFocusHours;
  final int pagesReadThisWeek;
  final double momentumScore;

  const AnalyticsData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalFocusHours = 0,
    this.pagesReadThisWeek = 0,
    this.momentumScore = 0,
  });
}

/// Analytics provider — fetches and computes all analytics data.
final analyticsProvider = FutureProvider<AnalyticsData>((ref) async {
  final db = ref.watch(databaseProvider);

  // Fetch all data
  final books = await db.getAllBooks();
  final sessions = await db.getAllFocusSessions();
  final totalHours = await db.getTotalFocusHours();
  final pagesThisWeek = await db.getPagesReadThisWeek();

  // Calculate streaks from focus session dates
  final sessionDates = sessions.map((s) => s.date).toList();
  final currentStreak = AppDateUtils.calculateCurrentStreak(sessionDates);
  final longestStreak = AppDateUtils.calculateLongestStreak(sessionDates);

  // Calculate momentum score
  final momentum = MomentumEngine.calculateMomentumScore(
    books: books,
    focusSessions: sessions,
  );

  return AnalyticsData(
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    totalFocusHours: totalHours,
    pagesReadThisWeek: pagesThisWeek,
    momentumScore: momentum,
  );
});

/// Total focus hours provider (stream for real-time updates).
final totalFocusHoursProvider = FutureProvider<double>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getTotalFocusHours();
});

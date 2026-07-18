import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pagepilot/core/constants/app_constants.dart';
import 'package:pagepilot/core/theme/app_theme.dart';
import 'package:pagepilot/presentation/providers/book_providers.dart';
import 'package:pagepilot/presentation/providers/analytics_providers.dart';
import 'package:pagepilot/presentation/screens/library/widgets/book_card.dart';
import 'package:pagepilot/presentation/screens/upload/upload_screen.dart';
import 'package:pagepilot/presentation/screens/reading/reading_screen.dart';
import 'package:pagepilot/presentation/screens/settings/settings_screen.dart';
import 'package:pagepilot/presentation/screens/analytics/analytics_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksInProgress = ref.watch(booksInProgressProvider);
    final completedBooks = ref.watch(completedBooksProvider);
    final analytics = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', width: 28, height: 28),
            const SizedBox(width: 8),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(booksInProgressProvider);
          ref.invalidate(completedBooksProvider);
          ref.invalidate(analyticsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            // ─── TOP STATS SECTION ──────────────────
            const SizedBox(height: 16),
            analytics.when(
              data: (data) => _StatsRow(
                streak: data.currentStreak,
                momentum: data.momentumScore.toInt(),
                focusHours: data.totalFocusHours,
              ),
              loading: () => const _StatsRow(
                streak: 0,
                momentum: 0,
                focusHours: 0,
              ),
              error: (_, __) => const _StatsRow(
                streak: 0,
                momentum: 0,
                focusHours: 0,
              ),
            ),

            const SizedBox(height: 24),

            // ─── BOOKS IN PROGRESS ──────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'In Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  booksInProgress.when(
                    data: (books) => Text(
                      '${books.length} book${books.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            booksInProgress.when(
              data: (books) {
                if (books.isEmpty) {
                  return _EmptyState(
                    icon: Icons.library_books_rounded,
                    message: 'No books yet.\nTap + to add your first PDF.',
                  );
                }
                return Column(
                  children: books
                      .map((book) => BookCard(
                            book: book,
                            onResume: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReadingScreen(bookId: book.id),
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppTheme.accentBlue),
                ),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text('Error: $e',
                      style: const TextStyle(color: AppTheme.error)),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ─── COMPLETED BOOKS ────────────────────
            completedBooks.when(
              data: (books) {
                if (books.isEmpty) return const SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${books.length}',
                              style: const TextStyle(
                                color: AppTheme.success,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...books.map((book) => BookCard(
                          book: book,
                          isCompleted: true,
                          onResume: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ReadingScreen(bookId: book.id),
                            ),
                          ),
                        )),
                  ],
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UploadScreen()),
        ),
        backgroundColor: AppTheme.accentBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Book',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─── STATS ROW WIDGET ─────────────────────────────

class _StatsRow extends StatelessWidget {
  final int streak;
  final int momentum;
  final double focusHours;

  const _StatsRow({
    required this.streak,
    required this.momentum,
    required this.focusHours,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.local_fire_department_rounded,
              iconColor: AppTheme.warning,
              label: 'Streak',
              value: '$streak day${streak == 1 ? '' : 's'}',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.speed_rounded,
              iconColor: AppTheme.accentBlue,
              label: 'Momentum',
              value: '$momentum',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.timer_rounded,
              iconColor: AppTheme.success,
              label: 'Focus',
              value: '${focusHours.toStringAsFixed(1)}h',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── EMPTY STATE WIDGET ───────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
      child: Column(
        children: [
          Icon(icon, size: 56, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

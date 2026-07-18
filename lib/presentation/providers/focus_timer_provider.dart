import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:pagepilot/data/database/app_database.dart';
import 'package:pagepilot/presentation/providers/database_provider.dart';

/// Focus timer state.
class FocusTimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final bool isCompleted;
  final int? bookId;

  const FocusTimerState({
    this.totalSeconds = 1500, // 25 minutes
    this.remainingSeconds = 1500,
    this.isRunning = false,
    this.isCompleted = false,
    this.bookId,
  });

  FocusTimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
    bool? isCompleted,
    int? bookId,
  }) {
    return FocusTimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
      bookId: bookId ?? this.bookId,
    );
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (totalSeconds == 0) return 0;
    return 1 - (remainingSeconds / totalSeconds);
  }
}

/// Focus timer notifier.
class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  final AppDatabase _db;
  Timer? _timer;
  DateTime? _sessionStart;
  int _pagesAtStart = 0;

  FocusTimerNotifier(this._db) : super(const FocusTimerState());

  /// Start the focus timer with given duration.
  void start({required int durationMinutes, required int bookId, int currentPages = 0}) {
    _timer?.cancel();
    _sessionStart = DateTime.now();
    _pagesAtStart = currentPages;

    final totalSecs = durationMinutes * 60;
    state = FocusTimerState(
      totalSeconds: totalSecs,
      remainingSeconds: totalSecs,
      isRunning: true,
      bookId: bookId,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _timer?.cancel();
        state = state.copyWith(
          remainingSeconds: 0,
          isRunning: false,
          isCompleted: true,
        );
        // Save session to database
        _saveFocusSession(currentPages);
      } else {
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
        );
      }
    });
  }

  /// Stop the timer and save partial session.
  void stop({int currentPages = 0}) {
    _timer?.cancel();
    if (_sessionStart != null && state.bookId != null) {
      final elapsed = DateTime.now().difference(_sessionStart!).inMinutes;
      if (elapsed > 0) {
        _saveFocusSession(currentPages);
      }
    }
    state = state.copyWith(isRunning: false);
  }

  /// Reset the timer.
  void reset() {
    _timer?.cancel();
    state = const FocusTimerState();
  }

  /// Dismiss the completion notification.
  void dismissCompletion() {
    state = state.copyWith(isCompleted: false);
  }

  /// Update timer duration (from settings).
  void setDuration(int minutes) {
    if (!state.isRunning) {
      final totalSecs = minutes * 60;
      state = FocusTimerState(
        totalSeconds: totalSecs,
        remainingSeconds: totalSecs,
      );
    }
  }

  void _saveFocusSession(int currentPages) async {
    if (state.bookId == null || _sessionStart == null) return;

    final elapsed = DateTime.now().difference(_sessionStart!).inMinutes;
    final pagesCovered = (currentPages - _pagesAtStart).clamp(0, 999);

    await _db.insertFocusSession(
      FocusSessionsCompanion.insert(
        bookId: state.bookId!,
        date: DateTime.now(),
        durationMinutes: elapsed > 0 ? elapsed : 1,
        pagesCovered: Value(pagesCovered),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusTimerProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusTimerState>((ref) {
  final db = ref.watch(databaseProvider);
  return FocusTimerNotifier(db);
});

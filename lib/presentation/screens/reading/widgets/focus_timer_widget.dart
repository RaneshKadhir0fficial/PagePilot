import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pagepilot/core/theme/app_theme.dart';
import 'package:pagepilot/presentation/providers/focus_timer_provider.dart';
import 'package:pagepilot/presentation/providers/settings_provider.dart';

/// Focus timer widget shown in the reading screen top bar.
class FocusTimerWidget extends ConsumerWidget {
  final int bookId;
  final int currentCompletedPages;

  const FocusTimerWidget({
    super.key,
    required this.bookId,
    required this.currentCompletedPages,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(focusTimerProvider);
    final settings = ref.watch(settingsProvider);

    // Show the completion bottom sheet when timer completes
    ref.listen(focusTimerProvider, (prev, next) {
      if (next.isCompleted && (prev == null || !prev.isCompleted)) {
        _showCompletionSheet(context, ref);
      }
    });

    if (timerState.isRunning) {
      return GestureDetector(
        onTap: () => _showTimerControls(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer, size: 16, color: AppTheme.accentBlue),
              const SizedBox(width: 4),
              Text(
                timerState.formattedTime,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentBlue,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.timer_rounded, color: AppTheme.textSecondary),
      tooltip: 'Start Focus Timer',
      onPressed: () {
        ref.read(focusTimerProvider.notifier).start(
              durationMinutes: settings.focusTimerDuration,
              bookId: bookId,
              currentPages: currentCompletedPages,
            );
      },
    );
  }

  void _showTimerControls(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(focusTimerProvider);
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    state.formattedTime,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: AppTheme.textPrimary,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: state.progress,
                    backgroundColor: AppTheme.surfaceLight,
                    color: AppTheme.accentBlue,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(focusTimerProvider.notifier).stop(
                                currentPages: currentCompletedPages,
                              );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                        ),
                        icon: const Icon(Icons.stop, color: Colors.white),
                        label: const Text('Stop',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCompletionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.success,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                '25-minute session completed.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Great focus! Keep up the momentum.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(focusTimerProvider.notifier).dismissCompletion();
                  Navigator.pop(context);
                },
                child: const Text('Continue Reading'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

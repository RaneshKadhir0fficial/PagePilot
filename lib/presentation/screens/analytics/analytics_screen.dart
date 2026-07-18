import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pagepilot/core/theme/app_theme.dart';
import 'package:pagepilot/presentation/providers/analytics_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        title: const Text('Analytics'),
      ),
      body: analyticsAsync.when(
        data: (data) => _buildAnalytics(context, data),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accentBlue),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: AppTheme.error)),
        ),
      ),
    );
  }

  Widget _buildAnalytics(BuildContext context, AnalyticsData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── MOMENTUM SCORE ────────────────────────
          Center(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceCard,
                border: Border.all(
                  color: _momentumColor(data.momentumScore),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _momentumColor(data.momentumScore)
                        .withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.momentumScore.toInt().toString(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: _momentumColor(data.momentumScore),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Text(
                    'Momentum',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ─── STATS GRID ────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppTheme.warning,
                  label: 'Current Streak',
                  value: '${data.currentStreak}',
                  suffix: 'day${data.currentStreak == 1 ? '' : 's'}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.emoji_events_rounded,
                  iconColor: const Color(0xFFFFD700),
                  label: 'Longest Streak',
                  value: '${data.longestStreak}',
                  suffix: 'day${data.longestStreak == 1 ? '' : 's'}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.timer_rounded,
                  iconColor: AppTheme.success,
                  label: 'Total Focus',
                  value: data.totalFocusHours.toStringAsFixed(1),
                  suffix: 'hours',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.auto_stories_rounded,
                  iconColor: AppTheme.accentBlue,
                  label: 'This Week',
                  value: '${data.pagesReadThisWeek}',
                  suffix: 'pages',
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ─── MOMENTUM BREAKDOWN ────────────────────
          const Text(
            'Momentum Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          _MomentumBar(
            label: 'Target Completion (40%)',
            value: (data.momentumScore * 0.4 / 100 * 40).clamp(0, 40),
            maxValue: 40,
            color: AppTheme.accentBlue,
          ),
          const SizedBox(height: 8),
          _MomentumBar(
            label: 'Focus Consistency (25%)',
            value: (data.momentumScore * 0.25 / 100 * 25).clamp(0, 25),
            maxValue: 25,
            color: AppTheme.success,
          ),
          const SizedBox(height: 8),
          _MomentumBar(
            label: 'Missed Days Bonus (20%)',
            value: (data.momentumScore * 0.20 / 100 * 20).clamp(0, 20),
            maxValue: 20,
            color: AppTheme.warning,
          ),
          const SizedBox(height: 8),
          _MomentumBar(
            label: 'Extra Reading (15%)',
            value: (data.momentumScore * 0.15 / 100 * 15).clamp(0, 15),
            maxValue: 15,
            color: const Color(0xFF9C27B0),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Color _momentumColor(double score) {
    if (score >= 80) return AppTheme.success;
    if (score >= 50) return AppTheme.accentBlue;
    if (score >= 25) return AppTheme.warning;
    return AppTheme.error;
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String suffix;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                suffix,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MomentumBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;

  const _MomentumBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              '${value.toInt()}/${maxValue.toInt()}',
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: maxValue > 0 ? (value / maxValue).clamp(0, 1) : 0,
            minHeight: 6,
            backgroundColor: AppTheme.surfaceLight,
            color: color,
          ),
        ),
      ],
    );
  }
}

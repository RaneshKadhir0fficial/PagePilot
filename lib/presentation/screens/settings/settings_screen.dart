import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pagepilot/core/constants/app_constants.dart';
import 'package:pagepilot/core/theme/app_theme.dart';
import 'package:pagepilot/presentation/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ─── SECTION 1: Missed Day Handling ──────
          _SectionHeader(title: 'Missed Day Handling'),
          _RadioOption(
            title: 'Auto Shift Plan',
            subtitle: 'Resume from last unread page. Extend completion date.',
            value: AppConstants.missedDayAutoShift,
            groupValue: settings.missedDayMode,
            onChanged: (v) => notifier.setMissedDayMode(v),
          ),
          _RadioOption(
            title: 'Adaptive Mode',
            subtitle: 'Slightly increase daily pages to keep original deadline.',
            value: AppConstants.missedDayAdaptive,
            groupValue: settings.missedDayMode,
            onChanged: (v) => notifier.setMissedDayMode(v),
          ),
          _RadioOption(
            title: 'Carry Forward',
            subtitle: 'Missed pages added to today\'s assignment.',
            value: AppConstants.missedDayCarryForward,
            groupValue: settings.missedDayMode,
            onChanged: (v) => notifier.setMissedDayMode(v),
          ),

          const SizedBox(height: 12),
          const Divider(color: AppTheme.divider, indent: 20, endIndent: 20),
          const SizedBox(height: 8),

          // ─── SECTION 2: Extra Reading Handling ───
          _SectionHeader(title: 'Extra Reading Handling'),
          _RadioOption(
            title: 'Auto-Advance',
            subtitle: 'Marks multiple blocks complete. Shortens finish date.',
            value: AppConstants.extraReadingAutoAdvance,
            groupValue: settings.extraReadingMode,
            onChanged: (v) => notifier.setExtraReadingMode(v),
          ),
          _RadioOption(
            title: 'Strict Mode',
            subtitle: 'Extra pages count as early reading. Schedule unchanged.',
            value: AppConstants.extraReadingStrict,
            groupValue: settings.extraReadingMode,
            onChanged: (v) => notifier.setExtraReadingMode(v),
          ),

          const SizedBox(height: 12),
          const Divider(color: AppTheme.divider, indent: 20, endIndent: 20),
          const SizedBox(height: 8),

          // ─── SECTION 3: Interaction Level ────────
          _SectionHeader(title: 'Interaction Level'),
          _RadioOption(
            title: 'Minimal',
            subtitle: 'No prompts. Only passive UI updates.',
            value: AppConstants.interactionMinimal,
            groupValue: settings.interactionLevel,
            onChanged: (v) => notifier.setInteractionLevel(v),
          ),
          _RadioOption(
            title: 'Balanced',
            subtitle: 'Bottom cards on completion. "You\'re ahead" messages.',
            value: AppConstants.interactionBalanced,
            groupValue: settings.interactionLevel,
            onChanged: (v) => notifier.setInteractionLevel(v),
          ),
          _RadioOption(
            title: 'Motivational',
            subtitle: 'Encouragement messages + milestone notifications.',
            value: AppConstants.interactionMotivational,
            groupValue: settings.interactionLevel,
            onChanged: (v) => notifier.setInteractionLevel(v),
          ),

          const SizedBox(height: 12),
          const Divider(color: AppTheme.divider, indent: 20, endIndent: 20),
          const SizedBox(height: 8),

          // ─── SECTION 4: Focus Timer ──────────────
          _SectionHeader(title: 'Focus Timer'),
          _DropdownSetting(
            title: 'Default Duration',
            value: settings.focusTimerDuration,
            items: [5, 10, 15, 20, 25, 30, 45, 60],
            suffix: 'min',
            onChanged: (v) => notifier.setFocusTimerDuration(v),
          ),
          _SwitchSetting(
            title: 'Sound on completion',
            value: settings.focusTimerSound,
            onChanged: (v) => notifier.setFocusTimerSound(v),
          ),
          _SwitchSetting(
            title: 'Vibration on completion',
            value: settings.focusTimerVibration,
            onChanged: (v) => notifier.setFocusTimerVibration(v),
          ),

          const SizedBox(height: 12),
          const Divider(color: AppTheme.divider, indent: 20, endIndent: 20),
          const SizedBox(height: 8),

          // ─── SECTION 5: AI Assistant ─────────────
          _SectionHeader(title: 'AI Assistant'),
          _SwitchSetting(
            title: 'Enable AI Assistant',
            value: settings.aiEnabled,
            onChanged: (v) => notifier.setAiEnabled(v),
          ),
          if (settings.aiEnabled) ...[
            _DropdownStringSetting(
              title: 'Model',
              value: settings.aiModel,
              items: const [
                'gemini-1.5-flash',
                'gemini-1.5-pro',
                'gemini-2.0-flash',
              ],
              onChanged: (v) => notifier.setAiModel(v),
            ),
            _DropdownSetting(
              title: 'Max pages per request',
              value: settings.aiMaxPages,
              items: [1, 2, 3, 5],
              suffix: '',
              onChanged: (v) => notifier.setAiMaxPages(v),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── HELPER WIDGETS ─────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.accentBlue,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _RadioOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentBlue.withValues(alpha: 0.1)
              : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentBlue.withValues(alpha: 0.4)
                : AppTheme.divider.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.accentBlue : AppTheme.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchSetting extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchSetting({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.accentBlue,
          ),
        ],
      ),
    );
  }
}

class _DropdownSetting extends StatelessWidget {
  final String title;
  final int value;
  final List<int> items;
  final String suffix;
  final ValueChanged<int> onChanged;

  const _DropdownSetting({
    required this.title,
    required this.value,
    required this.items,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<int>(
              value: items.contains(value) ? value : items.first,
              dropdownColor: AppTheme.surfaceCard,
              underline: const SizedBox(),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
              items: items
                  .map((v) => DropdownMenuItem(
                        value: v,
                        child: Text('$v${suffix.isNotEmpty ? ' $suffix' : ''}'),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownStringSetting extends StatelessWidget {
  final String title;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownStringSetting({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              dropdownColor: AppTheme.surfaceCard,
              underline: const SizedBox(),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
              ),
              items: items
                  .map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(v),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pagepilot/core/constants/app_constants.dart';

/// Settings state for the app.
class AppSettings {
  final String missedDayMode;
  final String extraReadingMode;
  final String interactionLevel;
  final int focusTimerDuration; // minutes
  final bool focusTimerSound;
  final bool focusTimerVibration;
  final bool aiEnabled;
  final String aiModel;
  final int aiMaxPages;

  const AppSettings({
    this.missedDayMode = AppConstants.missedDayAutoShift,
    this.extraReadingMode = AppConstants.extraReadingAutoAdvance,
    this.interactionLevel = AppConstants.interactionMinimal,
    this.focusTimerDuration = AppConstants.defaultFocusDuration,
    this.focusTimerSound = true,
    this.focusTimerVibration = true,
    this.aiEnabled = true,
    this.aiModel = AppConstants.defaultAiModel,
    this.aiMaxPages = AppConstants.defaultAiMaxPages,
  });

  AppSettings copyWith({
    String? missedDayMode,
    String? extraReadingMode,
    String? interactionLevel,
    int? focusTimerDuration,
    bool? focusTimerSound,
    bool? focusTimerVibration,
    bool? aiEnabled,
    String? aiModel,
    int? aiMaxPages,
  }) {
    return AppSettings(
      missedDayMode: missedDayMode ?? this.missedDayMode,
      extraReadingMode: extraReadingMode ?? this.extraReadingMode,
      interactionLevel: interactionLevel ?? this.interactionLevel,
      focusTimerDuration: focusTimerDuration ?? this.focusTimerDuration,
      focusTimerSound: focusTimerSound ?? this.focusTimerSound,
      focusTimerVibration: focusTimerVibration ?? this.focusTimerVibration,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      aiModel: aiModel ?? this.aiModel,
      aiMaxPages: aiMaxPages ?? this.aiMaxPages,
    );
  }
}

/// Settings notifier with SharedPreferences persistence.
class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(const AppSettings()) {
    _load();
  }

  void _load() {
    state = AppSettings(
      missedDayMode: _prefs.getString(AppConstants.keyMissedDayMode) ??
          AppConstants.missedDayAutoShift,
      extraReadingMode:
          _prefs.getString(AppConstants.keyExtraReadingMode) ??
              AppConstants.extraReadingAutoAdvance,
      interactionLevel:
          _prefs.getString(AppConstants.keyInteractionLevel) ??
              AppConstants.interactionMinimal,
      focusTimerDuration:
          _prefs.getInt(AppConstants.keyFocusTimerDuration) ??
              AppConstants.defaultFocusDuration,
      focusTimerSound:
          _prefs.getBool(AppConstants.keyFocusTimerSound) ?? true,
      focusTimerVibration:
          _prefs.getBool(AppConstants.keyFocusTimerVibration) ?? true,
      aiEnabled: _prefs.getBool(AppConstants.keyAiEnabled) ?? true,
      aiModel: _prefs.getString(AppConstants.keyAiModel) ??
          AppConstants.defaultAiModel,
      aiMaxPages: _prefs.getInt(AppConstants.keyAiMaxPages) ??
          AppConstants.defaultAiMaxPages,
    );
  }

  Future<void> setMissedDayMode(String mode) async {
    await _prefs.setString(AppConstants.keyMissedDayMode, mode);
    state = state.copyWith(missedDayMode: mode);
  }

  Future<void> setExtraReadingMode(String mode) async {
    await _prefs.setString(AppConstants.keyExtraReadingMode, mode);
    state = state.copyWith(extraReadingMode: mode);
  }

  Future<void> setInteractionLevel(String level) async {
    await _prefs.setString(AppConstants.keyInteractionLevel, level);
    state = state.copyWith(interactionLevel: level);
  }

  Future<void> setFocusTimerDuration(int minutes) async {
    await _prefs.setInt(AppConstants.keyFocusTimerDuration, minutes);
    state = state.copyWith(focusTimerDuration: minutes);
  }

  Future<void> setFocusTimerSound(bool enabled) async {
    await _prefs.setBool(AppConstants.keyFocusTimerSound, enabled);
    state = state.copyWith(focusTimerSound: enabled);
  }

  Future<void> setFocusTimerVibration(bool enabled) async {
    await _prefs.setBool(AppConstants.keyFocusTimerVibration, enabled);
    state = state.copyWith(focusTimerVibration: enabled);
  }

  Future<void> setAiEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.keyAiEnabled, enabled);
    state = state.copyWith(aiEnabled: enabled);
  }

  Future<void> setAiModel(String model) async {
    await _prefs.setString(AppConstants.keyAiModel, model);
    state = state.copyWith(aiModel: model);
  }

  Future<void> setAiMaxPages(int pages) async {
    await _prefs.setInt(AppConstants.keyAiMaxPages, pages);
    state = state.copyWith(aiMaxPages: pages);
  }
}

/// SharedPreferences provider.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

/// Settings provider.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});

/// Onboarding completion check.
final onboardingCompleteProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;
});

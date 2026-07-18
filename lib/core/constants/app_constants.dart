/// App-wide constants for PagePilot.
class AppConstants {
  AppConstants._();

  // App Identity
  static const String appName = 'PagePilot';
  static const String appTagline = 'A Reading Discipline Engine';

  // Shared Preferences Keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyMissedDayMode = 'missed_day_mode';
  static const String keyExtraReadingMode = 'extra_reading_mode';
  static const String keyInteractionLevel = 'interaction_level';
  static const String keyFocusTimerDuration = 'focus_timer_duration';
  static const String keyFocusTimerSound = 'focus_timer_sound';
  static const String keyFocusTimerVibration = 'focus_timer_vibration';
  static const String keyAiEnabled = 'ai_enabled';
  static const String keyAiModel = 'ai_model';
  static const String keyAiMaxPages = 'ai_max_pages';

  // Default values
  static const int defaultFocusDuration = 25; // minutes
  static const int defaultPagesPerDay = 5;
  static const int defaultAiMaxPages = 2;
  static const String defaultAiModel = 'gemini-1.5-flash';

  // Missed Day Modes
  static const String missedDayAutoShift = 'auto_shift';
  static const String missedDayAdaptive = 'adaptive';
  static const String missedDayCarryForward = 'carry_forward';

  // Extra Reading Modes
  static const String extraReadingAutoAdvance = 'auto_advance';
  static const String extraReadingStrict = 'strict';

  // Interaction Levels
  static const String interactionMinimal = 'minimal';
  static const String interactionBalanced = 'balanced';
  static const String interactionMotivational = 'motivational';

  // Book Status
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';

  // Highlight Colors
  static const List<String> highlightColors = [
    '#FFEB3B', // Yellow
    '#4CAF50', // Green
    '#2196F3', // Blue
    '#FF9800', // Orange
    '#E91E63', // Pink
    '#9C27B0', // Purple
  ];
}

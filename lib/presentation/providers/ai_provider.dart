import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pagepilot/data/datasources/gemini_api_service.dart';
import 'package:pagepilot/presentation/providers/settings_provider.dart';

/// AI response state.
class AiState {
  final String? response;
  final bool isLoading;
  final String? error;

  const AiState({this.response, this.isLoading = false, this.error});

  AiState copyWith({String? response, bool? isLoading, String? error, bool clearError = false}) {
    return AiState(
      response: response ?? this.response,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// AI assistant notifier.
class AiNotifier extends StateNotifier<AiState> {
  final GeminiApiService _service;

  AiNotifier(this._service) : super(const AiState());

  Future<void> sendAction({
    required String action,
    required String text,
  }) async {
    state = const AiState(isLoading: true);

    final response = await _service.sendPrompt(
      action: action,
      text: text,
    );

    if (response.startsWith('AI Error:') ||
        response == 'Internet required for AI.') {
      state = AiState(error: response);
    } else {
      state = AiState(response: response);
    }
  }

  void clear() {
    state = const AiState();
  }
}

/// Gemini service provider.
final geminiServiceProvider = Provider<GeminiApiService>((ref) {
  final settings = ref.watch(settingsProvider);
  return GeminiApiService(modelName: settings.aiModel);
});

/// AI notifier provider.
final aiProvider =
    StateNotifierProvider<AiNotifier, AiState>((ref) {
  final service = ref.watch(geminiServiceProvider);
  return AiNotifier(service);
});

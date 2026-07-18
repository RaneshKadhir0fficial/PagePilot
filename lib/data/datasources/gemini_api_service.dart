import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Gemini API Service for AI-powered reading assistance.
///
/// Key constraints:
/// - Only analyzes currently visible page(s)
/// - Never loads entire PDF
/// - Never stores content externally
/// - Sends only selected text
class GeminiApiService {
  // API Key — hardcoded for personal use (will not be published)
  static const String _apiKey = 'AIzaSyB57MHFmCWpnBLtnp7VQYBUe58NL8X_uEs';

  String _modelName;

  GeminiApiService({String modelName = 'gemini-1.5-flash'})
      : _modelName = modelName;

  /// Update the model being used.
  void updateModel(String modelName) {
    _modelName = modelName;
  }

  GenerativeModel get _currentModel {
    return GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
    );
  }

  /// Check if internet is available.
  static Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Send a structured prompt to Gemini.
  /// Returns the AI response text, or an error message.
  Future<String> sendPrompt({
    required String action,
    required String text,
  }) async {
    // Check connectivity
    if (!await isOnline()) {
      return 'Internet required for AI.';
    }

    final prompt = _buildPrompt(action, text);

    try {
      final content = [Content.text(prompt)];
      final response = await _currentModel.generateContent(content);
      return response.text ?? 'No response generated.';
    } catch (e) {
      return 'AI Error: ${e.toString()}';
    }
  }

  /// Build a structured prompt based on the action type.
  String _buildPrompt(String action, String text) {
    switch (action) {
      case 'summarize':
        return 'Summarize the following text in under 150 words:\n\n$text';
      case 'explain':
        return 'Explain the following text in simple, easy-to-understand language:\n\n$text';
      case 'key_points':
        return 'Extract the key points from the following text as a bullet list:\n\n$text';
      case 'examples':
        return 'Give practical examples to illustrate the concepts in the following text:\n\n$text';
      case 'highlight_concepts':
        return 'Identify and explain the most important concepts in the following text:\n\n$text';
      default:
        return 'Analyze the following text:\n\n$text';
    }
  }
}

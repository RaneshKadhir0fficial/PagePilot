import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pagepilot/core/theme/app_theme.dart';
import 'package:pagepilot/presentation/providers/ai_provider.dart';
import 'package:pagepilot/presentation/providers/settings_provider.dart';

/// AI Assistant panel with 5 action buttons.
class AiPanel extends ConsumerStatefulWidget {
  final String pageText;

  const AiPanel({
    super.key,
    required this.pageText,
  });

  @override
  ConsumerState<AiPanel> createState() => _AiPanelState();
}

class _AiPanelState extends ConsumerState<AiPanel> {
  final _customTextController = TextEditingController();
  bool _useCustomText = false;

  @override
  void dispose() {
    _customTextController.dispose();
    super.dispose();
  }

  String get _textToAnalyze =>
      _useCustomText && _customTextController.text.trim().isNotEmpty
          ? _customTextController.text.trim()
          : widget.pageText;

  void _sendAction(String action) {
    final text = _textToAnalyze;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No text to analyze. Enter text manually.'),
        ),
      );
      return;
    }
    ref.read(aiProvider.notifier).sendAction(action: action, text: text);
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiProvider);
    final settings = ref.watch(settingsProvider);

    if (!settings.aiEnabled) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.85,
        color: AppTheme.surfaceDark,
        child: const Center(
          child: Text(
            'AI Assistant is disabled.\nEnable it in Settings.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
          ),
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      color: AppTheme.surfaceDark,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppTheme.primaryNavy,
                border: Border(bottom: BorderSide(color: AppTheme.divider)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology_rounded,
                      color: AppTheme.accentBlue, size: 22),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'AI Assistant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: AppTheme.textMuted),
                    onPressed: () {
                      ref.read(aiProvider.notifier).clear();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Custom text toggle
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Switch(
                        value: _useCustomText,
                        onChanged: (v) =>
                            setState(() => _useCustomText = v),
                        activeThumbColor: AppTheme.accentBlue,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Enter text manually',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_useCustomText) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customTextController,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 14),
                      maxLines: 5,
                      minLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Paste or type text to analyze...',
                        contentPadding: const EdgeInsets.all(12),
                        filled: true,
                        fillColor: AppTheme.surfaceCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ActionButton(
                    icon: Icons.summarize_rounded,
                    label: 'Summarize',
                    onTap: () => _sendAction('summarize'),
                  ),
                  _ActionButton(
                    icon: Icons.lightbulb_outline_rounded,
                    label: 'Explain Simply',
                    onTap: () => _sendAction('explain'),
                  ),
                  _ActionButton(
                    icon: Icons.list_alt_rounded,
                    label: 'Key Points',
                    onTap: () => _sendAction('key_points'),
                  ),
                  _ActionButton(
                    icon: Icons.school_rounded,
                    label: 'Give Examples',
                    onTap: () => _sendAction('examples'),
                  ),
                  _ActionButton(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Highlight Concepts',
                    onTap: () => _sendAction('highlight_concepts'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(color: AppTheme.divider, height: 1),

            // Response area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildResponse(aiState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponse(AiState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.accentBlue),
            SizedBox(height: 12),
            Text(
              'Analyzing...',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.error!,
                style: const TextStyle(color: AppTheme.error, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    if (state.response != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider.withValues(alpha: 0.4)),
        ),
        child: SelectableText(
          state.response!,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textPrimary,
            height: 1.6,
          ),
        ),
      );
    }

    return const Center(
      child: Text(
        'Select an action above to analyze the current page content.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceCard,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.divider.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppTheme.accentBlue),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

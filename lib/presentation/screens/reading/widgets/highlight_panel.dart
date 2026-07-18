import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pagepilot/core/constants/app_constants.dart';
import 'package:pagepilot/core/theme/app_theme.dart';
import 'package:pagepilot/presentation/providers/highlight_providers.dart';

/// Highlight panel — allows adding highlights with text + color + page.
class HighlightPanel extends ConsumerStatefulWidget {
  final int bookId;
  final int currentPage;

  const HighlightPanel({
    super.key,
    required this.bookId,
    required this.currentPage,
  });

  @override
  ConsumerState<HighlightPanel> createState() => _HighlightPanelState();
}

class _HighlightPanelState extends ConsumerState<HighlightPanel> {
  final _textController = TextEditingController();
  String _selectedColor = AppConstants.highlightColors[0];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _addHighlight() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await ref.read(highlightNotifierProvider.notifier).addHighlight(
          bookId: widget.bookId,
          pageNumber: widget.currentPage,
          highlightedText: text,
          color: _selectedColor,
        );
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final highlightsAsync =
        ref.watch(highlightsForBookProvider(widget.bookId));

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
                  const Icon(Icons.highlight_rounded,
                      color: Color(0xFFFFEB3B), size: 22),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Highlights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    'Page ${widget.currentPage}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.accentBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Color picker
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Text(
                    'Color: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  ...AppConstants.highlightColors.map(
                    (color) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _colorFromHex(color),
                          shape: BoxShape.circle,
                          border: _selectedColor == color
                              ? Border.all(
                                  color: AppTheme.white, width: 2)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Highlights list
            Expanded(
              child: highlightsAsync.when(
                data: (highlights) {
                  if (highlights.isEmpty) {
                    return const Center(
                      child: Text(
                        'No highlights yet.\nAdd highlighted text below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: highlights.length,
                    itemBuilder: (context, index) {
                      final h = highlights[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(
                              color: _colorFromHex(h.color),
                              width: 3,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _colorFromHex(h.color)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'p.${h.pageNumber}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _colorFromHex(h.color),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: () => ref
                                      .read(highlightNotifierProvider.notifier)
                                      .deleteHighlight(h.id),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: AppTheme.error,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '"${h.highlightedText}"',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child:
                      CircularProgressIndicator(color: AppTheme.accentBlue),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: AppTheme.error)),
                ),
              ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceCard,
                border: Border(top: BorderSide(color: AppTheme.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 14),
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText:
                            'Type text to highlight from page ${widget.currentPage}...',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addHighlight,
                    icon: const Icon(Icons.add_circle_rounded,
                        color: AppTheme.accentBlue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('FF');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

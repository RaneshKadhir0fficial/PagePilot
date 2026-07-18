import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pagepilot/core/theme/app_theme.dart';
import 'package:pagepilot/core/utils/date_utils.dart';
import 'package:pagepilot/presentation/providers/book_providers.dart';
import 'package:pagepilot/presentation/screens/reading/reading_screen.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  // Step 1 state
  String? _filePath;
  String? _fileName;
  int? _totalPages;
  bool _isPicking = false;

  // Step 2 state
  final _titleController = TextEditingController();
  int _pagesPerDay = 5;
  DateTime _startDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    setState(() => _isPicking = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final name = result.files.single.name;

        // Extract total page count using Syncfusion PDF
        final file = File(path);
        final bytes = await file.readAsBytes();
        final document = PdfDocument(inputBytes: bytes);
        final pageCount = document.pages.count;
        document.dispose();

        setState(() {
          _filePath = path;
          _fileName = name;
          _totalPages = pageCount;
          _titleController.text = name.replaceAll('.pdf', '').replaceAll('_', ' ');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reading PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _saveBook() async {
    if (_filePath == null || _totalPages == null) return;
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final bookId = await ref.read(bookNotifierProvider.notifier).addBook(
        title: _titleController.text.trim(),
        filePath: _filePath!,
        totalPages: _totalPages!,
        pagesPerDay: _pagesPerDay,
        startDate: _startDate,
      );

      if (!mounted) return;
      // Navigate directly to reading screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ReadingScreen(bookId: bookId)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving book: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingDays = _totalPages != null
        ? AppDateUtils.calculateRemainingDays(_totalPages!, _pagesPerDay)
        : 0;
    final completionDate = _startDate.add(Duration(days: remainingDays));

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        title: const Text('Add New Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── STEP 1: Select PDF ─────────────────
            const Text(
              'Step 1: Select PDF',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.accentBlue,
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _isPicking ? null : _pickPdf,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _filePath != null
                        ? AppTheme.success.withValues(alpha: 0.5)
                        : AppTheme.divider,
                    width: _filePath != null ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    if (_isPicking)
                      const CircularProgressIndicator(color: AppTheme.accentBlue)
                    else
                      Icon(
                        _filePath != null
                            ? Icons.check_circle_rounded
                            : Icons.upload_file_rounded,
                        size: 48,
                        color: _filePath != null
                            ? AppTheme.success
                            : AppTheme.textMuted,
                      ),
                    const SizedBox(height: 12),
                    Text(
                      _filePath != null
                          ? _fileName ?? 'File selected'
                          : 'Tap to select a PDF file',
                      style: TextStyle(
                        fontSize: 15,
                        color: _filePath != null
                            ? AppTheme.textPrimary
                            : AppTheme.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_totalPages != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$_totalPages pages detected',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.accentBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (_filePath != null) ...[
              const SizedBox(height: 28),

              // ─── STEP 2: Setup Fields ────────────────
              const Text(
                'Step 2: Configure',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentBlue,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Title',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Book title',
                ),
              ),

              const SizedBox(height: 20),

              // Pages per Day
              const Text(
                'Pages per Day',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: DropdownButton<int>(
                  value: _pagesPerDay.clamp(1, 30),
                  isExpanded: true,
                  dropdownColor: AppTheme.surfaceCard,
                  underline: const SizedBox(),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                  ),
                  items: [
                    ...List.generate(30, (i) => i + 1).map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text('$v page${v == 1 ? '' : 's'}'),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _pagesPerDay = v);
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Start Date
              const Text(
                'Start Date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppTheme.accentBlue,
                            surface: AppTheme.surfaceCard,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => _startDate = picked);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppDateUtils.formatDate(_startDate),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: AppTheme.textMuted,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.accentBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reading Plan Summary',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Total Pages',
                      value: '$_totalPages',
                    ),
                    _SummaryRow(
                      label: 'Pages per Day',
                      value: '$_pagesPerDay',
                    ),
                    _SummaryRow(
                      label: 'Days to Complete',
                      value: '$remainingDays',
                    ),
                    _SummaryRow(
                      label: 'Est. Completion',
                      value: AppDateUtils.formatDate(completionDate),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    disabledBackgroundColor: AppTheme.surfaceLight,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Start Reading',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
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
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

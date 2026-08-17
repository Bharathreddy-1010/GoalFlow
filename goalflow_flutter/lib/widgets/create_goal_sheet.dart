import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class CreateGoalSheet extends StatefulWidget {
  final Function({
    required String title,
    required String description,
    required String category,
    required String startDate,
    required String targetDate,
  }) onCreateGoal;

  const CreateGoalSheet({super.key, required this.onCreateGoal});

  @override
  State<CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<CreateGoalSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Health';
  final List<String> _categories = ['Health', 'Learning', 'Fitness', 'Career', 'Finance', 'Personal'];

  // Timeline Start & End Dates
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate.add(const Duration(days: 1)) : _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2035),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  int get _totalDays {
    return _endDate.difference(_startDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    final String startDateStr = formatter.format(_startDate);
    final String endDateStr = formatter.format(_endDate);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Add New Goal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Title Field
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'e.g. Build a consistent morning routine',
                labelText: 'Goal Title',
              ),
            ),
            const SizedBox(height: 12),

            // Description Field
            TextField(
              controller: _descController,
              maxLines: 2,
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Brief summary of what you want to achieve',
                labelText: 'Description',
              ),
            ),
            const SizedBox(height: 16),

            // Category Chips
            const Text(
              'Category',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                  selectedColor: AppTheme.primaryGreen,
                  backgroundColor: AppTheme.surfaceElevated,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.border,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Goal Timeline (Start Date & End Date Pickers)
            const Text(
              'Goal Timeline',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                // Start Date Picker
                Expanded(
                  child: GestureDetector(
                    onTap: _selectStartDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Date',
                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 15, color: AppTheme.primaryGreen),
                              const SizedBox(width: 6),
                              Text(
                                startDateStr,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // End Date Picker
                Expanded(
                  child: GestureDetector(
                    onTap: _selectEndDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'End Date',
                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.flag_rounded, size: 15, color: AppTheme.primaryGreen),
                              const SizedBox(width: 6),
                              Text(
                                endDateStr,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Timeline Duration Badge Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreenLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Timeline: $_totalDays Days ($startDateStr → $endDateStr)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.trim().isEmpty) return;
                  widget.onCreateGoal(
                    title: _titleController.text.trim(),
                    description: _descController.text.trim(),
                    category: _selectedCategory,
                    startDate: startDateStr,
                    targetDate: endDateStr,
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Create Goal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'app_toast.dart';

class AiTipsModal extends StatefulWidget {
  final String goalTitle;
  final String? description;
  final String? category;
  final String? taskTitle;
  final bool showCategorySelector;

  const AiTipsModal({
    super.key,
    required this.goalTitle,
    this.description,
    this.category,
    this.taskTitle,
    this.showCategorySelector = false,
  });

  static void show(
    BuildContext context, {
    required String goalTitle,
    String? description,
    String? category,
    String? taskTitle,
    bool showCategorySelector = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AiTipsModal(
        goalTitle: goalTitle,
        description: description,
        category: category,
        taskTitle: taskTitle,
        showCategorySelector: showCategorySelector,
      ),
    );
  }

  @override
  State<AiTipsModal> createState() => _AiTipsModalState();
}

class _AiTipsModalState extends State<AiTipsModal> {
  bool _isLoading = true;
  List<Map<String, String>> _tips = [];
  late String _selectedCategory;

  final List<Map<String, dynamic>> _categories = const [
    {'id': 'Learning', 'label': 'Learning', 'icon': Icons.school_outlined},
    {'id': 'Fitness', 'label': 'Fitness', 'icon': Icons.fitness_center_rounded},
    {'id': 'Health', 'label': 'Health', 'icon': Icons.favorite_outline_rounded},
    {'id': 'Career', 'label': 'Career', 'icon': Icons.work_outline_rounded},
    {'id': 'Finance', 'label': 'Finance', 'icon': Icons.account_balance_wallet_outlined},
    {'id': 'Personal', 'label': 'Personal', 'icon': Icons.person_outline_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category ?? 'Learning';
    _loadTips(_selectedCategory);
  }

  Future<void> _loadTips(String category) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
    });

    final fetchedTips = await ApiService.fetchAiTips(
      goalTitle: widget.showCategorySelector ? '$category Action Plan' : widget.goalTitle,
      description: widget.description ?? 'Actionable guidance for $category goals',
      category: category,
      taskTitle: widget.taskTitle ?? '$category focus',
    );

    if (mounted) {
      setState(() {
        _tips = fetchedTips;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.taskTitle != null && widget.taskTitle!.isNotEmpty
        ? widget.taskTitle!
        : widget.goalTitle;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header with AI Sparkles
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.greenBgSubtle,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryGreen, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.showCategorySelector ? 'AI Daily Insights' : 'AI Action Tips',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                          child: const Text(
                            'GROQ LLM',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.showCategorySelector
                          ? 'Select a domain to generate real-time tips:'
                          : 'Tailored for: "$titleText"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 20),
              ),
            ],
          ),

          if (widget.showCategorySelector) ...[
            const SizedBox(height: 16),
            // Category Option Selector Bar (Home Page Only)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _categories.map((cat) {
                  final catId = cat['id'] as String;
                  final isSelected = _selectedCategory.toLowerCase() == catId.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(
                        cat['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : AppTheme.primaryGreen,
                      ),
                      label: Text(cat['label'] as String),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryGreen,
                      backgroundColor: AppTheme.greenBgSubtle,
                      checkmarkColor: Colors.white,
                      showCheckmark: isSelected,
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryGreen : AppTheme.border,
                        width: 1.2,
                      ),
                      onSelected: (val) {
                        if (!isSelected) {
                          _loadTips(catId);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Content Area
          if (_isLoading)
            Container(
              height: 220,
              width: double.infinity,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Generating AI tips with Groq Llama 3.3...',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: _tips.map((tip) => _buildTipCard(tip)).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTipCard(Map<String, String> tip) {
    final title = tip['title'] ?? 'Action Tip';
    final desc = tip['desc'] ?? '';
    final category = tip['category'] ?? _selectedCategory;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.25),
          width: 1.1,
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.greenBgSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.textMuted),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: '$title: $desc'));
                  AppToast.show(
                    context,
                    'Tip copied to clipboard!',
                    icon: Icons.content_copy_rounded,
                  );
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

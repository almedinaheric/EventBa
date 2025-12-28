import 'package:flutter/material.dart';
import 'package:eventba_mobile/models/category/category_model.dart';

class CategorySelectionWidget extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<String> selectedCategoryIds;
  final Function(List<String>) onCategoriesChanged;
  final String subtitle;

  const CategorySelectionWidget({
    super.key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onCategoriesChanged,
    this.subtitle = "Select categories you're interested in",
  });

  @override
  State<CategorySelectionWidget> createState() =>
      _CategorySelectionWidgetState();
}

class _CategorySelectionWidgetState extends State<CategorySelectionWidget> {
  late List<String> _selectedCategoryIds;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIds = List.from(widget.selectedCategoryIds);
  }

  @override
  void didUpdateWidget(CategorySelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    
    if (oldWidget.selectedCategoryIds.length !=
            widget.selectedCategoryIds.length ||
        !oldWidget.selectedCategoryIds.every(
          (id) => widget.selectedCategoryIds.contains(id),
        )) {
      setState(() {
        _selectedCategoryIds = List.from(widget.selectedCategoryIds);
      });
    }
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
    widget.onCategoriesChanged(_selectedCategoryIds);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: widget.categories
              .map(
                (category) => GestureDetector(
                  onTap: () => _toggleCategory(category.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedCategoryIds.contains(category.id)
                          ? const Color(0xFF5B7CF6)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedCategoryIds.contains(category.id)
                            ? const Color(0xFF5B7CF6)
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        color: _selectedCategoryIds.contains(category.id)
                            ? Colors.white
                            : const Color(0xFF343A40),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

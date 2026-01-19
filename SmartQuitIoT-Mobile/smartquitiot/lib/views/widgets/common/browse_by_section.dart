import 'package:flutter/material.dart';

class BrowseBySection extends StatelessWidget {
  final String selectedCategory;
  final List<Map<String, dynamic>> categories;
  final Function(String) onCategorySelected;
  final VoidCallback? onFilterTap;

  const BrowseBySection({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Browse By',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onFilterTap,
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Trending',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) => 
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildCategoryTab(category),
              ),
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTab(Map<String, dynamic> category) {
    final isSelected = selectedCategory == category['title'];
    
    return GestureDetector(
      onTap: () => onCategorySelected(category['title']),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D09E) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category['emoji'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              category['title'],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

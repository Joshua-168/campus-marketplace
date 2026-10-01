import 'package:flutter/material.dart';

import '../../../app/constants/app_colors.dart';
import '../../../domain/entities/resource_entity.dart';

class CategorySelector extends StatelessWidget {
  final ResourceCategory? selectedCategory;
  final ValueChanged<ResourceCategory?> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  IconData _getCategoryIcon(ResourceCategory cat) {
    switch (cat) {
      case ResourceCategory.books:
        return Icons.menu_book_rounded;
      case ResourceCategory.electronics:
        return Icons.devices_rounded;
      case ResourceCategory.labEquipment:
        return Icons.science_rounded;
      case ResourceCategory.sportsEquipment:
        return Icons.sports_basketball_rounded;
      case ResourceCategory.projectKits:
        return Icons.memory_rounded;
      case ResourceCategory.musicalInstruments:
        return Icons.music_note_rounded;
      case ResourceCategory.hostelEssentials:
        return Icons.king_bed_rounded;
      case ResourceCategory.others:
        return Icons.widgets_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: ResourceCategory.values.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : ResourceCategory.values[index - 1];
          final isSelected = selectedCategory == category;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onCategorySelected(category),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected ? null : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppColors.cardDarkHover,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAll ? Icons.grid_view_rounded : _getCategoryIcon(category!),
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.textSecondaryDark,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAll ? 'All Categories' : category!.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimaryDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

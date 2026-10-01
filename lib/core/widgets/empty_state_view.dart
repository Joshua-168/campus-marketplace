import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import 'custom_button.dart';

/// Reusable Empty State Component with icon, title, description, and optional action.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onActionButtonPressed;

  const EmptyStateView({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.description,
    this.buttonText,
    this.onActionButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onActionButtonPressed != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 180,
                child: CustomButton(
                  text: buttonText!,
                  onPressed: onActionButtonPressed,
                  height: 46,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

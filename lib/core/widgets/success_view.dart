import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants/app_colors.dart';
import '../../app/router/route_constants.dart';
import 'custom_button.dart';

class SuccessView extends StatefulWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onContinue;

  const SuccessView({
    super.key,
    this.title = 'Success!',
    this.message = 'Your action was completed successfully.',
    this.buttonText = 'Back to Home',
    this.onContinue,
  });

  @override
  State<SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<SuccessView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondaryDark,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              CustomButton(
                text: widget.buttonText,
                onPressed: () {
                  if (widget.onContinue != null) {
                    widget.onContinue!();
                  } else {
                    context.goNamed(RouteConstants.homeName);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

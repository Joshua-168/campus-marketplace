import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../domain/entities/request_entity.dart';
import '../../../domain/entities/resource_entity.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/request_provider.dart';

class RequestDialog extends ConsumerStatefulWidget {
  final ResourceEntity resource;

  const RequestDialog({super.key, required this.resource});

  static Future<void> show(BuildContext context, ResourceEntity resource) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => RequestDialog(resource: resource),
    );
  }

  @override
  ConsumerState<RequestDialog> createState() => _RequestDialogState();
}

class _RequestDialogState extends ConsumerState<RequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  int _durationDays = 7;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submitRequest() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = ref.read(authNotifierProvider).user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to send a request.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final request = RequestEntity(
        id: const Uuid().v4(),
        resourceId: widget.resource.id,
        resourceTitle: widget.resource.title,
        resourceImageUrl: widget.resource.imageUrl,
        borrowerId: user.id,
        borrowerName: user.name,
        borrowerEmail: user.email,
        ownerId: widget.resource.ownerId,
        ownerName: widget.resource.ownerName,
        ownerEmail: widget.resource.ownerEmail,
        status: RequestStatus.pending,
        notes: _notesController.text.trim(),
        proposedDurationDays: _durationDays,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await ref.read(requestNotifierProvider.notifier).sendRequest(request);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request sent to resource owner!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          final errorMsg = ref.read(requestNotifierProvider).errorMessage ?? 'Failed to send request.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requestState = ref.watch(requestNotifierProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request Resource',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Item Quick Info Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.resource.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          'Owner: ${widget.resource.ownerName}',
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Proposed Duration Selector
            Text(
              'Proposed Borrow Duration (Days)',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [3, 7, 14, 30].map((days) {
                final isSelected = _durationDays == days;
                return ChoiceChip(
                  label: Text('$days Days'),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _durationDays = days);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Note to Owner Text Field
            CustomTextField(
              label: 'Message / Note to Owner',
              hint: 'Hi! I need this textbook for my midterms next week. I can pick it up at the library...',
              controller: _notesController,
              maxLines: 3,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please add a brief message for the owner';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            CustomButton(
              text: 'Submit Borrow Request',
              isLoading: requestState.isLoading,
              onPressed: _submitRequest,
            ),
          ],
        ),
      ),
    );
  }
}

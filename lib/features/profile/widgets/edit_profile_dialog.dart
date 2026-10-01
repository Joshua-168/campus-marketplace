import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_colors.dart';
import '../../../core/utils/auth_validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../domain/entities/user_entity.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  final UserEntity user;

  const EditProfileDialog({super.key, required this.user});

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late String _selectedDept;
  late String _selectedYear;

  static const List<String> _departments = [
    'Computer Science & Engineering',
    'Electronics & Communication',
    'Electrical & Electronics',
    'Mechanical Engineering',
    'Civil Engineering',
    'Information Technology',
    'Biotechnology',
  ];

  static const List<String> _years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Post Graduate',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _bioController = TextEditingController(text: widget.user.bio);
    _selectedDept = _departments.contains(widget.user.department)
        ? widget.user.department
        : _departments.first;
    _selectedYear = _years.contains(widget.user.year)
        ? widget.user.year
        : _years[2];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updated = widget.user.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        department: _selectedDept,
        year: _selectedYear,
        bio: _bioController.text.trim(),
      );

      final success = await ref.read(authNotifierProvider.notifier).updateProfile(updated);

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully! ✨'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          final error = ref.read(authNotifierProvider).errorMessage ?? 'Update failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
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
    final authState = ref.watch(authNotifierProvider);

    return Dialog(
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit Student Profile', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Full Name',
                controller: _nameController,
                prefixIcon: Icons.person_outline_rounded,
                validator: AuthValidators.validateName,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_android_rounded,
                validator: AuthValidators.validatePhone,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedDept,
                decoration: InputDecoration(
                  labelText: 'Department',
                  prefixIcon: const Icon(Icons.school_outlined, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.backgroundDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: _departments.map((dept) {
                  return DropdownMenuItem(value: dept, child: Text(dept, style: const TextStyle(fontSize: 13)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDept = val);
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedYear,
                decoration: InputDecoration(
                  labelText: 'Academic Year',
                  prefixIcon: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.backgroundDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: _years.map((y) {
                  return DropdownMenuItem(value: y, child: Text(y));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedYear = val);
                },
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Bio',
                controller: _bioController,
                maxLines: 3,
                hint: 'Brief student bio...',
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Save Changes',
                isLoading: authState.isLoading,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

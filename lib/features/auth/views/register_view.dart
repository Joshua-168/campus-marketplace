import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_strings.dart';
import '../../../core/utils/auth_validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterView extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToLogin;
  final VoidCallback onRegisterSuccess;

  const RegisterView({
    super.key,
    required this.onNavigateToLogin,
    required this.onRegisterSuccess,
  });

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _campusController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  String _selectedDept = 'Computer Science & Engineering';
  String _selectedYear = '3rd Year';

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
  void dispose() {
    _nameController.dispose();
    _campusController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authNotifierProvider.notifier).register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            campusName: _campusController.text.trim(),
            department: _selectedDept,
            year: _selectedYear,
            phoneNumber: _phoneController.text.trim(),
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.emailVerificationSent),
              backgroundColor: AppColors.success,
            ),
          );
          widget.onRegisterSuccess();
        } else {
          final errorMsg = ref.read(authNotifierProvider).errorMessage ?? AppStrings.genericError;
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
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onNavigateToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.createAccount,
                  style: theme.textTheme.headlineLarge?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.registerSubtitle,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),

                CustomTextField(
                  label: 'Full Name',
                  hint: 'Sam Joshua',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: AuthValidators.validateName,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Campus / University Name',
                  hint: 'Chennai Institute of Technology',
                  controller: _campusController,
                  prefixIcon: Icons.school_outlined,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter your campus name' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _selectedDept,
                  decoration: InputDecoration(
                    labelText: 'Department',
                    prefixIcon: const Icon(Icons.apartment_rounded, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.cardDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDept = val);
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _selectedYear,
                  decoration: InputDecoration(
                    labelText: 'Academic Year',
                    prefixIcon: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.cardDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedYear = val);
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Phone Number',
                  hint: '+91 98765 43210',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android_rounded,
                  validator: AuthValidators.validatePhone,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Campus Email',
                  hint: 'samjoshuas.it2024@citchennai.net',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: AuthValidators.validateEmail,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: AuthValidators.validatePassword,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Confirm Password',
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_clock_outlined,
                  validator: (val) {
                    if (val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                CustomButton(
                  text: 'Create Account',
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: widget.onNavigateToLogin,
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/router/route_constants.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/success_view.dart';
import '../../../domain/entities/resource_entity.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/upload_resource_provider.dart';
import '../widgets/image_picker_widget.dart';

class AddListingView extends ConsumerStatefulWidget {
  final ResourceEntity? existingResource;

  const AddListingView({super.key, this.existingResource});

  @override
  ConsumerState<AddListingView> createState() => _AddListingViewState();
}

class _AddListingViewState extends ConsumerState<AddListingView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();
  final _imageUrlController = TextEditingController();

  ResourceCategory _selectedCategory = ResourceCategory.books;
  ResourceCondition _selectedCondition = ResourceCondition.good;
  bool _isFreeBorrow = true;

  File? _pickedImageFile;
  bool _isUploadingImage = false;
  double _imageUploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.existingResource != null) {
      final res = widget.existingResource!;
      _titleController.text = res.title;
      _descriptionController.text = res.description;
      _selectedCategory = res.category;
      _selectedCondition = res.condition;
      _imageUrlController.text = res.imageUrl;
      _isFreeBorrow = res.price == 0;
      if (!_isFreeBorrow) {
        _priceController.text = res.price.toStringAsFixed(0);
      }
      if (res.depositAmount > 0) {
        _depositController.text = res.depositAmount.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = ref.read(authNotifierProvider).user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be signed in to post a resource.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      String finalImageUrl = _imageUrlController.text.trim();

      // If user picked a local image file, upload to Firebase Storage first
      if (_pickedImageFile != null) {
        setState(() {
          _isUploadingImage = true;
          _imageUploadProgress = 0.1;
        });

        try {
          final storagePath =
              '${AppConstants.resourceImagesPath}/${DateTime.now().millisecondsSinceEpoch}_${user.id}.jpg';

          final uploadedUrl = await ref.read(storageServiceProvider).uploadFile(
                path: storagePath,
                file: _pickedImageFile!,
                onProgress: (progress) {
                  setState(() => _imageUploadProgress = progress);
                },
              );

          finalImageUrl = uploadedUrl;
        } catch (e) {
          if (mounted) {
            setState(() => _isUploadingImage = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image upload failed: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        setState(() => _isUploadingImage = false);
      }

      if (finalImageUrl.isEmpty) {
        finalImageUrl =
            'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch % 100}';
      }

      final priceVal =
          _isFreeBorrow ? 0.0 : (double.tryParse(_priceController.text) ?? 0.0);
      final depositVal = double.tryParse(_depositController.text) ?? 0.0;

      bool success = false;
      if (widget.existingResource == null) {
        success =
            await ref.read(uploadResourceNotifierProvider.notifier).createListing(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  category: _selectedCategory,
                  condition: _selectedCondition,
                  price: priceVal,
                  depositAmount: depositVal,
                  ownerId: user.id,
                  ownerName: user.name,
                  ownerEmail: user.email,
                  campusName: user.campusName,
                  imageUrl: finalImageUrl,
                );
      } else {
        final updated = widget.existingResource!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          condition: _selectedCondition,
          price: priceVal,
          depositAmount: depositVal,
          imageUrl: finalImageUrl,
          updatedAt: DateTime.now(),
        );
        success = await ref
            .read(uploadResourceNotifierProvider.notifier)
            .updateListing(updated);
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SuccessView(
                title: widget.existingResource == null ? 'Listing Published! 🎉' : 'Listing Updated!',
                message: widget.existingResource == null
                    ? 'Your resource was successfully posted to the campus marketplace.'
                    : 'Your listing details were updated.',
                buttonText: 'View Marketplace',
                onContinue: () {
                  context.goNamed(RouteConstants.homeName);
                },
              ),
            ),
          );
        } else {
          final errorMsg =
              ref.read(uploadResourceNotifierProvider).errorMessage ??
                  AppStrings.genericError;
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
    final uploadState = ref.watch(uploadResourceNotifierProvider);
    final isEditing = widget.existingResource != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Resource' : 'Post Campus Resource'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Note
                Text(
                  isEditing ? 'Update Listing Details' : 'Share or Sell Resource',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Help fellow campus peers by sharing unused books, lab gear, or electronics.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Image Picker Component
                ImagePickerWidget(
                  initialImageUrl: _imageUrlController.text.isNotEmpty
                      ? _imageUrlController.text
                      : null,
                  isUploading: _isUploadingImage,
                  uploadProgress: _imageUploadProgress,
                  onImageSelected: (file) {
                    setState(() => _pickedImageFile = file);
                  },
                  onImageRemoved: () {
                    setState(() {
                      _pickedImageFile = null;
                      _imageUrlController.clear();
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Title Input
                CustomTextField(
                  label: 'Resource Title',
                  hint: 'e.g. Physics Vol 2 Textbook or TI-84 Calculator',
                  controller: _titleController,
                  prefixIcon: Icons.title_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a title for your resource';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Category Dropdown
                Text(
                  'Category',
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<ResourceCategory>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined, size: 20),
                  ),
                  items: ResourceCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 20),

                // Condition Selector Chips
                Text(
                  'Condition',
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ResourceCondition.values.map((cond) {
                    final isSelected = _selectedCondition == cond;
                    return ChoiceChip(
                      label: Text(cond.displayName),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCondition = cond);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Free Borrow / Price Mode Switch
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Free Campus Borrow',
                            style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lend for free to fellow campus students',
                            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isFreeBorrow,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) => setState(() => _isFreeBorrow = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                if (!_isFreeBorrow) ...[
                  CustomTextField(
                    label: 'Price (₹ or ₹ / day)',
                    hint: '150',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.currency_rupee_rounded,
                    validator: (val) {
                      if (!_isFreeBorrow && (val == null || val.trim().isEmpty)) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                ],

                CustomTextField(
                  label: 'Security Deposit (Optional ₹)',
                  hint: '500',
                  controller: _depositController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.security_rounded,
                ),
                const SizedBox(height: 18),

                // Description Text Area
                CustomTextField(
                  label: 'Description & Pickup Details',
                  hint: 'Describe condition, included accessories, and preferred campus pickup location...',
                  controller: _descriptionController,
                  maxLines: 4,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please provide a brief description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Optional Direct Image Link
                CustomTextField(
                  label: 'Image Web URL (Optional Fallback)',
                  hint: 'https://...',
                  controller: _imageUrlController,
                  prefixIcon: Icons.link_rounded,
                ),
                const SizedBox(height: 28),

                // Submit Button
                CustomButton(
                  text: isEditing ? 'Update Listing' : 'Post Resource Listing',
                  isLoading: uploadState.isLoading || _isUploadingImage,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

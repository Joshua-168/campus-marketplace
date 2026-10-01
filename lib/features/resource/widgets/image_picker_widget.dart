import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/constants/app_colors.dart';
import '../../../data/services/image_picker_service.dart';

/// Interactive Image Picker Container with camera/gallery modal sheet, preview, and progress bar.
class ImagePickerWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(File file)? onImageSelected;
  final VoidCallback? onImageRemoved;
  final double uploadProgress;
  final bool isUploading;

  const ImagePickerWidget({
    super.key,
    this.initialImageUrl,
    this.onImageSelected,
    this.onImageRemoved,
    this.uploadProgress = 0.0,
    this.isUploading = false,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _selectedFile;
  final ImagePickerService _pickerService = ImagePickerService();

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final file = await _pickerService.pickFromGallery();
                    if (file != null) {
                      setState(() => _selectedFile = file);
                      widget.onImageSelected?.call(file);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: AppColors.accent),
                  title: const Text('Take Photo with Camera'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final file = await _pickerService.pickFromCamera();
                    if (file != null) {
                      setState(() => _selectedFile = file);
                      widget.onImageSelected?.call(file);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasInitialImage = widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty;
    final hasImage = _selectedFile != null || hasInitialImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resource Photo',
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: widget.isUploading ? null : () => _showPickerOptions(context),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? AppColors.cardDark
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                if (_selectedFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _selectedFile!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (hasInitialImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: widget.initialImageUrl!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tap to upload a photo of your item',
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                if (widget.isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: widget.uploadProgress > 0 ? widget.uploadProgress : null,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Uploading... ${(widget.uploadProgress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (hasImage && !widget.isUploading)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedFile = null);
                        widget.onImageRemoved?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

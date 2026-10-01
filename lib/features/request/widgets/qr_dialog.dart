import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../domain/entities/request_entity.dart';

class QrDialog extends StatefulWidget {
  final RequestEntity request;
  final VoidCallback onHandoverComplete;

  const QrDialog({
    super.key,
    required this.request,
    required this.onHandoverComplete,
  });

  @override
  State<QrDialog> createState() => _QrDialogState();
}

class _QrDialogState extends State<QrDialog> {
  bool _isScanning = false;

  void _simulateScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isScanning = false);
      Navigator.of(context).pop();
      widget.onHandoverComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payload = 'CAMPUS_MARKETPLACE:${widget.request.id}:${widget.request.resourceId}';

    return Dialog(
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'QR Pickup Pass',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: QrImageView(
                data: payload,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Show this QR code to ${widget.request.ownerName} during physical handover.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: _isScanning ? 'Verifying Handover...' : 'Scan Handover QR Code',
              isLoading: _isScanning,
              onPressed: _simulateScan,
            ),
          ],
        ),
      ),
    );
  }
}

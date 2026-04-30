import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/document_request.dart';
import '../../widgets/common/app_widgets.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final request = ModalRoute.of(context)!.settings.arguments as DocumentRequest;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 56),
              ),
              const SizedBox(height: 20),
              const Text('Request Submitted\nSuccessfully!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Your application has been received and is now being processed by the barangay staff.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSub)),
              const SizedBox(height: 28),

              // Request Detail Card
              AppCard(
                child: Column(
                  children: [
                    _DetailRow('Type of Request', request.documentType),
                    const Divider(height: 20),
                    _DetailRow('Date', AppUtils.formatDate(request.createdAt)),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Reference No.', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
                        Row(
                          children: [
                            Text(request.referenceNo,
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 14)),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: request.referenceNo));
                                AppUtils.showSnack(context, 'Reference number copied!');
                              },
                              child: const Icon(Icons.copy, size: 16, color: AppColors.textSub),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Back to Home',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'View Request Status',
                outlined: true,
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.tracker, (_) => false,
                  arguments: request.id,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    ],
  );
}

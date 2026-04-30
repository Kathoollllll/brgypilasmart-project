import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/request_service.dart';
import '../../../data/models/document_request.dart';
import '../../widgets/common/app_widgets.dart';
import '../../widgets/forms/image_upload_widget.dart';

class RequestFormScreen extends StatefulWidget {
  const RequestFormScreen({super.key});

  @override
  State<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final _form       = GlobalKey<FormState>();
  final _purpose    = TextEditingController();
  final _additional = TextEditingController();
  final _auth       = AuthService();
  final _reqSvc     = RequestService();

  String? _docType;
  File? _idImage;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _docType = ModalRoute.of(context)?.settings.arguments as String?;
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = await _auth.getCurrentUserModel();
      if (user == null) throw Exception('Not logged in');

      final request = await _reqSvc.submitRequest(
        userId: user.uid,
        userName: user.fullName,
        documentType: _docType!,
        purpose: _purpose.text.trim(),
        additionalInfo: _additional.text.trim().isEmpty ? null : _additional.text.trim(),
        idImage: _idImage,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.confirmation, arguments: request);
    } catch (e) {
      AppUtils.showSnack(context, 'Submission failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _purpose.dispose(); _additional.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => LoadingOverlay(
    loading: _loading,
    child: Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Document Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Document Request', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const Text('Provide the purpose and complete the required information below.',
                style: TextStyle(fontSize: 13, color: AppColors.textSub)),
              const SizedBox(height: 20),

              // Document Type Dropdown
              const Text('DOCUMENT TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSub, letterSpacing: 1)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _docType,
                decoration: const InputDecoration(hintText: 'Select a document'),
                items: AppConstants.docTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _docType = v),
                validator: (v) => v == null ? 'Please select a document type' : null,
              ),
              const SizedBox(height: 16),

              const Text('PURPOSE OF REQUEST', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSub, letterSpacing: 1)),
              const SizedBox(height: 6),
              AppTextField(
                label: 'Purpose',
                controller: _purpose,
                hint: 'e.g., Employment, Scholarship',
                validator: (v) => AppUtils.validateRequired(v, 'Purpose'),
              ),
              const SizedBox(height: 16),

              const Text('ADDITIONAL INFORMATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSub, letterSpacing: 1)),
              const SizedBox(height: 6),
              AppTextField(
                label: 'Additional Info',
                controller: _additional,
                hint: 'Any specific details we should know?',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              const Text('VALID ID UPLOAD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSub, letterSpacing: 1)),
              const SizedBox(height: 6),
              ImageUploadWidget(onImageSelected: (f) => _idImage = f),
              const SizedBox(height: 24),

              AppButton(label: 'Submit Request', onPressed: _submit, loading: _loading),
              const SizedBox(height: 16),

              // Processing time info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.chipBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Processing Time', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
                          const SizedBox(height: 4),
                          Text(
                            'Standard requests are processed within ${AppConstants.processingDays * 24}-${AppConstants.processingDays * 48} hours. '
                            'You will receive a notification once your document is ready for digital download or pickup.',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

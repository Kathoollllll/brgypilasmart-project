import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/request_service.dart';
import '../../widgets/common/app_widgets.dart';
import '../../widgets/forms/image_upload_widget.dart';

class RequestFormScreen extends StatefulWidget {
  const RequestFormScreen({super.key});

  @override
  State<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final _form = GlobalKey<FormState>();
  final _purpose = TextEditingController();
  final _additional = TextEditingController();
  final _auth = AuthService();
  final _reqSvc = RequestService();

  String? _category;
  String? _docType;
  List<String> _availableDocTypes = [];
  File? _idImage;
  bool _loading = false;
  bool _residentVerified = false;

  @override
  void initState() {
    super.initState();
    _checkVerified();
  }

  // Future<void> _checkVerified() async {
  //   final user = await _auth.getCurrentUserModel();
  //   if (mounted) setState(() => _residentVerified = user?.isVerified ?? false);
  // }

  Future<void> _checkVerified() async {
    final user = await _auth.getCurrentUserModel();
    if (mounted) setState(() {
      // Skip upload if verified OR if they already have an ID on their profile
      _residentVerified = (user?.isVerified ?? false) || 
                          (user?.idImageUrl != null && user!.idImageUrl!.isNotEmpty);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments as String?;
    if (_availableDocTypes.isEmpty) {
      if (arg != null &&
          AppConstants.requestCategoryDocuments.containsKey(arg)) {
        _category = arg;
        _availableDocTypes = AppConstants.requestCategoryDocuments[arg]!;
        _docType = _availableDocTypes.first;
      } else {
        _availableDocTypes = AppConstants.allDocTypes;
        if (arg != null && _availableDocTypes.contains(arg)) {
          _docType = arg;
          _category = AppConstants.requestCategoryDocuments.entries
              .firstWhere(
                (entry) => entry.value.contains(arg),
                orElse: () => const MapEntry('', []),
              )
              .key;
        }
      }
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_idImage == null && !_residentVerified) {
      AppUtils.showSnack(context, 'Please upload a valid ID before submitting.',
          error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await _auth.getCurrentUserModel();
      if (user == null) throw Exception('Not logged in');

      final request = await _reqSvc.submitRequest(
        userId: user.uid,
        userName: user.fullName,
        documentType: _docType!,
        purpose: _purpose.text.trim(),
        additionalInfo:
            _additional.text.trim().isEmpty ? null : _additional.text.trim(),
        idImage: _idImage,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.confirmation,
          arguments: request);
    } catch (e) {
      final msg = e.toString().contains('too large')
          ? 'ID photo is too large. Please retake it directly with your camera.'
          : 'Submission failed. Please try again.';
      AppUtils.showSnack(context, msg, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _purpose.dispose();
    _additional.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LoadingOverlay(
        loading: _loading,
        child: Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text('Document Request'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: AppLogo(size: 22),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Document Request',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  if (_category != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text('Category: $_category',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  const SizedBox(height: 6),
                  const Text(
                      'Provide the purpose and complete the required information below.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSub)),
                  const SizedBox(height: 20),

                  // Document Type Dropdown
                  // EDITABLE: Choose which document types users can request in /lib/core/constants/app_constants.dart
                  const Text('DOCUMENT TYPE',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSub,
                          letterSpacing: 1)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _docType,
                    isExpanded: true,
                    decoration:
                        const InputDecoration(hintText: 'Select a document'),
                    items: _availableDocTypes
                        .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) => setState(() => _docType = v),
                    validator: (v) =>
                        v == null ? 'Please select a document type' : null,
                  ),
                  const SizedBox(height: 16),

                  const Text('PURPOSE OF REQUEST',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSub,
                          letterSpacing: 1)),
                  const SizedBox(height: 6),
                  AppTextField(
                    label: 'Purpose',
                    controller: _purpose,
                    hint: 'e.g., Employment, Scholarship',
                    validator: (v) => AppUtils.validateRequired(v, 'Purpose'),
                    showLabel: false,
                  ),
                  const SizedBox(height: 16),

                  const Text('ADDITIONAL INFORMATION',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSub,
                          letterSpacing: 1)),
                  const SizedBox(height: 6),
                  AppTextField(
                    label: 'Additional Info',
                    controller: _additional,
                    hint: 'Any specific details we should know?',
                    maxLines: 3,
                    showLabel: false,
                  ),
                  const SizedBox(height: 16),

                  const Text('VALID ID UPLOAD',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSub,
                          letterSpacing: 1)),
                  const SizedBox(height: 6),
                  if (_residentVerified)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF16A34A).withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified,
                              color: Color(0xFF16A34A), size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your identity is already verified. No ID upload needed.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ImageUploadWidget(onImageSelected: (f) => _idImage = f),
                  const SizedBox(height: 24),

                  AppButton(
                      label: 'Submit Request',
                      onPressed: _submit,
                      loading: _loading),
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
                        const Icon(Icons.info_outline,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Processing Time',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: AppColors.primary)),
                              const SizedBox(height: 4),
                              Text(
                                'Standard requests are processed within ${AppConstants.processingDays * 12}-${AppConstants.processingDays * 24} hours. '
                                'You will receive a notification once your document is ready for digital download or pickup.',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textSub),
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

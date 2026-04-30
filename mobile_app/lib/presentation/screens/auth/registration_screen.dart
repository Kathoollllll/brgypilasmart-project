import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/auth_service.dart';
import '../../widgets/common/app_widgets.dart';
import '../../widgets/forms/image_upload_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _form        = GlobalKey<FormState>();
  final _fullName    = TextEditingController();
  final _email       = TextEditingController();
  final _contact     = TextEditingController();
  final _address     = TextEditingController();
  final _password    = TextEditingController();
  final _confirmPass = TextEditingController();
  final _svc         = AuthService();

  String? _gender;
  DateTime? _birthdate;
  File? _idImage;
  bool _loading = false;
  bool _showPass = false;

  static const _genders = ['Male', 'Female', 'Prefer not to say'];

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_gender == null) { AppUtils.showSnack(context, 'Please select gender', error: true); return; }
    setState(() => _loading = true);
    try {
      await _svc.register(
        email: _email.text.trim(),
        password: _password.text,
        fullName: _fullName.text.trim(),
        contactNumber: _contact.text.trim(),
        address: _address.text.trim(),
        gender: _gender!,
        birthdate: _birthdate,
        idImage: _idImage,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      AppUtils.showSnack(context, 'Registration failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _birthdate = d);
  }

  @override
  void dispose() {
    _fullName.dispose(); _email.dispose(); _contact.dispose();
    _address.dispose(); _password.dispose(); _confirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LoadingOverlay(
    loading: _loading,
    child: Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Join BrgyPilaSmart', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 4),
              const Text('Create your account and get your resident profile verified for faster services.',
                style: TextStyle(fontSize: 13, color: AppColors.textSub)),
              const SizedBox(height: 24),
              AppTextField(label: 'Full Name', controller: _fullName, validator: (v) => AppUtils.validateRequired(v, 'Full name')),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Birthdate',
                controller: TextEditingController(text: _birthdate != null ? AppUtils.formatDate(_birthdate!) : ''),
                readOnly: true,
                onTap: _pickDate,
                suffix: const Icon(Icons.calendar_today, size: 18),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 14),
              AppTextField(label: 'Address', controller: _address, validator: (v) => AppUtils.validateRequired(v, 'Address'), maxLines: 2),
              const SizedBox(height: 14),
              AppTextField(label: 'Contact Number', controller: _contact, keyboardType: TextInputType.phone, validator: (v) => AppUtils.validateRequired(v, 'Contact')),
              const SizedBox(height: 14),
              AppTextField(label: 'Email Address', controller: _email, keyboardType: TextInputType.emailAddress, validator: AppUtils.validateEmail),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Create Password',
                controller: _password,
                obscure: !_showPass,
                validator: AppUtils.validatePassword,
                suffix: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _showPass = !_showPass)),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Confirm Password',
                controller: _confirmPass,
                obscure: !_showPass,
                validator: (v) => v != _password.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 20),
              const Text('Valid ID Verification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              const Text('Upload a clear photo of your National ID or Driver\'s License.', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
              const SizedBox(height: 8),
              ImageUploadWidget(onImageSelected: (f) => _idImage = f),
              const SizedBox(height: 24),
              AppButton(label: 'Submit', onPressed: _submit, loading: _loading),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(fontSize: 13, color: AppColors.textSub)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Login', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}

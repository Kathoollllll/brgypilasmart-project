import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/common/app_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _address = TextEditingController();
  final _contact = TextEditingController();
  final _email = TextEditingController();
  final _birthdateController = TextEditingController();
  final _ageController = TextEditingController();

  final _auth = AuthService();
  UserModel? _user;
  String? _gender;
  DateTime? _birthdate;
  bool _loading = true;
  bool _saving = false;

  static const _genders = ['Male', 'Female', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _auth.getCurrentUserModel();
    if (!mounted) return;
    setState(() {
      _user = user;
      _fullName.text = user?.fullName ?? '';
      _address.text = user?.address ?? '';
      _contact.text = user?.contactNumber ?? '';
      _email.text = user?.email ?? '';
      _gender = user?.gender;
      _birthdate = user?.birthdate;
      _birthdateController.text =
          _birthdate != null ? AppUtils.formatDate(_birthdate!) : '';
      _ageController.text =
          _birthdate != null ? _calculateAge(_birthdate!).toString() : '';
      _loading = false;
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (date == null) return;
    setState(() {
      _birthdate = date;
      _birthdateController.text = AppUtils.formatDate(date);
      _ageController.text = _calculateAge(date).toString();
    });
  }

  int _calculateAge(DateTime birthdate) {
    final today = DateTime.now();
    var age = today.year - birthdate.year;
    if (today.month < birthdate.month ||
        (today.month == birthdate.month && today.day < birthdate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _saveProfile() async {
    if (!_form.currentState!.validate()) return;
    if (_user == null) return;
    setState(() => _saving = true);
    try {
      final updated = _user!.copyWith(
        fullName: _fullName.text.trim(),
        contactNumber: _contact.text.trim(),
        address: _address.text.trim(),
        gender: _gender ?? _user!.gender,
        birthdate: _birthdate,
      );
      await _auth.updateUser(updated);
      if (!mounted) return;
      AppUtils.showSnack(context, 'Profile updated successfully.');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppUtils.showSnack(context, 'Update failed. Please try again.',
          error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _fullName.dispose();
    _address.dispose();
    _contact.dispose();
    _email.dispose();
    _birthdateController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LoadingOverlay(
        loading: _saving,
        child: Scaffold(
          appBar: AppBar(title: const Text('Edit Profile')),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Update your details',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        const SizedBox(height: 24),
                        AppTextField(
                            label: 'Full Name',
                            controller: _fullName,
                            validator: (v) =>
                                AppUtils.validateRequired(v, 'Full name')),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Birthdate',
                          controller: _birthdateController,
                          readOnly: true,
                          onTap: _pickDate,
                          suffix: const Icon(Icons.calendar_today, size: 18),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Age',
                          controller: _ageController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _gender,
                          decoration:
                              const InputDecoration(labelText: 'Gender'),
                          items: _genders
                              .map((g) =>
                                  DropdownMenuItem(value: g, child: Text(g)))
                              .toList(),
                          onChanged: (v) => setState(() => _gender = v),
                          validator: (v) =>
                              v == null ? 'Please select gender' : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                            label: 'Address',
                            controller: _address,
                            validator: (v) =>
                                AppUtils.validateRequired(v, 'Address'),
                            maxLines: 2),
                        const SizedBox(height: 16),
                        AppTextField(
                            label: 'Contact Number',
                            controller: _contact,
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                AppUtils.validateRequired(v, 'Contact number')),
                        const SizedBox(height: 16),
                        AppTextField(
                            label: 'Email Address',
                            controller: _email,
                            readOnly: true),
                        const SizedBox(height: 28),
                        AppButton(
                            label: 'Save Changes',
                            onPressed: _saveProfile,
                            loading: _saving),
                        const SizedBox(height: 12),
                        const Text(
                            'Email address is not editable here. To change email, please contact support.',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSub)),
                      ],
                    ),
                  ),
                ),
        ),
      );
}

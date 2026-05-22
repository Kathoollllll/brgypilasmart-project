import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/common/app_widgets.dart';
import '../../widgets/common/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await _auth.getCurrentUserModel();
    if (mounted)
      setState(() {
        _user = u;
        _loading = false;
      });
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? '
          'This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _auth.deleteAccount();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to delete account. Please log out and log back in first, then try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(AppConstants.appName),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: AppLogo(size: 22),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.chipBlue,
                      child: Icon(Icons.person,
                          color: AppColors.primary, size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(_user?.fullName ?? '',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    if (_user?.address != null)
                      Text(_user!.address,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSub)),
                    const SizedBox(height: 8),
                    if (_user?.isVerified == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified,
                                color: AppColors.success, size: 14),
                            SizedBox(width: 4),
                            Text('Verified',
                                style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Edit Profile',
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.editProfile),
                      outlined: true,
                    ),
                    const SizedBox(height: 24),

                    // Menu items
                    _MenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () {}),
                    _MenuItem(
                        icon: Icons.help_outline,
                        label: 'Help Center',
                        subtitle: 'FAQ & Support',
                        onTap: () {}),
                    const SizedBox(height: 8),
                    _MenuItem(
                        icon: Icons.logout,
                        label: 'Logout',
                        subtitle: 'Sign out of account',
                        onTap: _logout,
                        color: AppColors.error),
                    // _MenuItem(
                    //     icon: Icons.logout,
                    //     label: 'Logout',
                    //     subtitle: 'Sign out of account',
                    //     onTap: _logout,
                    //     color: AppColors.error),
                    const SizedBox(height: 8),
                    _MenuItem(
                        icon: Icons.delete_forever_outlined,
                        label: 'Delete Account',
                        subtitle: 'Permanently remove your account',
                        onTap: _deleteAccount,
                        color: AppColors.error),
                  ],
                ),
              ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: 3,
          onTap: (i) {
            const routes = [
              AppRoutes.home,
              AppRoutes.requestCats,
              AppRoutes.tracker,
              AppRoutes.profile
            ];
            if (i != 3) Navigator.pushReplacementNamed(context, routes[i]);
          },
        ),
      );
}

class _MenuItem extends StatelessWidget {
  const _MenuItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.subtitle,
      this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? subtitle;
  final Color? color;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color ?? AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: color ?? AppColors.textPrimary)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSub)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.textSub.withOpacity(0.5)),
          ],
        ),
      );
}

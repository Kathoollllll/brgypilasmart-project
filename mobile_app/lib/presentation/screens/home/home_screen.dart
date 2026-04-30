import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/request_service.dart';
import '../../../data/models/document_request.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/common/app_widgets.dart';
import '../../widgets/common/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  final _reqSvc = RequestService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await _auth.getCurrentUserModel();
    if (mounted) setState(() => _user = u);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(AppConstants.appName),
      actions: [
        IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _loadUser,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text('Hello, ${_user?.fullName.split(' ').first ?? 'there'}!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Text('Welcome back to BrgyPilaSmart! How can we assist you today?',
              style: TextStyle(fontSize: 13, color: AppColors.textSub)),
            const SizedBox(height: 20),

            // Request Document Card
            _RequestDocumentBanner(onTap: () => Navigator.pushNamed(context, AppRoutes.requestCats)),
            const SizedBox(height: 24),

            // Latest Requests
            SectionHeader(
              'Latest Request Status',
              action: TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.tracker),
                child: const Text('View all', style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(height: 12),
            if (_user != null)
              StreamBuilder<List<DocumentRequest>>(
                stream: _reqSvc.userRequests(_user!.uid),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final reqs = snap.data ?? [];
                  if (reqs.isEmpty) {
                    return const EmptyState(icon: Icons.description_outlined, title: 'No requests yet',
                      subtitle: 'Submit your first barangay document request.');
                  }
                  return Column(
                    children: reqs.take(3).map((r) => _RequestCard(request: r)).toList(),
                  );
                },
              )
            else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    ),
    bottomNavigationBar: AppBottomNav(
      currentIndex: 0,
      onTap: (i) {
        const routes = [AppRoutes.home, AppRoutes.requestCats, AppRoutes.tracker, AppRoutes.profile];
        if (i != 0) Navigator.pushReplacementNamed(context, routes[i]);
      },
    ),
  );
}

class _RequestDocumentBanner extends StatelessWidget {
  const _RequestDocumentBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Request Document', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                const SizedBox(height: 4),
                Text('Request your barangay documents online – fast and easy.',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.description_outlined, color: Colors.white, size: 28),
          ),
        ],
      ),
    ),
  );
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});
  final DocumentRequest request;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(14),
    onTap: () => Navigator.pushNamed(context, AppRoutes.tracker, arguments: request.id),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.chipBlue, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.documentType,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text('Ref #${request.referenceNo}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSub)),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: _progress(request.status),
                backgroundColor: AppColors.border,
                color: AppColors.primary,
                minHeight: 4,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        StatusBadge(request.status),
      ],
    ),
  );

  double _progress(String status) => switch (status) {
    AppConstants.statusRequested => 0.25,
    AppConstants.statusVerified  => 0.5,
    AppConstants.statusPrinted   => 0.75,
    AppConstants.statusReady     => 1.0,
    _ => 0,
  };
}

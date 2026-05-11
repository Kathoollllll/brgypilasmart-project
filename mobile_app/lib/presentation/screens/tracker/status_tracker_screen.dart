import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/request_service.dart';
import '../../../data/models/document_request.dart';
import '../../widgets/common/app_widgets.dart';
import '../../widgets/common/bottom_nav.dart';

class StatusTrackerScreen extends StatefulWidget {
  const StatusTrackerScreen({super.key});

  @override
  State<StatusTrackerScreen> createState() => _StatusTrackerScreenState();
}

class _StatusTrackerScreenState extends State<StatusTrackerScreen> {
  final _auth   = AuthService();
  final _reqSvc = RequestService();
  String? _uid;
  String? _selectedId;
  late Stream<List<DocumentRequest>> _requestsStream;  // For the disappearing requests issue

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedId = ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  void initState() {
    super.initState();
    _loadUid();
  }

  // Future<void> _loadUid() async {
  //   final u = await _auth.getCurrentUserModel();
  //   if (mounted) setState(() => _uid = u?.uid);
  // }
   Future<void> _loadUid() async {
    final u = await _auth.getCurrentUserModel();
    if (mounted) {
      setState(() {
        _uid = u?.uid;
        // Initialize stream only once when UID is available
        if (_uid != null) {
          _requestsStream = _reqSvc.userRequests(_uid!);
        }
      });
    }
  }

    @override
    Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: _uid == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<DocumentRequest>>(
              stream: _requestsStream,  // Use cached stream
              builder: (ctx, snap) {
                // Add error handling
                if (snap.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.primary),
                        const SizedBox(height: 16),
                        const Text('Failed to load requests', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(snap.error.toString(), style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Retry',
                          onPressed: () => setState(() {
                            if (_uid != null) {
                              _requestsStream = _reqSvc.userRequests(_uid!);
                            }
                          }),
                        ),
                      ],
                    ),
                  );
                }

                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reqs = snap.data ?? [];
                if (reqs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.track_changes_outlined,
                    title: 'No requests to track',
                    subtitle: 'Your submitted requests will appear here.',
                  );
                }
                final selected = _selectedId != null
                    ? reqs.firstWhere((r) => r.id == _selectedId, orElse: () => reqs.first)
                    : reqs.first;

                return Column(
                  children: [
                    // Current status chip
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          const Text('CURRENT STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSub, letterSpacing: 1)),
                          const SizedBox(width: 12),
                          Text(selected.status,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ],
                      ),
                    ),
                    // Requests list (horizontal picker)
                    if (reqs.length > 1) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: reqs.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) => ChoiceChip(
                            label: Text(reqs[i].documentType, style: const TextStyle(fontSize: 11)),
                            selected: reqs[i].id == selected.id,
                            onSelected: (_) => setState(() => _selectedId = reqs[i].id),
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(color: reqs[i].id == selected.id ? Colors.white : AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Progress stepper
                    _StatusStepper(status: selected.status),
                    const SizedBox(height: 16),

                    // Timeline
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          const Text('Timeline Activity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 12),
                          ...selected.timeline.reversed.map((t) => _TimelineItem(update: t)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (i) {
          const routes = [AppRoutes.home, AppRoutes.requestCats, AppRoutes.tracker, AppRoutes.profile];
          if (i != 2) Navigator.pushReplacementNamed(context, routes[i]);
        },
      ),
    );
  }
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: const Text(AppConstants.appName)),
//     body: _uid == null
//         ? const Center(child: CircularProgressIndicator())
//         : StreamBuilder<List<DocumentRequest>>(
//             // stream: _reqSvc.userRequests(_uid!),
//             stream: _requestsStream,
//             builder: (ctx, snap) {
//               if (snap.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               final reqs = snap.data ?? [];
//               if (reqs.isEmpty) {
//                 return const EmptyState(
//                   icon: Icons.track_changes_outlined,
//                   title: 'No requests to track',
//                   subtitle: 'Your submitted requests will appear here.',
//                 );
//               }
//               final selected = _selectedId != null
//                   ? reqs.firstWhere((r) => r.id == _selectedId, orElse: () => reqs.first)
//                   : reqs.first;

//               return Column(
//                 children: [
//                   // Current status chip
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
//                     child: Row(
//                       children: [
//                         const Text('CURRENT STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSub, letterSpacing: 1)),
//                         const SizedBox(width: 12),
//                         Text(selected.status,
//                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
//                       ],
//                     ),
//                   ),
//                   // Requests list (horizontal picker)
//                   if (reqs.length > 1) ...[
//                     const SizedBox(height: 12),
//                     SizedBox(
//                       height: 40,
//                       child: ListView.separated(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         scrollDirection: Axis.horizontal,
//                         itemCount: reqs.length,
//                         separatorBuilder: (_, __) => const SizedBox(width: 8),
//                         itemBuilder: (_, i) => ChoiceChip(
//                           label: Text(reqs[i].documentType, style: const TextStyle(fontSize: 11)),
//                           selected: reqs[i].id == selected.id,
//                           onSelected: (_) => setState(() => _selectedId = reqs[i].id),
//                           selectedColor: AppColors.primary,
//                           labelStyle: TextStyle(color: reqs[i].id == selected.id ? Colors.white : AppColors.textPrimary),
//                         ),
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 16),

//                   // Progress stepper
//                   _StatusStepper(status: selected.status),
//                   const SizedBox(height: 16),

//                   // Timeline
//                   Expanded(
//                     child: ListView(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       children: [
//                         const Text('Timeline Activity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
//                         const SizedBox(height: 12),
//                         ...selected.timeline.reversed.map((t) => _TimelineItem(update: t)),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//     bottomNavigationBar: AppBottomNav(
//       currentIndex: 2,
//       onTap: (i) {
//         const routes = [AppRoutes.home, AppRoutes.requestCats, AppRoutes.tracker, AppRoutes.profile];
//         if (i != 2) Navigator.pushReplacementNamed(context, routes[i]);
//       },
//     ),
//   );
// }

class _StatusStepper extends StatelessWidget {
  const _StatusStepper({required this.status});
  final String status;

  static const _steps = AppConstants.allStatuses;

  @override
  Widget build(BuildContext context) {
    final idx = _steps.indexOf(status);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIdx = (i ~/ 2) + 1;
            return Expanded(
              child: Container(
                height: 2,
                color: stepIdx <= idx ? AppColors.primary : AppColors.border,
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final done = stepIdx <= idx;
          return Column(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: done ? AppColors.primary : AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: Icon(done ? Icons.check : Icons.circle, color: Colors.white, size: 14),
              ),
              const SizedBox(height: 4),
              Text(_steps[stepIdx], style: TextStyle(fontSize: 9, color: done ? AppColors.primary : AppColors.textSub, fontWeight: FontWeight.w500)),
            ],
          );
        }),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.update});
  final StatusUpdate update;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        children: [
          Container(
            width: 10, height: 10,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          ),
          Container(width: 2, height: 60, color: AppColors.border),
        ],
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(update.status, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(AppUtils.formatTime(update.timestamp), style: const TextStyle(fontSize: 11, color: AppColors.textSub)),
              ],
            ),
            if (update.note != null)
              Text(update.note!, style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
            const SizedBox(height: 4),
            Text(AppUtils.formatDate(update.timestamp), style: const TextStyle(fontSize: 11, color: AppColors.textSub)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ],
  );
}

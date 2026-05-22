import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/request_service.dart';
import '../../../data/models/document_request.dart';
import '../../widgets/common/app_widgets.dart';
import '../../widgets/common/bottom_nav.dart';

String _normalizeStatus(String status) =>
    status == 'Printed' ? AppConstants.statusPrinted : status;

class StatusTrackerScreen extends StatefulWidget {
  const StatusTrackerScreen({super.key});

  @override
  State<StatusTrackerScreen> createState() => _StatusTrackerScreenState();
}

class _StatusTrackerScreenState extends State<StatusTrackerScreen> {
  final _auth = AuthService();
  final _reqSvc = RequestService();
  String? _uid;
  String? _selectedId;
  late Stream<List<DocumentRequest>>
      _requestsStream; // For the disappearing requests issue

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

  Future<void> _confirmCancel(DocumentRequest request) async {
    if (request.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text('Are you sure you want to cancel this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _reqSvc.cancelRequest(request.id!);
    if (!mounted) return;
    AppUtils.showSnack(context, 'Request cancelled successfully.');
    setState(() => _selectedId = null);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(AppConstants.appName), actions: const [
          Padding(
              padding: EdgeInsets.only(right: 12), child: AppLogo(size: 22)),
        ]),
        body: _uid == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<List<DocumentRequest>>(
                stream: _requestsStream, // Use cached stream
                builder: (ctx, snap) {
                  // Add error handling
                  if (snap.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: AppColors.primary),
                          const SizedBox(height: 16),
                          const Text('Failed to load requests',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(snap.error.toString(),
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSub)),
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
                      ? reqs.firstWhere((r) => r.id == _selectedId,
                          orElse: () => reqs.first)
                      : reqs.first;

                  final displayStatus = _normalizeStatus(selected.status);
                  final latest = selected.timeline.isNotEmpty
                      ? selected.timeline.last
                      : StatusUpdate(
                          status: displayStatus,
                          timestamp: selected.createdAt,
                          note: 'No updates yet.');
                  // If the request has been picked up/collected, override the note
                  final lowerStatus = displayStatus.toLowerCase();
                  final latestNoteLower = (latest.note ?? '').toLowerCase();
                  final isCollected = lowerStatus.contains('pick') ||
                      lowerStatus.contains('collec') ||
                      latestNoteLower.contains('collect') ||
                      latestNoteLower.contains('picked');
                  final displayNote = isCollected
                      ? 'The document has been collected. Request closed.'
                      : (latest.note ?? 'No updates yet.');
                  return Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            const SizedBox(height: 16),
                            const Text('CURRENT STATUS',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSub,
                                    letterSpacing: 1)),
                            const SizedBox(height: 8),
                            Text(displayStatus,
                                style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary)),
                            const SizedBox(height: 4),
                            Text(
                                'Your request for ${selected.documentType} is now ${displayStatus.toLowerCase()}.',
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.textSub)),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.primary.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.update,
                                        color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Latest update',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14)),
                                        const SizedBox(height: 6),
                                        Text(displayNote,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSub)),
                                        const SizedBox(height: 6),
                                        Text(
                                            AppUtils.formatDate(
                                                latest.timestamp),
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textSub)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (reqs.length > 1) ...[
                              SizedBox(
                                height: 46,
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: reqs.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 10),
                                  itemBuilder: (_, i) {
                                    final item = reqs[i];
                                    final selectedItem = item.id == selected.id;
                                    return ChoiceChip(
                                      label: Text(item.documentType,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: selectedItem
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                          )),
                                      selected: selectedItem,
                                      selectedColor: AppColors.primary,
                                      backgroundColor: AppColors.surface,
                                      onSelected: (_) =>
                                          setState(() => _selectedId = item.id),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            _StatusStepper(timeline: selected.timeline),
                            const SizedBox(height: 24),
                            const Text('Timeline Activity',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 15)),
                            const SizedBox(height: 12),
                            ...selected.timeline.reversed
                                .map((t) => _TimelineItem(update: t)),
                            const SizedBox(height: 24),
                            // Disable cancel when request reached a final status
                            Builder(builder: (ctx) {
                              final status =
                                  (selected.status ?? '').toLowerCase();
                              final latestNote = (selected.timeline.isNotEmpty
                                      ? (selected.timeline.last.note ?? '')
                                      : '')
                                  .toLowerCase();
                              const finalKeywords = [
                                'pick',
                                'ready',
                                'done',
                                'close',
                                'complete',
                                'collec',
                                'cancel',
                              ];
                              final isFinal = finalKeywords.any((k) =>
                                  status.contains(k) || latestNote.contains(k));
                              return OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isFinal
                                      ? AppColors.textSub
                                      : AppColors.error,
                                  side: BorderSide(
                                      color: isFinal
                                          ? AppColors.border
                                          : AppColors.error),
                                  minimumSize: const Size(double.infinity, 52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: isFinal
                                    ? null
                                    : () => _confirmCancel(selected),
                                child: const Text('Cancel Request'),
                              );
                            }),
                            const SizedBox(height: 24),
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
            const routes = [
              AppRoutes.home,
              AppRoutes.requestCats,
              AppRoutes.tracker,
              AppRoutes.profile
            ];
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
  const _StatusStepper({required this.timeline});
  final List<StatusUpdate> timeline;

  static const _steps = AppConstants.allStatuses;

  int _maxCompletedIndex() {
    var maxIndex = -1;
    for (final update in timeline) {
      final status = _normalizeStatus(update.status);
      final index = _steps.indexOf(status);
      if (index > maxIndex) maxIndex = index;
    }
    return maxIndex;
  }

  @override
  Widget build(BuildContext context) {
    final maxCompleted = _maxCompletedIndex();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: List.generate(_steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final stepIdx = (i ~/ 2) + 1;
                return Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: stepIdx <= maxCompleted
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }
              final stepIdx = i ~/ 2;
              final done = stepIdx <= maxCompleted;
              return Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: done ? AppColors.primary : Colors.white,
                      border: Border.all(
                          color: done ? AppColors.primary : AppColors.border,
                          width: 2),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x11000000),
                            blurRadius: 2,
                            offset: Offset(0, 1))
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        done ? Icons.check : Icons.circle,
                        color: done ? Colors.white : AppColors.textSub,
                        size: done ? 18 : 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 70,
                    child: Text(_steps[stepIdx],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            color: done ? AppColors.primary : AppColors.textSub,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              );
            }),
          ),
        ],
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
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
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
                    Text(_normalizeStatus(update.status),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(AppUtils.formatTime(update.timestamp),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSub)),
                  ],
                ),
                if (update.note != null)
                  Text(update.note!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSub)),
                const SizedBox(height: 4),
                Text(AppUtils.formatDate(update.timestamp),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSub)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      );
}

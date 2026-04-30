import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/app_widgets.dart';
import '../../widgets/common/bottom_nav.dart';

class RequestCategoriesScreen extends StatelessWidget {
  const RequestCategoriesScreen({super.key});

  static const _categories = [
    _Category('Personal ID', Icons.badge_outlined, 'Barangay Clearance', AppColors.primary),
    _Category('Financial Aid', Icons.attach_money, 'Certificate of Indigency', Color(0xFFEA580C)),
    _Category('Employment', Icons.work_outline, 'Certificate of Residency', Color(0xFF7C3AED)),
    _Category('Business', Icons.store_outlined, 'Business Clearance', Color(0xFF059669)),
    _Category('Legal & Travel', Icons.gavel_outlined, 'Barangay ID', Color(0xFFDC2626)),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppConstants.appName)),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Document Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              SizedBox(height: 4),
              Text('Select a document type to continue.', style: TextStyle(fontSize: 13, color: AppColors.textSub)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _categories.length,
            itemBuilder: (_, i) => _CategoryTile(
              category: _categories[i],
              onTap: () => Navigator.pushNamed(
                context, AppRoutes.requestForm,
                arguments: _categories[i].docType,
              ),
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: AppBottomNav(
      currentIndex: 1,
      onTap: (i) {
        const routes = [AppRoutes.home, AppRoutes.requestCats, AppRoutes.tracker, AppRoutes.profile];
        if (i != 1) Navigator.pushReplacementNamed(context, routes[i]);
      },
    ),
  );
}

class _Category {
  const _Category(this.label, this.icon, this.docType, this.color);
  final String label;
  final IconData icon;
  final String docType;
  final Color color;
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});
  final _Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(category.icon, color: category.color, size: 28),
        ),
        const SizedBox(height: 10),
        Text(category.label, textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(category.docType, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: AppColors.textSub)),
      ],
    ),
  );
}

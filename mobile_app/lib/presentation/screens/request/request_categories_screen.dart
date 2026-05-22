import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/app_widgets.dart';
import '../../widgets/common/bottom_nav.dart';

class RequestCategoriesScreen extends StatelessWidget {
  const RequestCategoriesScreen({super.key});

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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Document Categories',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  SizedBox(height: 4),
                  Text('Select a document type to continue.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSub)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.05,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: AppConstants.requestCategoryList.length,
                itemBuilder: (_, i) {
                  final category = AppConstants.requestCategoryList[i];
                  return _CategoryTile(
                    category: category,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.requestForm,
                      arguments: category.label,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: 1,
          onTap: (i) {
            const routes = [
              AppRoutes.home,
              AppRoutes.requestCats,
              AppRoutes.tracker,
              AppRoutes.profile
            ];
            if (i != 1) Navigator.pushReplacementNamed(context, routes[i]);
          },
        ),
      );
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});
  final RequestCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(category.icon, color: category.color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(category.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text(category.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSub, height: 1.3)),
          ],
        ),
      );
}

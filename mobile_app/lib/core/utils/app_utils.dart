import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppUtils {
  // Validators
  static String? validateRequired(String? v, [String label = 'Field']) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  static String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return re.hasMatch(v) ? null : 'Enter a valid email';
  }

  static String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    return v.length < 6 ? 'Minimum 6 characters' : null;
  }

  // Formatters
  static String formatDate(DateTime d) => DateFormat('MMMM d, yyyy').format(d);
  static String formatTime(DateTime d) => DateFormat('h:mm a').format(d);

  static String generateRefNo(String docType) {
    final prefix = docType.split(' ').map((w) => w[0]).join();
    final year = DateTime.now().year;
    final id = DateTime.now().millisecondsSinceEpoch % 10000;
    return '$prefix-$year-${id.toString().padLeft(4, '0')}';
  }

  static Route<T> fadeRoute<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );
  }

  // Snackbar
  static void showSnack(BuildContext ctx, String msg, {bool error = false}) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }
}

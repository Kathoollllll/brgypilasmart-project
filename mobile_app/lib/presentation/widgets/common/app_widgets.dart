import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

// ─── Primary Button ───────────────────────────────────────────────────────────
class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, required this.onPressed, this.loading = false, this.outlined = false});
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;

  @override
  Widget build(BuildContext context) => outlined
      ? OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: AppColors.primary),
          ),
          child: _child(AppColors.primary),
        )
      : ElevatedButton(
          onPressed: loading ? null : onPressed,
          child: _child(Colors.white),
        );

  Widget _child(Color c) => loading
      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: c, strokeWidth: 2))
      : Text(label);
}

// ─── Text Field ───────────────────────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  const AppTextField({super.key, required this.label, this.controller, this.validator,
    this.obscure = false, this.keyboardType, this.suffix, this.maxLines = 1, this.hint, this.readOnly = false, this.onTap});
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final int maxLines;
  final String? hint;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    obscureText: obscure,
    keyboardType: keyboardType,
    maxLines: maxLines,
    readOnly: readOnly,
    onTap: onTap,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
    ),
  );
}

// ─── Card ─────────────────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.onTap, this.color});
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => Card(
    color: color,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final String status;

  static Color _bg(String s) => switch (s) {
    AppConstants.statusRequested => const Color(0xFFFEF3C7),
    AppConstants.statusVerified  => const Color(0xFFDCFCE7),
    AppConstants.statusPrinted   => const Color(0xFFDBEAFE),
    AppConstants.statusReady     => const Color(0xFFD1FAE5),
    _ => const Color(0xFFF3F4F6),
  };

  static Color _fg(String s) => switch (s) {
    AppConstants.statusRequested => const Color(0xFFD97706),
    AppConstants.statusVerified  => const Color(0xFF16A34A),
    AppConstants.statusPrinted   => const Color(0xFF1D4ED8),
    AppConstants.statusReady     => const Color(0xFF065F46),
    _ => AppColors.textSub,
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _bg(status),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(status,
      style: TextStyle(color: _fg(status), fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

// ─── Section Header ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
      const Spacer(),
      if (action != null) action!,
    ],
  );
}

// ─── Loading Overlay ─────────────────────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, required this.loading, required this.child});
  final bool loading;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      if (loading)
        const Positioned.fill(
          child: ColoredBox(
            color: Color(0x80FFFFFF),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
    ],
  );
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.subtitle});
  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: AppColors.border),
        const SizedBox(height: 16),
        Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSub)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: TextStyle(fontSize: 13, color: AppColors.textSub), textAlign: TextAlign.center),
        ],
      ],
    ),
  );
}

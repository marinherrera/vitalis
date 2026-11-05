import 'package:flutter/material.dart';
import 'package:vitalis/ui/theme/app_colors.dart';

/// Painel branco com borda fina, usado para agrupar informações.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    required this.child,
  });

  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return Material(
      color: AppColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.line),
          ),
          child: child,
        ),
      ),
    );
  }
}

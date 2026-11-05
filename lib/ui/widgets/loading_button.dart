import 'package:flutter/material.dart';
import 'package:vitalis/ui/theme/app_colors.dart';

/// Botão principal que mostra um indicador enquanto a ação está em andamento.
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.field,
              ),
            )
          : Text(label),
    );
  }
}

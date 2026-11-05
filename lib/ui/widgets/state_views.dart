import 'package:flutter/material.dart';
import 'package:vitalis/ui/theme/app_colors.dart';

/// Estado de carregamento.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de erro, com ação para o usuário resolver.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor = AppColors.riskCritical,
    this.actionLabel = 'Tentar novamente',
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final action = onAction;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: iconColor),
            const SizedBox(height: 14),
            Text(title, textAlign: TextAlign.center, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 260,
                child: FilledButton.icon(
                  onPressed: action,
                  icon: const Icon(Icons.refresh),
                  label: Text(actionLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado de lista vazia, explicando o que vai aparecer ali.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label = actionLabel;
    final action = onAction;
    // Sem rolagem própria: este estado também aparece dentro de listas.
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 32 : 48, color: AppColors.offline),
            SizedBox(height: compact ? 8 : 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: compact ? textTheme.titleMedium : textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            if (label != null && action != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 240,
                child: OutlinedButton(onPressed: action, child: Text(label)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

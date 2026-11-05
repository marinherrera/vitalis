import 'package:flutter/material.dart';

/// Título de seção com descrição opcional.
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final description = subtitle;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium),
          if (description != null) ...[
            const SizedBox(height: 2),
            Text(description, style: textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

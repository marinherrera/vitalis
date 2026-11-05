import 'package:flutter/material.dart';

/// Paleta do Vitalis: o verde da lavoura como base, o laranja do sol como
/// acento e cores de risco com contraste para leitura sob luz forte.
abstract final class AppColors {
  static const Color field = Color(0xFF1F5A3D);
  static const Color fieldDark = Color(0xFF123826);
  static const Color fieldSoft = Color(0xFFD6E8DC);
  static const Color sun = Color(0xFFE8892B);

  static const Color background = Color(0xFFF1F5F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFDCE4DD);
  static const Color ink = Color(0xFF16231B);
  static const Color muted = Color(0xFF56645B);

  static const Color riskNormal = Color(0xFF2E7D4F);
  static const Color riskAttention = Color(0xFFE0A100);
  static const Color riskCritical = Color(0xFFC62828);
  static const Color offline = Color(0xFF7B8580);

  /// Versões escuras, para texto sobre fundos claros tingidos.
  static const Color normalText = Color(0xFF1E6B40);
  static const Color attentionText = Color(0xFF7A5000);
  static const Color criticalText = Color(0xFFA31F1F);
  static const Color offlineText = Color(0xFF4E5852);
}

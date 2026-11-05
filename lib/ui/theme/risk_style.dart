import 'package:flutter/material.dart';
import 'package:vitalis/core/constants/risk_thresholds.dart';
import 'package:vitalis/data/models/risk.dart';
import 'package:vitalis/data/models/risk_alert.dart';
import 'package:vitalis/ui/theme/app_colors.dart';

/// Cores e ícones de cada situação de risco.
class RiskStyle {
  const RiskStyle({
    required this.color,
    required this.onColor,
    required this.textColor,
    required this.icon,
  });

  static const RiskStyle normal = RiskStyle(
    color: AppColors.riskNormal,
    onColor: Colors.white,
    textColor: AppColors.normalText,
    icon: Icons.check_circle_outline,
  );

  static const RiskStyle attention = RiskStyle(
    color: AppColors.riskAttention,
    onColor: AppColors.ink,
    textColor: AppColors.attentionText,
    icon: Icons.warning_amber_rounded,
  );

  static const RiskStyle critical = RiskStyle(
    color: AppColors.riskCritical,
    onColor: Colors.white,
    textColor: AppColors.criticalText,
    icon: Icons.local_fire_department_outlined,
  );

  static const RiskStyle offline = RiskStyle(
    color: AppColors.offline,
    onColor: Colors.white,
    textColor: AppColors.offlineText,
    icon: Icons.sensors_off,
  );

  static const RiskStyle lowBattery = RiskStyle(
    color: AppColors.riskAttention,
    onColor: AppColors.ink,
    textColor: AppColors.attentionText,
    icon: Icons.battery_alert,
  );

  /// Cor de fundo do bloco.
  final Color color;

  /// Cor do texto sobre [color].
  final Color onColor;

  /// Cor do texto sobre fundos claros tingidos com [color].
  final Color textColor;

  final IconData icon;

  static RiskStyle of(RiskLevel level) => switch (level) {
        RiskLevel.normal => normal,
        RiskLevel.attention => attention,
        RiskLevel.critical => critical,
      };

  static RiskStyle forAlert(AlertType type) => switch (type) {
        AlertType.attention => attention,
        AlertType.critical => critical,
        AlertType.lowBattery => lowBattery,
        AlertType.sensorOffline => offline,
      };

  static IconData batteryIcon(int level) {
    if (level <= 0) return Icons.battery_0_bar;
    if (level <= RiskThresholds.lowBattery) return Icons.battery_alert;
    if (level < 40) return Icons.battery_2_bar;
    if (level < 70) return Icons.battery_4_bar;
    if (level < 95) return Icons.battery_6_bar;
    return Icons.battery_full;
  }
}

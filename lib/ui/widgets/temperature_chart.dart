import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vitalis/core/constants/app_config.dart';
import 'package:vitalis/core/constants/risk_thresholds.dart';
import 'package:vitalis/core/utils/formatters.dart';
import 'package:vitalis/data/models/sensor_reading.dart';
import 'package:vitalis/ui/theme/app_colors.dart';
import 'package:vitalis/ui/widgets/state_views.dart';

/// Gráfico das últimas leituras (FL Chart) com as linhas dos limites de risco.
class TemperatureChart extends StatelessWidget {
  const TemperatureChart({super.key, required this.readings, this.height = 200});

  final List<SensorReading> readings;
  final double height;

  @override
  Widget build(BuildContext context) {
    final window = readings.length > AppConfig.chartWindow
        ? readings.sublist(readings.length - AppConfig.chartWindow)
        : readings;

    if (window.length < 2) {
      return SizedBox(
        height: height,
        child: const EmptyView(
          icon: Icons.show_chart,
          title: 'Gráfico em preparo',
          message: 'As primeiras leituras aparecem aqui em alguns segundos.',
          compact: true,
        ),
      );
    }

    final temperatures = window.map((reading) => reading.skinTemperature);
    final minY =
        math.min(32.0, temperatures.reduce(math.min) - 0.5).floorToDouble();
    final maxY =
        math.max(38.0, temperatures.reduce(math.max) + 0.5).ceilToDouble();

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (AppConfig.chartWindow - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: AppColors.line, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            bottomTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: 1,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}°',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: RiskThresholds.attentionTemperature,
                color: AppColors.riskAttention,
                strokeWidth: 1.5,
                dashArray: const [6, 4],
              ),
              HorizontalLine(
                y: RiskThresholds.criticalTemperature,
                color: AppColors.riskCritical,
                strokeWidth: 1.5,
                dashArray: const [6, 4],
              ),
            ],
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.ink,
              getTooltipItems: (spots) => [
                for (final spot in spots)
                  LineTooltipItem(
                    Formatters.temperature(spot.y),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < window.length; i++)
                  FlSpot(i.toDouble(), window[i].skinTemperature),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: AppColors.field,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.field.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Legenda das linhas tracejadas do gráfico.
class ThresholdLegend extends StatelessWidget {
  const ThresholdLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        _LegendItem(
          color: AppColors.riskAttention,
          label:
              'Atenção a partir de ${Formatters.temperature(RiskThresholds.attentionTemperature)}',
        ),
        _LegendItem(
          color: AppColors.riskCritical,
          label:
              'Risco alto a partir de ${Formatters.temperature(RiskThresholds.criticalTemperature)}',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 3, color: color),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

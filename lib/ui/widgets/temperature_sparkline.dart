import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vitalis/data/models/sensor_reading.dart';

/// Mini gráfico das últimas leituras, sem eixos, para os cartões da equipe.
class TemperatureSparkline extends StatelessWidget {
  const TemperatureSparkline({
    super.key,
    required this.readings,
    required this.color,
    this.height = 40,
    this.points = 20,
  });

  final List<SensorReading> readings;
  final Color color;
  final double height;

  /// Quantidade de leituras mais recentes desenhadas.
  final int points;

  @override
  Widget build(BuildContext context) {
    final window = readings.length > points
        ? readings.sublist(readings.length - points)
        : readings;

    if (window.length < 2) return SizedBox(height: height);

    final values = window.map((reading) => reading.skinTemperature);
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    // Margem mínima para a linha não ficar achatada quando a temperatura é estável.
    final padding = math.max(0.15, (maxValue - minValue) * 0.15);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (window.length - 1).toDouble(),
          minY: minValue - padding,
          maxY: maxValue + padding,
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < window.length; i++)
                  FlSpot(i.toDouble(), window[i].skinTemperature),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: color,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

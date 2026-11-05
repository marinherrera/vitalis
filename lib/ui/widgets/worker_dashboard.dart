import 'package:flutter/material.dart';
import 'package:vitalis/logic/monitoring/worker_monitor.dart';
import 'package:vitalis/ui/widgets/risk_hero.dart';
import 'package:vitalis/ui/widgets/section_title.dart';
import 'package:vitalis/ui/widgets/surface_card.dart';
import 'package:vitalis/ui/widgets/temperature_chart.dart';
import 'package:vitalis/ui/widgets/vitals_panel.dart';

/// Painel completo de um trabalhador. Usado pelo próprio trabalhador e pelo
/// supervisor na tela de detalhe.
class WorkerDashboard extends StatelessWidget {
  const WorkerDashboard({
    super.key,
    required this.monitor,
    this.header,
    this.action,
    this.bottom,
  });

  final WorkerMonitor monitor;

  /// Conteúdo acima do bloco principal (ex.: aviso de sensor sem sinal).
  final Widget? header;

  /// Ação logo abaixo dos indicadores (ex.: registrar hidratação).
  final Widget? action;

  /// Conteúdo no fim da tela (ex.: alertas do trabalhador).
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final header = this.header;
    final action = this.action;
    final bottom = this.bottom;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        if (header != null) ...[header, const SizedBox(height: 12)],
        RiskHero(
          assessment: monitor.assessment,
          temperature: monitor.latest?.skinTemperature,
        ),
        const SizedBox(height: 12),
        VitalsPanel(
          batteryLevel: monitor.batteryLevel,
          monitoredFor: now.difference(monitor.startedAt),
          lastHydration: monitor.lastHydration,
          now: now,
        ),
        if (action != null) ...[const SizedBox(height: 12), action],
        const SizedBox(height: 24),
        const SectionTitle(
          title: 'Últimas leituras',
          subtitle: 'Cada ponto é uma medição do sensor, a cada 2 segundos.',
        ),
        SurfaceCard(
          padding: const EdgeInsets.fromLTRB(8, 18, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TemperatureChart(readings: monitor.readings),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: ThresholdLegend(),
              ),
            ],
          ),
        ),
        if (bottom != null) ...[const SizedBox(height: 24), bottom],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitalis/core/utils/formatters.dart';
import 'package:vitalis/logic/monitoring/worker_monitor.dart';
import 'package:vitalis/logic/providers/monitoring_provider.dart';
import 'package:vitalis/logic/team_filter.dart';
import 'package:vitalis/ui/screens/supervisor/worker_detail_screen.dart';
import 'package:vitalis/ui/theme/app_colors.dart';
import 'package:vitalis/ui/widgets/app_text_field.dart';
import 'package:vitalis/ui/widgets/state_views.dart';
import 'package:vitalis/ui/widgets/surface_card.dart';
import 'package:vitalis/ui/widgets/vitalis_logo.dart';
import 'package:vitalis/ui/widgets/worker_card.dart';
import 'package:vitalis/ui/widgets/worker_side_panel.dart';

/// Visão da equipe em campo: resumo, filtros e um cartão colorido por
/// trabalhador, com quem precisa de atenção no topo. Em telas largas, tocar
/// em um cartão abre o painel lateral com o status e as ações recomendadas.
class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  /// Largura mínima da tela para mostrar o painel lateral.
  static const double _sidePanelBreakpoint = 900;
  static const double _sidePanelWidth = 360;
  static const double _minCardWidth = 300;
  static const double _gap = 12;

  final _searchController = TextEditingController();
  String _query = '';
  TeamFilter _filter = TeamFilter.all;
  String? _selectedId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(WorkerMonitor monitor) {
    if (!_filter.matches(monitor)) return false;
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    return monitor.worker.name.toLowerCase().contains(query) ||
        monitor.worker.activity.toLowerCase().contains(query);
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _filter = TeamFilter.all;
    });
  }

  void _openDetails(WorkerMonitor monitor) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WorkerDetailScreen(workerId: monitor.worker.id),
      ),
    );
  }

  /// Telas largas abrem o painel lateral; telas estreitas abrem o detalhe.
  void _onWorkerTap(WorkerMonitor monitor, {required bool wide}) {
    if (!wide) {
      _openDetails(monitor);
      return;
    }
    setState(() {
      _selectedId = _selectedId == monitor.worker.id ? null : monitor.worker.id;
    });
  }

  void _onAction(WorkerMonitor monitor, WorkerAction action) {
    final name = monitor.worker.firstName;
    final message = switch (action) {
      WorkerAction.callRescue => 'Pedido de socorro enviado para $name.',
      WorkerAction.removeFromField => '$name marcado(a) para sair do campo.',
      WorkerAction.logIncident => 'Ocorrência de $name registrada.',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$message (simulação)')));
  }

  @override
  Widget build(BuildContext context) {
    final monitoring = context.watch<MonitoringProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            VitalisLogo(size: 32, showName: false),
            SizedBox(width: 10),
            Text('Equipe em campo'),
          ],
        ),
        actions: [
          if (monitoring.status == MonitoringStatus.active)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: _LiveIndicator(),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (monitoring.status == MonitoringStatus.failure) {
            return ErrorView(
              title: 'Equipe indisponível',
              message: monitoring.errorMessage ?? 'Tente novamente.',
              onAction: monitoring.retry,
            );
          }
          if (monitoring.status != MonitoringStatus.active) {
            return const LoadingView(
              message: 'Conectando aos sensores da equipe...',
            );
          }
          final team = monitoring.monitors;
          if (team.isEmpty) {
            return const EmptyView(
              icon: Icons.groups_outlined,
              title: 'Nenhum trabalhador na equipe',
              message:
                  'Quando os trabalhadores criarem uma conta no app, eles aparecem aqui.',
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= _sidePanelBreakpoint;
              final selectedId = _selectedId;
              final selected = wide && selectedId != null
                  ? monitoring.monitorFor(selectedId)
                  : null;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildTeam(team, wide: wide, selected: selected)),
                  if (selected != null) ...[
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: _sidePanelWidth,
                      child: WorkerSidePanel(
                        monitor: selected,
                        onClose: () => setState(() => _selectedId = null),
                        onOpenDetails: () => _openDetails(selected),
                        onAction: (action) => _onAction(selected, action),
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTeam(
    List<WorkerMonitor> team, {
    required bool wide,
    required WorkerMonitor? selected,
  }) {
    final visible = team.where(_matches).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _TeamStats(team: team),
        const SizedBox(height: 16),
        AppTextField(
          controller: _searchController,
          label: 'Buscar por nome ou atividade',
          icon: Icons.search,
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final filter in TeamFilter.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      '${filter.label} (${team.where(filter.matches).length})',
                    ),
                    selected: _filter == filter,
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (visible.isEmpty)
          EmptyView(
            icon: Icons.search_off,
            title: 'Ninguém encontrado',
            message: 'Tente outro nome ou mostre todos os trabalhadores.',
            actionLabel: 'Limpar busca e filtro',
            onAction: _clearFilters,
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  ((constraints.maxWidth + _gap) / (_minCardWidth + _gap))
                      .floor()
                      .clamp(1, 4)
                      .toInt();
              final cardWidth =
                  (constraints.maxWidth - _gap * (columns - 1)) / columns;

              return Wrap(
                spacing: _gap,
                runSpacing: _gap,
                children: [
                  for (final monitor in visible)
                    SizedBox(
                      width: cardWidth,
                      child: WorkerCard(
                        monitor: monitor,
                        selected: selected?.worker.id == monitor.worker.id,
                        onTap: () => _onWorkerTap(monitor, wide: wide),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

/// Indicador de que as leituras estão chegando em tempo real.
class _LiveIndicator extends StatelessWidget {
  const _LiveIndicator();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 9, color: AppColors.riskNormal),
        SizedBox(width: 6),
        Text(
          'AO VIVO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

/// Resumo da equipe: trabalhadores ativos, alertas críticos, temperatura
/// média e quem está sem sinal.
class _TeamStats extends StatelessWidget {
  const _TeamStats({required this.team});

  final List<WorkerMonitor> team;

  @override
  Widget build(BuildContext context) {
    final active = team.where((monitor) => monitor.isOnline).length;
    final critical = team.where(TeamFilter.critical.matches).length;
    final offline = team.where(TeamFilter.offline.matches).length;

    final temperatures = [
      for (final monitor in team)
        if (monitor.isOnline && monitor.latest != null)
          monitor.latest!.skinTemperature,
    ];
    final average = temperatures.isEmpty
        ? '--'
        : Formatters.temperature(
            temperatures.reduce((a, b) => a + b) / temperatures.length,
          );

    final tiles = [
      _StatTile(label: 'TRABALHADORES ATIVOS', value: '$active'),
      _StatTile(
        label: 'ALERTAS CRÍTICOS',
        value: '$critical',
        valueColor: critical > 0 ? AppColors.riskCritical : null,
      ),
      _StatTile(label: 'TEMP. MÉDIA CAMPO', value: average),
      _StatTile(
        label: 'SEM SINAL',
        value: '$offline',
        valueColor: offline > 0 ? AppColors.offlineText : null,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final columns = constraints.maxWidth >= 640 ? 4 : 2;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tile in tiles) SizedBox(width: width, child: tile),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 28,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: valueColor ?? AppColors.ink,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

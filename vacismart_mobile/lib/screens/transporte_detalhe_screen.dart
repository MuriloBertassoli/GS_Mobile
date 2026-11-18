import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/operacao_dtos.dart';
import '../services/vacismart_api_service.dart';
import '../widgets/vacismart_widgets.dart';
import 'telemetria_screen.dart';

class TransporteDetalheScreen extends StatefulWidget {
  // Parâmetro recebido da tela anterior (Requisito 1: passagem de parâmetros)
  final TransporteSaidaDto transporte;

  const TransporteDetalheScreen({super.key, required this.transporte});

  @override
  State<TransporteDetalheScreen> createState() => _TransporteDetalheScreenState();
}

class _TransporteDetalheScreenState extends State<TransporteDetalheScreen> {
  final _apiService = VaciSmartApiService();
  late TransporteSaidaDto _transporteAtual;
  List<LoteSaidaDto> _lotes = [];
  List<EventoSaidaDto> _historico = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _transporteAtual = widget.transporte;
    _carregarDetalhes();
  }

  Future<void> _carregarDetalhes() async {
    setState(() => _carregando = true);
    try {
      final transpAtualizado = await _apiService.buscarTransportePorId(_transporteAtual.id);
      final pagLotes = await _apiService.listarLotesPorTransporte(_transporteAtual.id);
      final pagHist = await _apiService.listarHistoricoTransporte(_transporteAtual.id);

      if (!mounted) return;
      setState(() {
        _transporteAtual = transpAtualizado;
        _lotes = pagLotes.conteudo;
        _historico = pagHist.conteudo;
      });
    } catch (e) {
      if (!mounted) return;
      await mostrarDialogErro(context, e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _iniciarMonitoramento() async {
    try {
      // Retorna 204 sem corpo; em seguida recarregamos o transporte para obter inicioMonitoramentoEm
      await _apiService.iniciarMonitoramento(_transporteAtual.id);
      if (!mounted) return;
      mostrarSnackBarSucesso(context, 'Monitoramento iniciado! Transporte EM_TRANSPORTE.');
      await _carregarDetalhes();
    } catch (e) {
      if (!mounted) return;
      await mostrarDialogErro(context, e);
    }
  }

  Color _corLote(EstadoLote estado) {
    if (estado == EstadoLote.BLOQUEADO_PREVENTIVAMENTE) return VaciSmartColors.perigo;
    if (estado == EstadoLote.EM_MONITORAMENTO) return VaciSmartColors.primaria;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final podeIniciar =
        _transporteAtual.estado == EstadoTransporte.CADASTRADO && _lotes.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Transporte ${_transporteAtual.codigo}'),
        backgroundColor: VaciSmartColors.primaria,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _carregarDetalhes, icon: const Icon(Icons.refresh)),
        ],
      ),
      backgroundColor: VaciSmartColors.fundo,
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _transporteAtual.codigo,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            StatusChipBadge(
                              texto: _transporteAtual.estado.name,
                              cor: VaciSmartColors.primaria,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('ID: ${_transporteAtual.id}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          _transporteAtual.inicioMonitoramentoEm != null
                              ? 'Início do monitoramento: ${_transporteAtual.inicioMonitoramentoEm!.toLocal()}'
                              : 'Monitoramento ainda não iniciado',
                        ),
                        const SizedBox(height: 16),
                        if (podeIniciar)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: VaciSmartColors.sucesso,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _iniciarMonitoramento,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Iniciar Monitoramento Térmico'),
                            ),
                          ),
                        if (_transporteAtual.estado == EstadoTransporte.EM_TRANSPORTE)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: VaciSmartColors.secundaria,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                // Passagem de parâmetro do transporte para a tela de Telemetria
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => TelemetriaScreen(transporte: _transporteAtual),
                                  ),
                                );
                                _carregarDetalhes();
                              },
                              icon: const Icon(Icons.sensors),
                              label: const Text('Abrir Telemetria e Ocorrências'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Lotes Vinculados',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_lotes.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Nenhum lote vinculado a este transporte.'),
                    ),
                  ),
                ..._lotes.map(
                  (lote) => Card(
                    child: ListTile(
                      title: Text(lote.codigo, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Disponibilidade: ${lote.disponibilidade.name}'),
                      trailing: StatusChipBadge(
                        texto: lote.estado.name,
                        cor: _corLote(lote.estado),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Histórico de Auditoria do Transporte',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._historico.map(
                  (ev) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(ev.acao),
                      subtitle: Text(
                        'Autor: ${ev.autor} • ${ev.dataHora.toLocal()}\n${ev.justificativa ?? ''}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
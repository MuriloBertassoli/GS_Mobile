import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/operacao_dtos.dart';
import '../services/vacismart_api_service.dart';
import '../widgets/vacismart_widgets.dart';

class TelemetriaScreen extends StatefulWidget {
  final TransporteSaidaDto transporte;

  const TelemetriaScreen({super.key, required this.transporte});

  @override
  State<TelemetriaScreen> createState() => _TelemetriaScreenState();
}

class _TelemetriaScreenState extends State<TelemetriaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dispositivoController = TextEditingController(text: 'ARDUINO-SENSOR-01');
  final _temperaturaController = TextEditingController();
  final _apiService = VaciSmartApiService();

  List<LeituraSaidaDto> _leituras = [];
  List<OcorrenciaSaidaDto> _ocorrencias = [];
  bool _carregando = true;
  bool _enviandoLeitura = false;

  @override
  void initState() {
    super.initState();
    _carregarTelemetria();
  }

  @override
  void dispose() {
    _dispositivoController.dispose();
    _temperaturaController.dispose();
    super.dispose();
  }

  Future<void> _carregarTelemetria() async {
    setState(() => _carregando = true);
    try {
      final pagLeituras = await _apiService.listarLeituras(widget.transporte.id);
      final pagOcorrencias = await _apiService.listarOcorrencias(widget.transporte.id);
      if (!mounted) return;
      setState(() {
        _leituras = pagLeituras.conteudo;
        _ocorrencias = pagOcorrencias.conteudo;
      });
    } catch (e) {
      if (!mounted) return;
      await mostrarDialogErro(context, e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _enviarLeituraSimulada() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviandoLeitura = true);
    try {
      // Envia a leitura com o instante atual (não futuro e posterior ao inicioMonitoramentoEm)
      final leituraCriada = await _apiService.registrarLeitura(
        transporteId: widget.transporte.id,
        dispositivoId: _dispositivoController.text.trim(),
        temperaturaC: num.parse(_temperaturaController.text.trim()),
        medidaEm: DateTime.now(),
      );

      if (!mounted) return;
      _temperaturaController.clear();

      if (leituraCriada.classificacao == ClassificacaoTemperatura.FORA_DA_FAIXA) {
        // Alerta crítico via showDialog quando a leitura provoca bloqueio preventivo no backend
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: VaciSmartColors.perigo),
                SizedBox(width: 8),
                Expanded(child: Text('Desvio Térmico Detectado!')),
              ],
            ),
            content: Text(
              'Leitura de ${leituraCriada.temperaturaC}°C classificada como FORA_DA_FAIXA.\n'
              'O backend abriu uma ocorrência e aplicou BLOQUEIO PREVENTIVO aos lotes afetados.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ciente')),
            ],
          ),
        );
      } else {
        mostrarSnackBarSucesso(
          context,
          'Leitura registrada: ${leituraCriada.temperaturaC}°C (${leituraCriada.classificacao.name})',
        );
      }

      await _carregarTelemetria();
    } catch (e) {
      if (!mounted) return;
      await mostrarDialogErro(context, e);
    } finally {
      if (mounted) setState(() => _enviandoLeitura = false);
    }
  }

  Color _corClassificacao(ClassificacaoTemperatura c) {
    switch (c) {
      case ClassificacaoTemperatura.NORMAL:
        return VaciSmartColors.sucesso;
      case ClassificacaoTemperatura.ATENCAO:
        return VaciSmartColors.alerta;
      case ClassificacaoTemperatura.FORA_DA_FAIXA:
        return VaciSmartColors.perigo;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Telemetria — ${widget.transporte.codigo}'),
        backgroundColor: VaciSmartColors.primaria,
        foregroundColor: Colors.white,
      ),
      backgroundColor: VaciSmartColors.fundo,
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Formulário funcional de ingestão simulada de temperatura (Requisito 4)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Simular Leitura do Sensor (POST /leituras)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dispositivoController,
                            decoration: const InputDecoration(
                              labelText: 'ID do Dispositivo (ex: ARDUINO-SENSOR-01)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Informe o dispositivo';
                              if (v.trim().length > 100) return 'Máximo de 100 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _temperaturaController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Temperatura (°C) — ex: 5.2 ou 9.3',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe a temperatura';
                              }
                              final numero = num.tryParse(v.trim());
                              if (numero == null) {
                                return 'Informe um número decimal válido (use ponto)';
                              }
                              // Valida numeric(10,3) sem arredondar silenciosamente
                              final partes = v.trim().split('.');
                              if (partes.length == 2 && partes[1].length > 3) {
                                return 'Máximo de 3 casas decimais (contrato J4)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: VaciSmartColors.primaria,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _enviandoLeitura ? null : _enviarLeituraSimulada,
                            icon: const Icon(Icons.send),
                            label: Text(_enviandoLeitura ? 'Enviando...' : 'Registrar Leitura'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ocorrências Térmicas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_ocorrencias.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Text('Nenhuma ocorrência registrada.'),
                    ),
                  ),
                ..._ocorrencias.map(
                  (oc) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.report_problem, color: VaciSmartColors.perigo),
                      title: Text(oc.tipo.name),
                      subtitle: Text('Aberta em: ${oc.abertaEm.toLocal()}'),
                      trailing: StatusChipBadge(
                        texto: oc.estado.name,
                        cor: oc.estado == EstadoOcorrencia.ABERTA
                            ? VaciSmartColors.perigo
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Histórico de Leituras',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_leituras.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Text('Nenhuma leitura enviada ainda.'),
                    ),
                  ),
                ..._leituras.map(
                  (l) => Card(
                    child: ListTile(
                      title: Text(
                        '${l.temperaturaC}°C — ${l.dispositivoId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Medida em: ${l.medidaEm.toLocal()}'),
                      trailing: StatusChipBadge(
                        texto: l.classificacao.name,
                        cor: _corClassificacao(l.classificacao),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
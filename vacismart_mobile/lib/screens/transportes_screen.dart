import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/operacao_dtos.dart';
import '../services/vacismart_api_service.dart';
import '../widgets/vacismart_widgets.dart';
import 'transporte_detalhe_screen.dart';

class TransportesScreen extends StatefulWidget {
  const TransportesScreen({super.key});

  @override
  State<TransportesScreen> createState() => _TransportesScreenState();
}

class _TransportesScreenState extends State<TransportesScreen> {
  final _apiService = VaciSmartApiService();
  List<TransporteSaidaDto> _transportes = [];
  EstadoTransporte? _filtroEstado;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _buscarTransportes();
  }

  Future<void> _buscarTransportes() async {
    setState(() => _carregando = true);
    try {
      final pagina = await _apiService.listarTransportes(estado: _filtroEstado);
      if (!mounted) return;
      setState(() => _transportes = pagina.conteudo);
    } catch (e) {
      if (!mounted) return;
      await mostrarDialogErro(context, e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Color _corEstado(EstadoTransporte estado) {
    switch (estado) {
      case EstadoTransporte.CADASTRADO:
        return VaciSmartColors.secundaria;
      case EstadoTransporte.EM_TRANSPORTE:
        return VaciSmartColors.sucesso;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transportes de Vacinas'),
        backgroundColor: VaciSmartColors.primaria,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _buscarTransportes, icon: const Icon(Icons.refresh)),
        ],
      ),
      backgroundColor: VaciSmartColors.fundo,
      body: Column(
        children: [
          // Barra de filtro por EstadoTransporte (Requisito 3: setState atualizando lista)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: _filtroEstado == null,
                    onSelected: (_) {
                      setState(() => _filtroEstado = null);
                      _buscarTransportes();
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('CADASTRADO'),
                    selected: _filtroEstado == EstadoTransporte.CADASTRADO,
                    onSelected: (_) {
                      setState(() => _filtroEstado = EstadoTransporte.CADASTRADO);
                      _buscarTransportes();
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('EM_TRANSPORTE'),
                    selected: _filtroEstado == EstadoTransporte.EM_TRANSPORTE,
                    onSelected: (_) {
                      setState(() => _filtroEstado = EstadoTransporte.EM_TRANSPORTE);
                      _buscarTransportes();
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _transportes.isEmpty
                    ? const Center(child: Text('Nenhum transporte encontrado neste filtro.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _transportes.length,
                        itemBuilder: (context, index) {
                          final item = _transportes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(
                                Icons.local_shipping,
                                color: VaciSmartColors.primaria,
                              ),
                              title: Text(
                                item.codigo,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                item.inicioMonitoramentoEm != null
                                    ? 'Iniciado em: ${item.inicioMonitoramentoEm!.toLocal()}'
                                    : 'Aguardando início do monitoramento',
                              ),
                              trailing: StatusChipBadge(
                                texto: item.estado.name,
                                cor: _corEstado(item.estado),
                              ),
                              onTap: () async {
                                // Passagem de parâmetro do TransporteSaidaDto para a próxima tela
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => TransporteDetalheScreen(transporte: item),
                                  ),
                                );
                                _buscarTransportes();
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
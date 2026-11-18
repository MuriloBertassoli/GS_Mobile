import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/operacao_dtos.dart';
import '../services/sessao_service.dart';
import '../services/vacismart_api_service.dart';
import '../widgets/vacismart_widgets.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final _apiService = VaciSmartApiService();
  List<UnidadeSaidaDto> _unidades = [];
  List<VacinaSaidaDto> _vacinas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    try {
      final pagUnidades = await _apiService.listarUnidades();
      final pagVacinas = await _apiService.listarVacinas();
      if (!mounted) return;
      setState(() {
        _unidades = pagUnidades.conteudo;
        _vacinas = pagVacinas.conteudo;
      });
    } catch (e) {
      if (!mounted) return;
      await mostrarDialogErro(context, e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // Formulário modal exclusivo para GESTOR criar uma vacina validando numeric(10,3)
  Future<void> _abrirFormularioVacina() async {
    final formKey = GlobalKey<FormState>();
    final nomeCtrl = TextEditingController();
    final minCtrl = TextEditingController(text: '2.0');
    final maxCtrl = TextEditingController(text: '8.0');
    final margemCtrl = TextEditingController(text: '1.0');

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Vacina (Gestor)'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeCtrl,
                  decoration: const InputDecoration(labelText: 'Nome da vacina'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                ),
                TextFormField(
                  controller: minCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: const InputDecoration(labelText: 'Temp. Mínima (°C)'),
                  validator: (v) => num.tryParse(v ?? '') == null ? 'Decimal inválido' : null,
                ),
                TextFormField(
                  controller: maxCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: const InputDecoration(labelText: 'Temp. Máxima (°C)'),
                  validator: (v) => num.tryParse(v ?? '') == null ? 'Decimal inválido' : null,
                ),
                TextFormField(
                  controller: margemCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Margem de Atenção (°C)'),
                  validator: (v) {
                    final min = num.tryParse(minCtrl.text);
                    final max = num.tryParse(maxCtrl.text);
                    final margem = num.tryParse(v ?? '');
                    if (margem == null || min == null || max == null) return 'Valor inválido';
                    if (min >= max) return 'Mínima deve ser menor que máxima';
                    if (margem < 0 || (2 * margem) > (max - min)) {
                      return 'Regra J4: 2 × margem <= max - min';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              try {
                await _apiService.criarVacina(
                  nome: nomeCtrl.text.trim(),
                  temperaturaMinC: num.parse(minCtrl.text.trim()),
                  temperaturaMaxC: num.parse(maxCtrl.text.trim()),
                  margemAtencaoC: num.parse(margemCtrl.text.trim()),
                );
                if (!mounted) return;
                mostrarSnackBarSucesso(context, 'Vacina cadastrada com sucesso!');
                _carregarDados();
              } catch (e) {
                if (!mounted) return;
                await mostrarDialogErro(context, e);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ehGestor = SessaoService.usuarioAtual?.perfil == Perfil.GESTOR;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unidades e Vacinas'),
        backgroundColor: VaciSmartColors.primaria,
        foregroundColor: Colors.white,
      ),
      backgroundColor: VaciSmartColors.fundo,
      floatingActionButton: ehGestor
          ? FloatingActionButton.extended(
              backgroundColor: VaciSmartColors.primaria,
              foregroundColor: Colors.white,
              onPressed: _abrirFormularioVacina,
              icon: const Icon(Icons.add),
              label: const Text('Nova Vacina'),
            )
          : null,
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Unidades de Saúde no Escopo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_unidades.isEmpty)
                  const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Nenhuma unidade encontrada.'))),
                ..._unidades.map(
                  (u) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_hospital, color: VaciSmartColors.primaria),
                      title: Text(u.nome),
                      subtitle: Text('ID: ${u.id}', style: const TextStyle(fontSize: 11)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Catálogo de Vacinas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_vacinas.isEmpty)
                  const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Nenhuma vacina cadastrada.'))),
                ..._vacinas.map(
                  (v) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.thermostat, color: VaciSmartColors.secundaria),
                      title: Text(v.nome),
                      subtitle: Text(
                        'Faixa ideal: ${v.temperaturaMinC}°C a ${v.temperaturaMaxC}°C (Margem: ±${v.margemAtencaoC}°C)',
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
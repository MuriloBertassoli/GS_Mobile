import 'package:flutter/material.dart';
import '../services/cidadao_mock_service.dart';
import '../widgets/vacismart_widgets.dart';

class CidadaoPortalScreen extends StatefulWidget {
  // Recebe parâmetro de navegação para abrir diretamente na aba desejada
  final int abaInicial;

  const CidadaoPortalScreen({super.key, this.abaInicial = 0});

  @override
  State<CidadaoPortalScreen> createState() => _CidadaoPortalScreenState();
}

class _CidadaoPortalScreenState extends State<CidadaoPortalScreen> {
  late int _abaSelecionada;
  String _filtroBairro = '';

  @override
  void initState() {
    super.initState();
    _abaSelecionada = widget.abaInicial;
  }

  @override
  Widget build(BuildContext context) {
    final disponibilidade = CidadaoMockService.obterDisponibilidadeSimulada()
        .where((item) =>
            item.unidadeNome.toLowerCase().contains(_filtroBairro.toLowerCase()) ||
            item.vacinaNome.toLowerCase().contains(_filtroBairro.toLowerCase()))
        .toList();

    final caderneta = CidadaoMockService.obterCadernetaSimulada();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal do Cidadão'),
        backgroundColor: VaciSmartColors.primaria,
        foregroundColor: Colors.white,
      ),
      backgroundColor: VaciSmartColors.fundo,
      body: Column(
        children: [
          // Banner obrigatório pelo Contrato J4 identificando explicitamente os dados simulados
          Container(
            width: double.infinity,
            color: Colors.amber.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: VaciSmartColors.alerta),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AMBIENTE DEMONSTRATIVO (MOCK): Consulta pública de disponibilidade e caderneta digital são funcionalidades previstas para etapas futuras da API.',
                    style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _abaSelecionada == 0 ? VaciSmartColors.primaria : Colors.grey.shade300,
                      foregroundColor: _abaSelecionada == 0 ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => setState(() => _abaSelecionada = 0),
                    child: const Text('Disponibilidade UBS'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _abaSelecionada == 1 ? VaciSmartColors.primaria : Colors.grey.shade300,
                      foregroundColor: _abaSelecionada == 1 ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => setState(() => _abaSelecionada = 1),
                    child: const Text('Minha Caderneta'),
                  ),
                ),
              ],
            ),
          ),
          if (_abaSelecionada == 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Filtrar por UBS ou vacina...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (valor) => setState(() => _filtroBairro = valor),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: disponibilidade.length,
                itemBuilder: (context, index) {
                  final item = disponibilidade[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.unidadeNome,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(item.vacinaNome),
                          const SizedBox(height: 8),
                          StatusChipBadge(
                            texto: item.seloQualidadeTermica,
                            cor: VaciSmartColors.sucesso,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lote: ${item.loteCodigo} • Doses disponíveis: ${item.dosesEstimadas}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: caderneta.length,
                itemBuilder: (context, index) {
                  final dose = caderneta[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.verified_user, color: VaciSmartColors.sucesso),
                      title: Text('${dose.vacinaNome} — ${dose.dose}'),
                      subtitle: Text(
                        'Data: ${dose.dataAplicacao}\nLocal: ${dose.unidadeAplicadora}\n${dose.loteValidado}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
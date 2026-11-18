import 'package:flutter/material.dart';
import '../models/auth_dtos.dart';
import '../models/enums.dart';
import '../services/sessao_service.dart';
import '../services/vacismart_api_service.dart';
import '../widgets/vacismart_widgets.dart';
import 'cidadao_portal_screen.dart';
import 'login_screen.dart';
import 'transportes_screen.dart';
import 'catalogo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = VaciSmartApiService();
  UsuarioSaidaDto? _usuario;
  bool _atualizandoPerfil = false;

  @override
  void initState() {
    super.initState();
    _usuario = SessaoService.usuarioAtual;
  }

  // Consulta GET /auth/me para validar o token ativo e atualizar os dados do usuário
  Future<void> _recarregarPerfil() async {
    setState(() => _atualizandoPerfil = true);
    try {
      final atualizado = await _apiService.buscarMeuPerfil();
      if (!mounted) return;
      setState(() => _usuario = atualizado);
      mostrarSnackBarSucesso(context, 'Dados da conta atualizados via /auth/me.');
    } catch (e) {
      if (!mounted) return;
      await mostrarDialogErro(context, e);
    } finally {
      if (mounted) setState(() => _atualizandoPerfil = false);
    }
  }

  void _sair() {
    SessaoService.encerrarSessao();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _usuario;
    if (usuario == null) {
      return const Scaffold(body: Center(child: Text('Sessão não encontrada.')));
    }

    final ehCidadao = usuario.perfil == Perfil.CIDADAO;

    return Scaffold(
      appBar: AppBar(
        title: const Text('VaciSmart — Painel'),
        backgroundColor: VaciSmartColors.primaria,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Sincronizar conta (/auth/me)',
            onPressed: _atualizandoPerfil ? null : _recarregarPerfil,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: _sair,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      backgroundColor: VaciSmartColors.fundo,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card com resumo da conta autenticada
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            usuario.nome,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        StatusChipBadge(
                          texto: usuario.perfil.name,
                          cor: ehCidadao ? VaciSmartColors.secundaria : VaciSmartColors.primaria,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(usuario.email, style: TextStyle(color: Colors.grey.shade700)),
                    if (usuario.unidadeSaudeId != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Unidade vinculada: ${usuario.unidadeSaudeId}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Módulos Disponíveis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Uso explícito de GridView conforme requisito visual da disciplina
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: ehCidadao
                    ? [
                        _MenuCardItem(
                          icone: Icons.vaccines,
                          titulo: 'Vacinas Disponíveis',
                          subtitulo: 'Consulta cidadã (Simulação)',
                          cor: VaciSmartColors.primaria,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CidadaoPortalScreen(abaInicial: 0),
                              ),
                            );
                          },
                        ),
                        _MenuCardItem(
                          icone: Icons.badge_outlined,
                          titulo: 'Minha Caderneta',
                          subtitulo: 'Histórico de doses (Simulação)',
                          cor: VaciSmartColors.secundaria,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CidadaoPortalScreen(abaInicial: 1),
                              ),
                            );
                          },
                        ),
                      ]
                    : [
                        _MenuCardItem(
                          icone: Icons.local_shipping_outlined,
                          titulo: 'Transportes',
                          subtitulo: 'Monitoramento e telemetria',
                          cor: VaciSmartColors.primaria,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const TransportesScreen()),
                            );
                          },
                        ),
                        _MenuCardItem(
                          icone: Icons.medical_services_outlined,
                          titulo: 'Unidades e Vacinas',
                          subtitulo: 'Catálogo e faixas térmicas',
                          cor: VaciSmartColors.secundaria,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CatalogoScreen()),
                            );
                          },
                        ),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCardItem extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final Color cor;
  final VoidCallback onTap;

  const _MenuCardItem({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 42, color: cor),
              const SizedBox(height: 12),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                subtitulo,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
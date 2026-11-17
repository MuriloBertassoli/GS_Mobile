import 'package:flutter/material.dart';
import '../services/vacismart_api_service.dart';
import '../widgets/vacismart_widgets.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _apiService = VaciSmartApiService();

  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Valida se a senha possui apenas caracteres ASCII imprimíveis (U+0020 a U+007E)
  bool _ehAsciiImprimivel(String texto) {
    for (final code in texto.runes) {
      if (code < 0x20 || code > 0x7E) return false;
    }
    return true;
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final usuarioCriado = await _apiService.cadastrarCidadao(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );

      if (!mounted) return;
      // POST /auth/cadastro retorna 201 sem token; o usuário deve fazer login em seguida
      mostrarSnackBarSucesso(
        context,
        'Conta criada para ${usuarioCriado.nome}! Faça login para continuar.',
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      await mostrarDialogErro(context, e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Cidadão'),
        backgroundColor: VaciSmartColors.primaria,
        foregroundColor: Colors.white,
      ),
      backgroundColor: VaciSmartColors.fundo,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Criar Conta Cidadão',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Acompanhe a disponibilidade e a integridade térmica das vacinas na sua região.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nome é obrigatório';
                      }
                      if (value.trim().length > 150) {
                        return 'Máximo de 150 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'E-mail é obrigatório';
                      }
                      if (!value.contains('@') || value.trim().length > 254) {
                        return 'Informe um e-mail válido (até 254 caracteres)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha (12 a 72 caracteres)',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 12 || value.length > 72) {
                        return 'A senha deve ter entre 12 e 72 caracteres';
                      }
                      if (!_ehAsciiImprimivel(value)) {
                        return 'Use apenas caracteres ASCII padrão sem acentos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VaciSmartColors.primaria,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _carregando ? null : _cadastrar,
                      child: _carregando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Concluir Cadastro', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
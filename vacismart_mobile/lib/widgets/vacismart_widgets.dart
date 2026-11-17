import 'package:flutter/material.dart';
import '../models/auth_dtos.dart';

// Paleta de cores consistente do VaciSmart (CitizenTech Saúde)
class VaciSmartColors {
  static const Color primaria = Color(0xFF0F766E); // Verde-petróleo clínico
  static const Color secundaria = Color(0xFF0369A1); // Azul-confiança
  static const Color fundo = Color(0xFFF4F7F6);
  static const Color alerta = Color(0xFFD97706);
  static const Color perigo = Color(0xFFDC2626);
  static const Color sucesso = Color(0xFF15803D);
}

// Cabeçalho visual com widget Image (requisito visual da disciplina)
class VaciSmartLogoHeader extends StatelessWidget {
  final String subtitulo;

  const VaciSmartLogoHeader({super.key, required this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: VaciSmartColors.primaria.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          // Uso explícito do widget Image com fallback elegante caso esteja sem internet
          child: ClipOval(
            child: Image.network(
              'https://cdn-icons-png.flaticon.com/512/2966/2966327.png',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.vaccines,
                  size: 64,
                  color: VaciSmartColors.primaria,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'VaciSmart',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: VaciSmartColors.primaria,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitulo,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

// Badge colorido para estados de transporte, lote e temperatura
class StatusChipBadge extends StatelessWidget {
  final String texto;
  final Color cor;

  const StatusChipBadge({super.key, required this.texto, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.5)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: cor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// Exibe feedback imediato via SnackBar (Requisito 4)
void mostrarSnackBarSucesso(BuildContext context, String mensagem) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(mensagem)),
        ],
      ),
      backgroundColor: VaciSmartColors.sucesso,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// Exibe AlertDialog detalhado para erros da API (ProblemDetail) ou alertas críticos (Requisito 4)
Future<void> mostrarDialogErro(BuildContext context, Object erro) async {
  String titulo = 'Atenção';
  String mensagem = erro.toString();

  if (erro is ApiException) {
    titulo = '${erro.title} (HTTP ${erro.status})';
    mensagem = erro.toString();
  }

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: VaciSmartColors.perigo),
          const SizedBox(width: 8),
          Expanded(child: Text(titulo, style: const TextStyle(fontSize: 18))),
        ],
      ),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Entendi'),
        ),
      ],
    ),
  );
}
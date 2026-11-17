import 'enums.dart';

class UsuarioSaidaDto {
  final String id; // UUID como String opaca
  final String nome;
  final String email;
  final Perfil perfil;
  final String? unidadeSaudeId; // Null para CIDADAO e GESTOR

  UsuarioSaidaDto({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
    this.unidadeSaudeId,
  });

  // Constrói o objeto Dart a partir do JSON retornado pelo backend
  factory UsuarioSaidaDto.fromJson(Map<String, dynamic> json) {
    return UsuarioSaidaDto(
      id: json['id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      perfil: parseEnum(Perfil.values, json['perfil'] as String?, Perfil.DESCONHECIDO),
      unidadeSaudeId: json['unidadeSaudeId'] as String?,
    );
  }
}

class LoginSaidaDto {
  final String token;
  final String tipo;
  final DateTime expiraEm;
  final UsuarioSaidaDto usuario;

  LoginSaidaDto({
    required this.token,
    required this.tipo,
    required this.expiraEm,
    required this.usuario,
  });

  factory LoginSaidaDto.fromJson(Map<String, dynamic> json) {
    return LoginSaidaDto(
      token: json['token'] as String,
      tipo: json['tipo'] as String? ?? 'Bearer',
      expiraEm: DateTime.parse(json['expiraEm'] as String), // Preserva o instante ISO-8601
      usuario: UsuarioSaidaDto.fromJson(json['usuario'] as Map<String, dynamic>),
    );
  }
}

// Representa o padrão RFC 7807 (application/problem+json) devolvido em erros 400/401/403/404/409
class ApiException implements Exception {
  final int status;
  final String title;
  final String detail;
  final List<String> errosCampos;

  ApiException({
    required this.status,
    required this.title,
    required this.detail,
    this.errosCampos = const [],
  });

  @override
  String toString() {
    if (errosCampos.isNotEmpty) {
      return '$detail\n• ${errosCampos.join('\n• ')}';
    }
    return detail;
  }
}
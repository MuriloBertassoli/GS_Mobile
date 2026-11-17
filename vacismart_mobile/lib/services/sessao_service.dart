import '../models/auth_dtos.dart';

// Mantém o estado da sessão autenticada em memória durante o uso do app
class SessaoService {
  static String? _token;
  static UsuarioSaidaDto? _usuarioAtual;

  static String? get token => _token;
  static UsuarioSaidaDto? get usuarioAtual => _usuarioAtual;
  static bool get estaAutenticado => _token != null && _usuarioAtual != null;

  static void iniciarSessao(LoginSaidaDto login) {
    _token = login.token;
    _usuarioAtual = login.usuario;
  }

  static void atualizarUsuario(UsuarioSaidaDto usuario) {
    _usuarioAtual = usuario;
  }

  // Logout local: remove o token da memória (não existe endpoint /auth/logout na J4)
  static void encerrarSessao() {
    _token = null;
    _usuarioAtual = null;
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/auth_dtos.dart';
import '../models/enums.dart';
import '../models/operacao_dtos.dart';
import 'sessao_service.dart';

class VaciSmartApiService {
  // Tratamento centralizado de respostas HTTP conforme Seção 9 do contrato J4
  dynamic _processarResposta(http.Response response) {
    final status = response.statusCode;

    // 204 No Content (ex: iniciar monitoramento ou delete) não possui corpo JSON
    if (status == 204) {
      return null;
    }

    // Decodifica UTF-8 para preservar acentuação em português
    final bodyText = utf8.decode(response.bodyBytes);
    dynamic jsonBody;
    if (bodyText.isNotEmpty) {
      try {
        jsonBody = jsonDecode(bodyText);
      } catch (_) {
        jsonBody = null;
      }
    }

    if (status >= 200 && status < 300) {
      return jsonBody;
    }

    // Tratamento de erros ProblemDetail (400, 401, 403, 404, 409, 500)
    String title = 'Erro HTTP $status';
    String detail = 'Falha na comunicação com o servidor.';
    List<String> errosCampos = [];

    if (jsonBody is Map<String, dynamic>) {
      title = jsonBody['title'] as String? ?? title;
      detail = jsonBody['detail'] as String? ?? detail;
      if (jsonBody['campos'] is List) {
        for (final item in jsonBody['campos']) {
          if (item is Map<String, dynamic>) {
            errosCampos.add('${item['campo']}: ${item['mensagem']}');
          }
        }
      }
    } else if (status == 401) {
      detail = 'Sessão expirada ou credenciais inválidas. Faça login novamente.';
    } else if (status == 403) {
      detail = 'Acesso negado para o seu perfil ou unidade de saúde.';
    }

    throw ApiException(
      status: status,
      title: title,
      detail: detail,
      errosCampos: errosCampos,
    );
  }

  // --- AUTENTICAÇÃO (/auth) ---

  Future<UsuarioSaidaDto> cadastrarCidadao({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/cadastro');
    final response = await http.post(
      uri,
      headers: ApiConfig.headers(),
      // Envia exclusivamente os 3 campos permitidos no CadastroEntradaDto
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
      }),
    );
    final data = _processarResposta(response) as Map<String, dynamic>;
    return UsuarioSaidaDto.fromJson(data);
  }

  Future<LoginSaidaDto> login({
    required String email,
    required String senha,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    final response = await http.post(
      uri,
      headers: ApiConfig.headers(),
      body: jsonEncode({
        'email': email,
        'senha': senha,
      }),
    );
    final data = _processarResposta(response) as Map<String, dynamic>;
    final loginDto = LoginSaidaDto.fromJson(data);
    SessaoService.iniciarSessao(loginDto);
    return loginDto;
  }

  Future<UsuarioSaidaDto> buscarMeuPerfil() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/me');
    final response = await http.get(
      uri,
      headers: ApiConfig.headers(token: SessaoService.token),
    );
    final data = _processarResposta(response) as Map<String, dynamic>;
    final usuario = UsuarioSaidaDto.fromJson(data);
    SessaoService.atualizarUsuario(usuario);
    return usuario;
  }

  // --- UNIDADES E VACINAS (/unidades, /vacinas) ---

  Future<PaginaDto<UnidadeSaidaDto>> listarUnidades({int page = 0, int size = 20}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/unidades?page=$page&size=$size&sort=nome,asc');
    final response = await http.get(
      uri,
      headers: ApiConfig.headers(token: SessaoService.token),
    );
    final data = _processarResposta(response) as Map<String, dynamic>;
    return PaginaDto.fromJson(data, UnidadeSaidaDto.fromJson);
  }

  Future<PaginaDto<VacinaSaidaDto>> listarVacinas({int page = 0, int size = 20}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/vacinas?page=$page&size=$size&sort=nome,asc');
    final response = await http.get(
      uri,
      headers: ApiConfig.headers(token: SessaoService.token),
    );
    final data = _processarResposta(response) as Map<String, dynamic>;
    return PaginaDto.fromJson(data, VacinaSaidaDto.fromJson);
  }

  Future<VacinaSaidaDto> criarVacina({
    required String nome,
    required num temperaturaMinC,
    required num temperaturaMaxC,
    required num margemAtencaoC,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/vacinas');
    final response = await http.post(
      uri,
      headers: ApiConfig.headers(token: SessaoService.token),
      body: jsonEncode({
        'nome': nome,
        'temperaturaMinC': temperaturaMinC,
        'temperaturaMaxC': temperaturaMaxC,
        'margemAtencaoC': margemAtencaoC,
      }),
    );
    final data = _processarResposta(response) as Map<String, dynamic>;
    return VacinaSaidaDto.fromJson(data);
  }

  // --- TRANSPORTES (/transportes) ---

  Future<PaginaDto<TransporteSaidaDto>> listarTransportes({
    EstadoTransporte? estado,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, String>{
      'page': '$page',
      'size': '$size',
      'sort': 'codigo,asc',
    };
    if (estado != null && estado != EstadoTransporte.DESCONHECIDO) {
      queryParams['estado'] = estado.name;
    }
    final uri = Uri.parse('${ApiConfig.baseUrl}/transportes').replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: ApiConfig.headers(token: SessaoService.token),
    );
    final data = _processarResposta(response) as Map<String, dynamic>;
    return PaginaDto.fromJson(data, TransporteSaidaDto.fromJson);
  }

  Future<TransporteSaidaDto> buscarTransportePorId(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/transportes/$id');
    final response = await http.get(
      uri,
      headers: ApiConfig.headers(token: SessaoService.token),
    );
    final data = _processarResposta(response) as Map<String, dynamic>;
    return TransporteSaidaDto.fromJson(data);
  }

  Future<void> iniciarMonitoramento(String transporteId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/transportes/$transporteId/monitoramento');
    // POST sem corpo que retorna 204 No Content em caso de sucesso
    final response = await http.post(
      uri,
      headers: ApiConfig.headers(token: SessaoService.token),
    );
    _processarResposta(response);
  }

  Future<PaginaDto<EventoSaidaDto>> listarHistoricoTransporte(String transporteId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/transportes/$transporteId/historico?page=0&size=50&sort=dataHora,desc',
    );
    final response = await http.get(
      uri,
      headers: ApiConfig.headers(token: SessaoService.token),
    );
    final data = _processarResposta(response) as Map<String, dynamic>;
    return PaginaDto.fromJson(data, EventoSaidaDto.fromJson);
  }

  // --- LOTES (/lotes) ---

  Future<PaginaDto<LoteSaidaDto>> listarLotesPorTransporte(String transporteId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/lotes?transporteId=$transporteId&page=0&size=50&sort=codigo,asc',
    );
    final response = await http.get(
      uri,
      headers: ApiConfig.headers(token: SessaoService.token),
    );
    final data = _processarResposta(response) as Map<String, dynamic>;
    return PaginaDto.fromJson(data, LoteSaidaDto.fromJson);
  }

  Future<PaginaDto<EventoSaidaDto>> listarHistoricoLote(String loteId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/lotes/$loteId/historico?page=0&size=50&sort=dataHora,desc',
    );
    final response = await http.get(
      uri,
      headers: ApiConfig.headers(token: SessaoService.token),
    );
    final data = _processarResposta(response) as Map<String, dynamic>;
    return PaginaDto.fromJson(data, EventoSaidaDto.fromJson);
  }

  // --- LEITURAS E OCORRÊNCIAS (/transportes/{id}/leituras e /ocorrencias) ---

  Future<LeituraSaidaDto> registrarLeitura({
    required String transporteId,
    required String dispositivoId,
    required num temperaturaC,
    required DateTime medidaEm,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/transportes/$transporteId/leituras');

    // Formata OffsetDateTime com offset explícito (ex: 2026-11-16T17:20:00-03:00)
    final local = medidaEm.toLocal();
    final offset = local.timeZoneOffset;
    final sinal = offset.isNegative ? '-' : '+';
    final horas = offset.inHours.abs().toString().padLeft(2, '0');
    final minutos = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final isoSemOffset = local.toIso8601String().split('.').first;
    final medidaEmFormatada = '$isoSemOffset$sinal$horas:$minutos';

    final response = await http.post(
      uri,
      headers: ApiConfig.headers(token: SessaoService.token),
      body: jsonEncode({
        'transporteId': transporteId, // Obrigatório ser igual ao {id} da rota
        'dispositivoId': dispositivoId,
        'temperaturaC': temperaturaC,
        'medidaEm': medidaEmFormatada,
      }),
    );
    final data = _processarResposta(response) as Map<String, dynamic>;
    return LeituraSaidaDto.fromJson(data);
  }

  Future<PaginaDto<LeituraSaidaDto>> listarLeituras(String transporteId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/transportes/$transporteId/leituras?page=0&size=50&sort=medidaEm,desc',
    );
    final response = await http.get(
      uri,
      headers: ApiConfig.headers(token: SessaoService.token),
    );
    final data = _processarResposta(response) as Map<String, dynamic>;
    return PaginaDto.fromJson(data, LeituraSaidaDto.fromJson);
  }

  Future<PaginaDto<OcorrenciaSaidaDto>> listarOcorrencias(String transporteId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/transportes/$transporteId/ocorrencias?page=0&size=50&sort=abertaEm,desc',
    );
    final response = await http.get(
      uri,
      headers: ApiConfig.headers(token: SessaoService.token),
    );
    final data = _processarResposta(response) as Map<String, dynamic>;
    return PaginaDto.fromJson(data, OcorrenciaSaidaDto.fromJson);
  }
}
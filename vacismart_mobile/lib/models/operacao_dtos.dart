import 'enums.dart';

// Wrapper genérico para todas as listagens paginadas da API (/api/v1)
class PaginaDto<T> {
  final List<T> conteudo;
  final int pagina;
  final int tamanho;
  final int totalElementos;
  final int totalPaginas;

  PaginaDto({
    required this.conteudo,
    required this.pagina,
    required this.tamanho,
    required this.totalElementos,
    required this.totalPaginas,
  });

  factory PaginaDto.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonItem,
  ) {
    final listaRaw = json['conteudo'] as List<dynamic>? ?? [];
    return PaginaDto<T>(
      conteudo: listaRaw.map((e) => fromJsonItem(e as Map<String, dynamic>)).toList(),
      pagina: json['pagina'] as int? ?? 0,
      tamanho: json['tamanho'] as int? ?? 20,
      totalElementos: (json['totalElementos'] as num?)?.toInt() ?? 0,
      totalPaginas: json['totalPaginas'] as int? ?? 0,
    );
  }
}

class UnidadeSaidaDto {
  final String id;
  final String nome;

  UnidadeSaidaDto({required this.id, required this.nome});

  factory UnidadeSaidaDto.fromJson(Map<String, dynamic> json) {
    return UnidadeSaidaDto(
      id: json['id'] as String,
      nome: json['nome'] as String,
    );
  }
}

class VacinaSaidaDto {
  final String id;
  final String nome;
  final num temperaturaMinC;
  final num temperaturaMaxC;
  final num margemAtencaoC;

  VacinaSaidaDto({
    required this.id,
    required this.nome,
    required this.temperaturaMinC,
    required this.temperaturaMaxC,
    required this.margemAtencaoC,
  });

  factory VacinaSaidaDto.fromJson(Map<String, dynamic> json) {
    return VacinaSaidaDto(
      id: json['id'] as String,
      nome: json['nome'] as String,
      temperaturaMinC: json['temperaturaMinC'] as num,
      temperaturaMaxC: json['temperaturaMaxC'] as num,
      margemAtencaoC: json['margemAtencaoC'] as num,
    );
  }
}

class TransporteSaidaDto {
  final String id;
  final String codigo;
  final String unidadeSaudeId;
  final EstadoTransporte estado;
  final DateTime? inicioMonitoramentoEm; // Null enquanto estiver CADASTRADO

  TransporteSaidaDto({
    required this.id,
    required this.codigo,
    required this.unidadeSaudeId,
    required this.estado,
    this.inicioMonitoramentoEm,
  });

  factory TransporteSaidaDto.fromJson(Map<String, dynamic> json) {
    return TransporteSaidaDto(
      id: json['id'] as String,
      codigo: json['codigo'] as String,
      unidadeSaudeId: json['unidadeSaudeId'] as String,
      estado: parseEnum(
        EstadoTransporte.values,
        json['estado'] as String?,
        EstadoTransporte.DESCONHECIDO,
      ),
      inicioMonitoramentoEm: json['inicioMonitoramentoEm'] != null
          ? DateTime.parse(json['inicioMonitoramentoEm'] as String)
          : null,
    );
  }
}

class LoteSaidaDto {
  final String id;
  final String codigo;
  final String vacinaId;
  final String transporteId;
  final EstadoLote estado;
  final DisponibilidadeLote disponibilidade;

  LoteSaidaDto({
    required this.id,
    required this.codigo,
    required this.vacinaId,
    required this.transporteId,
    required this.estado,
    required this.disponibilidade,
  });

  factory LoteSaidaDto.fromJson(Map<String, dynamic> json) {
    return LoteSaidaDto(
      id: json['id'] as String,
      codigo: json['codigo'] as String,
      vacinaId: json['vacinaId'] as String,
      transporteId: json['transporteId'] as String,
      estado: parseEnum(EstadoLote.values, json['estado'] as String?, EstadoLote.DESCONHECIDO),
      disponibilidade: parseEnum(
        DisponibilidadeLote.values,
        json['disponibilidade'] as String?,
        DisponibilidadeLote.DESCONHECIDO,
      ),
    );
  }
}

class LeituraSaidaDto {
  final String id;
  final String transporteId;
  final String dispositivoId;
  final num temperaturaC;
  final DateTime medidaEm;
  final DateTime recebidaEm;
  final ClassificacaoTemperatura classificacao;

  LeituraSaidaDto({
    required this.id,
    required this.transporteId,
    required this.dispositivoId,
    required this.temperaturaC,
    required this.medidaEm,
    required this.recebidaEm,
    required this.classificacao,
  });

  factory LeituraSaidaDto.fromJson(Map<String, dynamic> json) {
    return LeituraSaidaDto(
      id: json['id'] as String,
      transporteId: json['transporteId'] as String,
      dispositivoId: json['dispositivoId'] as String,
      temperaturaC: json['temperaturaC'] as num,
      medidaEm: DateTime.parse(json['medidaEm'] as String),
      recebidaEm: DateTime.parse(json['recebidaEm'] as String),
      classificacao: parseEnum(
        ClassificacaoTemperatura.values,
        json['classificacao'] as String?,
        ClassificacaoTemperatura.DESCONHECIDO,
      ),
    );
  }
}

class OcorrenciaSaidaDto {
  final String id;
  final String transporteId;
  final TipoOcorrencia tipo;
  final EstadoOcorrencia estado;
  final DateTime abertaEm;
  final DateTime? encerradaEm;

  OcorrenciaSaidaDto({
    required this.id,
    required this.transporteId,
    required this.tipo,
    required this.estado,
    required this.abertaEm,
    this.encerradaEm,
  });

  factory OcorrenciaSaidaDto.fromJson(Map<String, dynamic> json) {
    return OcorrenciaSaidaDto(
      id: json['id'] as String,
      transporteId: json['transporteId'] as String,
      tipo: parseEnum(TipoOcorrencia.values, json['tipo'] as String?, TipoOcorrencia.DESCONHECIDO),
      estado: parseEnum(
        EstadoOcorrencia.values,
        json['estado'] as String?,
        EstadoOcorrencia.DESCONHECIDO,
      ),
      abertaEm: DateTime.parse(json['abertaEm'] as String),
      encerradaEm:
          json['encerradaEm'] != null ? DateTime.parse(json['encerradaEm'] as String) : null,
    );
  }
}

class EventoSaidaDto {
  final String id;
  final String entidade;
  final String referenciaId;
  final String acao;
  final String autor;
  final DateTime dataHora;
  final String? justificativa;

  EventoSaidaDto({
    required this.id,
    required this.entidade,
    required this.referenciaId,
    required this.acao,
    required this.autor,
    required this.dataHora,
    this.justificativa,
  });

  factory EventoSaidaDto.fromJson(Map<String, dynamic> json) {
    return EventoSaidaDto(
      id: json['id'] as String,
      entidade: json['entidade'] as String,
      referenciaId: json['referenciaId'] as String,
      acao: json['acao'] as String,
      autor: json['autor'] as String,
      dataHora: DateTime.parse(json['dataHora'] as String),
      justificativa: json['justificativa'] as String?,
    );
  }
}
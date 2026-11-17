enum Perfil { CIDADAO, FUNCIONARIO, GESTOR, DESCONHECIDO }

enum EstadoTransporte { CADASTRADO, EM_TRANSPORTE, RECEBIDO, FINALIZADO, DESCONHECIDO }

enum EstadoLote {
  EM_MONITORAMENTO,
  AGUARDANDO_CONFERENCIA,
  BLOQUEADO_PREVENTIVAMENTE,
  LIBERADO,
  DESCARTADO,
  DESCONHECIDO
}

enum DisponibilidadeLote { NAO_DISPONIVEL, CONFIRMADA, DESCONHECIDO }

enum ClassificacaoTemperatura { NORMAL, ATENCAO, FORA_DA_FAIXA, DESCONHECIDO }

enum TipoOcorrencia { FORA_DA_FAIXA, PERDA_DE_TELEMETRIA, DESCONHECIDO }

enum EstadoOcorrencia { ABERTA, ENCERRADA, DESCONHECIDO }

// Converte string vinda do JSON da API para o Enum correspondente sem quebrar o app
T parseEnum<T extends Enum>(List<T> values, String? raw, T fallback) {
  if (raw == null) return fallback;
  for (final v in values) {
    if (v.name == raw) return v;
  }
  return fallback;
}
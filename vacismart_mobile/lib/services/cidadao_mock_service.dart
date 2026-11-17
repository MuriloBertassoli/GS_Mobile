// ATENÇÃO: Fonte de dados 100% MOCKADA para funcionalidades futuras do perfil CIDADAO
// (Disponibilidade pública de vacinas e Caderneta Digital ainda não existem na API J4).

class DisponibilidadeUnidadeMock {
  final String unidadeNome;
  final String bairro;
  final String vacinaNome;
  final String loteCodigo;
  final String seloQualidadeTermica;
  final int dosesEstimadas;

  DisponibilidadeUnidadeMock({
    required this.unidadeNome,
    required this.bairro,
    required this.vacinaNome,
    required this.loteCodigo,
    required this.seloQualidadeTermica,
    required this.dosesEstimadas,
  });
}

class RegistroCadernetaMock {
  final String vacinaNome;
  final String dose;
  final String dataAplicacao;
  final String unidadeAplicadora;
  final String loteValidado;

  RegistroCadernetaMock({
    required this.vacinaNome,
    required this.dose,
    required this.dataAplicacao,
    required this.unidadeAplicadora,
    required this.loteValidado,
  });
}

class CidadaoMockService {
  static List<DisponibilidadeUnidadeMock> obterDisponibilidadeSimulada() {
    return [
      DisponibilidadeUnidadeMock(
        unidadeNome: 'UBS Central — Santo André',
        bairro: 'Centro',
        vacinaNome: 'Influenza Tetravalente (2°C a 8°C)',
        loteCodigo: 'VAC-2026-091',
        seloQualidadeTermica: 'Cadeia de Frio Íntegra (100% dentro da faixa)',
        dosesEstimadas: 140,
      ),
      DisponibilidadeUnidadeMock(
        unidadeNome: 'UBS Vila Assunção',
        bairro: 'Vila Assunção',
        vacinaNome: 'Tríplice Viral SCR (2°C a 8°C)',
        loteCodigo: 'VAC-2026-104',
        seloQualidadeTermica: 'Cadeia de Frio Íntegra (100% dentro da faixa)',
        dosesEstimadas: 85,
      ),
      DisponibilidadeUnidadeMock(
        unidadeNome: 'UBS Parque das Nações',
        bairro: 'Parque das Nações',
        vacinaNome: 'COVID-19 Bivalente (2°C a 8°C)',
        loteCodigo: 'VAC-2026-118',
        seloQualidadeTermica: 'Cadeia de Frio Íntegra (100% dentro da faixa)',
        dosesEstimadas: 60,
      ),
    ];
  }

  static List<RegistroCadernetaMock> obterCadernetaSimulada() {
    return [
      RegistroCadernetaMock(
        vacinaNome: 'Influenza Tetravalente',
        dose: 'Dose Anual 2026',
        dataAplicacao: '14/05/2026',
        unidadeAplicadora: 'UBS Central — Santo André',
        loteValidado: 'VAC-2026-042 (Integridade Térmica Verificada)',
      ),
      RegistroCadernetaMock(
        vacinaNome: 'Antitetânica (dT)',
        dose: 'Reforço',
        dataAplicacao: '10/11/2025',
        unidadeAplicadora: 'UBS Vila Assunção',
        loteValidado: 'VAC-2025-889 (Integridade Térmica Verificada)',
      ),
    ];
  }
}
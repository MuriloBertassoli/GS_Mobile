# VaciSmart Mobile — Monitoramento Térmico e Transparência na Cadeia de Frio

Aplicativo mobile desenvolvido em **Flutter e Dart** como parte da **Global Solution 2026/2 (CitizenTech — FIAP)**. O sistema integra-se ao backend **VaciSmart API (Java / Spring Boot)** para garantir a integridade térmica de lotes de vacinas durante o transporte e promover transparência sanitária ao cidadão.

---

## 1. O Problema e a Finalidade do Projeto
A perda de imunizantes por falhas na cadeia de frio (variações de temperatura fora da faixa ideal de conservação, geralmente entre 2 °C e 8 °C) compromete campanhas de saúde pública, gera desperdício de recursos e reduz a confiança da população.

A finalidade do **VaciSmart** é conectar a telemetria de sensores térmicos (IoT/Arduino) durante o transporte de vacinas a uma plataforma de gestão e transparência:
* **Prevenção e Bloqueio Automático:** Ao registrar leituras de temperatura em tempo real via API, qualquer desvio térmico crítico gera automaticamente uma ocorrência e aplica o **bloqueio preventivo** nos lotes afetados, impedindo que doses comprometidas cheguem à sala de vacinação.
* **Rastreabilidade e Auditoria:** Cada mudança de estado do transporte ou lote é registrada com histórico auditável.

---

## 2. Cidadão Beneficiado e Perfis de Uso
O aplicativo atende tanto o beneficiário final quanto a operação sanitária, respeitando o isolamento de permissões por perfil autenticado via JWT:

* **Cidadão (Beneficiário Final):** População que utiliza as Unidades Básicas de Saúde (UBS). O cidadão pode criar sua conta, autenticar-se e consultar (em módulo demonstrativo) a disponibilidade de vacinas nas UBS próximas com selo de integridade térmica, além de visualizar sua caderneta digital.
* **Funcionário de Unidade de Saúde:** Opera dentro do escopo da sua UBS vinculada, acompanhando transportes, iniciando o monitoramento térmico, simulando leituras de sensores e verificando ocorrências abertas.
* **Gestor:** Possui visão global das unidades de saúde, catálogo de vacinas (com cadastro de faixas térmicas e margens de atenção) e transportes em andamento.

---

## 3. Conexão com os ODS da ONU (Agenda 2030)
* **ODS 3 — Saúde e Bem-Estar:** Assegura a eficácia e a qualidade dos imunizantes disponibilizados à população, reduzindo riscos clínicos e falhas na imunização.
* **ODS 9 — Indústria, Inovação e Infraestrutura:** Moderniza a logística sanitária por meio da integração entre sensores de telemetria, API RESTful e aplicativo mobile.
* **ODS 10 — Redução das Desigualdades:** Garante o mesmo rigor de rastreabilidade e segurança vacinal em unidades públicas de regiões periféricas ou com infraestrutura limitada.
* **ODS 11 — Cidades e Comunidades Sustentáveis:** Torna os serviços públicos de saúde mais resilientes, transparentes e eficientes na gestão de insumos essenciais.

---

## 4. Arquitetura e Funcionalidades Implementadas
O aplicativo foi estruturado seguindo boas práticas de organização em Dart/Flutter e gerenciamento de estado nativo (`StatefulWidget` e `setState`):

* `lib/config/`: Centralização da URL base da API (`/api/v1`) e montagem de cabeçalhos HTTP (`Authorization: Bearer <token>`).
* `lib/models/`: DTOs e Enums fiéis ao contrato REST da API (`UsuarioSaidaDto`, `LoginSaidaDto`, `TransporteSaidaDto`, `LoteSaidaDto`, `LeituraSaidaDto`, `OcorrenciaSaidaDto`, `EventoSaidaDto` e `PaginaDto<T>`).
* `lib/services/`:
  * `vacismart_api_service.dart`: Cliente HTTP para autenticação, consultas paginadas, início de monitoramento (`204 No Content`), envio de leituras e tratamento de erros RFC 7807 (`ProblemDetail`).
  * `sessao_service.dart`: Controle em memória do token JWT e do usuário logado.
  * `cidadao_mock_service.dart`: Fonte de dados simulada e explicitamente identificada para as telas futuras de disponibilidade pública e caderneta do cidadão.
* `lib/screens/`:
  * **Login e Cadastro (`login_screen.dart` / `cadastro_screen.dart`):** Formulários com `GlobalKey<FormState>` e validações de e-mail e senha ASCII (12 a 72 caracteres).
  * **Painel Principal (`home_screen.dart`):** Navegação em `GridView` adaptada ao perfil autenticado (`CIDADAO`, `FUNCIONARIO` ou `GESTOR`) e sincronização via `GET /auth/me`.
  * **Portal do Cidadão (`cidadao_portal_screen.dart`):** Consulta simulada de vacinas por UBS com filtro dinâmico e histórico da caderneta.
  * **Catálogo de Unidades e Vacinas (`catalogo_screen.dart`):** Listagem de unidades/vacinas e cadastro de novas vacinas para perfil `GESTOR`.
  * **Transportes (`transportes_screen.dart`):** Listagem com filtro dinâmico por estado (`CADASTRADO`, `EM_TRANSPORTE`) e passagem de parâmetros para detalhes.
  * **Detalhes do Transporte e Telemetria (`transporte_detalhe_screen.dart` / `telemetria_screen.dart`):** Início de monitoramento, visualização de lotes/histórico e envio de leituras térmicas com alerta imediato em caso de desvio (`FORA_DA_FAIXA`).

---

## 5. Como Executar o Projeto

### Pré-requisitos
* **Flutter SDK** (versão 3.x ou superior) e **Dart SDK**.
* **Android Studio / Emulador Android** ou dispositivo físico configurado (não executar em navegador Web).
* **Backend VaciSmart API** em execução na porta `8080` (`/api/v1`).

### Passo a Passo
1. Clone este repositório e acesse a pasta do aplicativo Flutter:
   ```bash
   git clone <URL_DO_REPOSITORIO>
   cd vacismart_mobile
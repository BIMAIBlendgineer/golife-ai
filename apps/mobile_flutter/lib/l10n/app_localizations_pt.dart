// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'GoLife AI';

  @override
  String get appShellTaglineReady =>
      'Shell do sistema de vida com limites de privacidade explicitos.';

  @override
  String get appShellTaglineBooting =>
      'Inicializando privacidade, missoes e grafo local...';

  @override
  String get navigate => 'Navegar';

  @override
  String get navDashboard => 'Inicio';

  @override
  String get navCapture => 'Capturar';

  @override
  String get navWeek => 'Semana';

  @override
  String get navTasks => 'Tarefas';

  @override
  String get navHabits => 'Habitos';

  @override
  String get navMoney => 'Dinheiro';

  @override
  String get navPantry => 'Despensa';

  @override
  String get navCloset => 'Armario';

  @override
  String get navEveryday => 'Cotidiano';

  @override
  String get navCopilot => 'Copilot';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Padrao do sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Espanol';

  @override
  String get languagePortugueseBrazil => 'Portugues Brasil';

  @override
  String get languageJapanese => 'Japones';

  @override
  String get languageChineseSimplified => 'Chines simplificado';

  @override
  String get privacyTitle => 'Privacidade';

  @override
  String get privacyIntro =>
      'Cada evento fica local, salvo quando a permissao do dominio e o nivel de privacidade permitem IA. Esta tela tambem oferece exportacao local e limpeza completa.';

  @override
  String get privacyEncryptedActive =>
      'A criptografia local sensivel esta ativa para Journal, Quick Notes e Finance neste dispositivo.';

  @override
  String get privacyEncryptedUnavailable =>
      'A criptografia local sensivel nao esta disponivel neste ambiente. Trate Journal, Quick Notes e Finance como nao protegidos em repouso ate o secure storage voltar.';

  @override
  String get privacyCenter => 'Centro de privacidade';

  @override
  String get privacyDisclosureEncryptedTitle => 'Criptografado localmente';

  @override
  String get privacyDisclosureEncryptedBody =>
      'Estas colecoes ficam protegidas em repouso neste dispositivo.';

  @override
  String get privacyDisclosureLocalTitle => 'Sempre local';

  @override
  String get privacyDisclosureLocalBody =>
      'Esses itens ficam no dispositivo e nao entram no roteamento de IA.';

  @override
  String get privacyDisclosureAiTitle =>
      'Pode ser enviado para IA se permitido';

  @override
  String get privacyDisclosureAiBody =>
      'So dominios com permissao de IA e eventos AI-allowed podem ser enviados.';

  @override
  String get privacyMetricTotalEvents => 'Eventos totais';

  @override
  String get privacyMetricAiEligible => 'Elegiveis para IA';

  @override
  String get privacyMetricBlockedLocal => 'Bloqueados localmente';

  @override
  String get dataControls => 'Controles de dados';

  @override
  String get dataControlsBody =>
      'Exportar copia o snapshot local completo em JSON. Apagar tudo limpa os dados locais e desativa a semeadura demo.';

  @override
  String get exportJson => 'Exportar JSON';

  @override
  String get deleteAllLocalData => 'Apagar todos os dados locais';

  @override
  String get domainControls => 'Controles por dominio';

  @override
  String get exportCopied =>
      'A exportacao JSON local foi copiada para a area de transferencia.';

  @override
  String get deleteAllTitle => 'Apagar todos os dados locais?';

  @override
  String get deleteAllBody =>
      'Isso remove eventos locais, entidades, missoes, feedback, ajustes de privacidade, cache runtime e preferencia de idioma neste dispositivo.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deleteAll => 'Apagar tudo';

  @override
  String get deleteAllDone => 'Todos os dados locais foram apagados.';

  @override
  String domainEventsEligible(int eventCount, int aiCount) {
    return '$eventCount eventos · $aiCount elegiveis para IA agora';
  }

  @override
  String get permissionLocal => 'Local';

  @override
  String get permissionSync => 'Sync';

  @override
  String get permissionAi => 'IA';

  @override
  String get domainHabits => 'Habitos';

  @override
  String get domainTasks => 'Tarefas';

  @override
  String get domainWeek => 'Semana';

  @override
  String get domainFinance => 'Dinheiro';

  @override
  String get domainPantry => 'Despensa';

  @override
  String get domainWardrobe => 'Armario';

  @override
  String get domainCopilot => 'Copilot';

  @override
  String get collectionFinanceRecords => 'Registros financeiros';

  @override
  String get collectionJournalEntries => 'Entradas de journal';

  @override
  String get collectionQuickNotes => 'Notas rapidas';

  @override
  String get collectionPrivacySettings => 'Ajustes de privacidade';

  @override
  String get collectionRuntimeConfigCache => 'Cache de runtime config';

  @override
  String get collectionDeviceEncryptionKey =>
      'Chave de criptografia do dispositivo';

  @override
  String get nothingAiEnabled => 'Nenhum dominio esta com IA ativa agora';

  @override
  String get gatewayLive => 'Gateway ativo';

  @override
  String get gatewayNoConnection => 'Sem conexao';

  @override
  String get gatewayUnavailable => 'IA temporariamente indisponivel';

  @override
  String get gatewayLocalFallback => 'Usando fallback local';

  @override
  String get feedbackNone => 'Sem feedback ainda';

  @override
  String get feedbackUseful => 'Util';

  @override
  String get feedbackRejected => 'Rejeitado';

  @override
  String get feedbackAccepted => 'Aceito';

  @override
  String get feedbackCompleted => 'Concluido';

  @override
  String get feedbackEdited => 'Editado';

  @override
  String get missionDeliveryAi => 'Com ajuda de IA';

  @override
  String get missionDeliveryFallback => 'Fallback local';

  @override
  String get missionDeliveryLocal => 'Local';

  @override
  String get missionDeliverySummaryAi =>
      'GoLife usou IA para esta missao depois do filtro local de privacidade.';

  @override
  String get missionDeliverySummaryFallback =>
      'GoLife ficou local porque o gateway estava indisponivel ou degradado.';

  @override
  String get missionDeliverySummaryLocal =>
      'GoLife manteve esta missao local no dispositivo.';

  @override
  String get actionWrite => 'Escrever';

  @override
  String get actionChat => 'Conversar';

  @override
  String get actionExplain => 'Explicar';

  @override
  String get actionUseful => 'Util';

  @override
  String get actionDoNow => 'Fazer agora';

  @override
  String get actionNotUseful => 'Nao util';

  @override
  String get actionAccept => 'Aceitar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionRemove => 'Remover';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionParseCapture => 'Parsear captura';

  @override
  String get actionReparseCapture => 'Parsear de novo';

  @override
  String actionSaveCaptureItems(int count) {
    return 'Salvar $count itens';
  }

  @override
  String get statusReady => 'Pronto';

  @override
  String get statusBooting => 'Inicializando';

  @override
  String get labelEvidence => 'Evidencia';

  @override
  String get labelDataUsedForMission => 'Dados usados para esta missao';

  @override
  String get labelDataSentToAi => 'Dados enviados para IA';

  @override
  String get labelBlockedFromAi => 'Bloqueado para IA';

  @override
  String get labelAlwaysLocalOnDevice => 'Sempre local neste dispositivo';

  @override
  String get labelEncryptedLocally => 'Criptografado localmente';

  @override
  String get labelUncertainty => 'Incerteza';

  @override
  String get labelTrace => 'Trace';

  @override
  String get fieldDomain => 'Dominio';

  @override
  String get fieldPrivacy => 'Privacidade';

  @override
  String get dashboardDisclosurePending =>
      'GoLife mantem os dados locais ate uma missao ficar pronta.';

  @override
  String dashboardMissionCountTitle(int count) {
    return '$count missoes para hoje';
  }

  @override
  String get dashboardMissionIntro =>
      'Home Today transforma o grafo em acoes pequenas: uma missao principal, duas de apoio, evidencia visivel e feedback rapido.';

  @override
  String get dashboardLoadingMissions => 'Carregando missoes...';

  @override
  String get dashboardBootstrappingMission =>
      'Inicializando eventos locais, ranking de missoes e trace do gateway.';

  @override
  String dashboardRiskCount(int count) {
    return '$count riscos';
  }

  @override
  String dashboardConfidencePill(int percent) {
    return '$percent% de confianca';
  }

  @override
  String get dashboardAiDisclosureTitle => 'Disclosure de dados para IA';

  @override
  String dashboardAiDisclosureSummary(
      Object summary, int sentCount, int blockedCount) {
    return '$summary Enviado agora: $sentCount eventos locais. Bloqueados localmente: $blockedCount.';
  }

  @override
  String get dashboardRisksTitle => 'Riscos de hoje';

  @override
  String get dashboardNoRisks =>
      'Nenhum risco diario explicito foi detectado no grafo atual elegivel para IA.';

  @override
  String get dashboardSupportMissionsTitle => 'Missoes de apoio';

  @override
  String get dashboardNoSupportMissions =>
      'Missoes secundarias aparecerao quando o plano diario estiver disponivel.';

  @override
  String get signalCriticalTask => 'Tarefa critica';

  @override
  String get signalRecoveryHabit => 'Habito de recuperacao';

  @override
  String signalRecoveryHabitBody(Object cue, Object streak) {
    return 'Gatilho: $cue - $streak';
  }

  @override
  String get signalRelevantSpend => 'Gasto relevante';

  @override
  String get signalUseThisFood => 'Use este alimento';

  @override
  String get dashboardWhyThisToday => 'Por que esta hoje';

  @override
  String dashboardConfidenceWithType(int percent, Object type) {
    return 'Confianca $percent% - $type';
  }

  @override
  String get dashboardNothingSent =>
      'Nada foi enviado para esta missao. GoLife ficou local neste passo.';

  @override
  String get dashboardNothingBlocked =>
      'Nenhum item especifico desta missao foi bloqueado para IA.';

  @override
  String get dashboardNoAlwaysLocalCollections =>
      'Nenhuma colecao sempre local configurada.';

  @override
  String get dashboardNoEncryptedCollections =>
      'Nenhuma colecao criptografada configurada.';

  @override
  String dashboardRiskSeverityLabel(Object severity) {
    return 'risco $severity';
  }

  @override
  String get captureTitle => 'Capturar';

  @override
  String get captureIntro =>
      'Escreva uma frase. GoLife pode dividir em varios rascunhos, deixar voce editar dominio e privacidade por item, e salvar tudo junto.';

  @override
  String get captureRouteTitle => 'Rota';

  @override
  String get captureAutoRoute => 'Auto';

  @override
  String get captureAutoModeBody =>
      'O modo auto tenta dividir e classificar cada clausula primeiro.';

  @override
  String captureCurrentDefaultPrivacy(Object domain, Object permission) {
    return 'Privacidade padrao atual para $domain: $permission';
  }

  @override
  String get captureDraftsToConfirm => 'Rascunhos para confirmar';

  @override
  String get captureRecentEvents => 'Eventos recentes';

  @override
  String capturePrivacyLabel(Object privacy) {
    return 'Privacidade: $privacy';
  }

  @override
  String captureItemsCaptured(int count) {
    return '$count item(s) capturados.';
  }

  @override
  String get captureEditItemTitle => 'Editar item';

  @override
  String get captureHintAuto =>
      'Exemplo: comprei cafe por 4.50, a alface vence amanha e preciso pagar internet.';

  @override
  String get captureHintTasks =>
      'Exemplo: enviar recibo do aluguel antes do almoco';

  @override
  String get captureHintHabits =>
      'Exemplo: caminhei 15 minutos depois do jantar';

  @override
  String get captureHintWeek =>
      'Exemplo: o foco de sexta deve ficar em trabalho admin';

  @override
  String get captureHintFinance => 'Exemplo: comprei cafe e sanduiche por 8.50';

  @override
  String get captureHintPantry => 'Exemplo: o espinafre vence amanha';

  @override
  String get captureHintWardrobe =>
      'Exemplo: pensando em comprar outra jaqueta preta';

  @override
  String get captureHintCopilot => 'Exemplo: uma nota de missao';

  @override
  String get copilotTitle => 'Copilot';

  @override
  String get copilotIntro =>
      'O copilot agora trabalha em torno de um plano diario ranqueado: trace visivel, tres missoes e fallback local quando o gateway esta indisponivel.';

  @override
  String get copilotBoundariesTitle => 'Limites de reflexao';

  @override
  String get copilotBoundariesBody =>
      'GoLife ajuda com organizacao diaria e reflexao pratica. Nao diagnostica, nao oferece terapia e nao substitui cuidado profissional. Se algo parecer urgente ou inseguro, use suporte real de crise ou medico.';

  @override
  String get copilotTodayPlanTitle => 'Plano de hoje';

  @override
  String get copilotNoPlan => 'Nenhum plano de missoes carregado ainda.';

  @override
  String get copilotLatestTraceTitle => 'Ultimo trace';

  @override
  String get copilotNoTrace => 'Nenhuma missao carregada ainda.';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'GoLife AI';

  @override
  String get appShellTaglineReady =>
      'Shell do sistema de vida com limites de privacidade explicitos.';

  @override
  String get appShellTaglineBooting =>
      'Inicializando privacidade, missoes e grafo local...';

  @override
  String get navigate => 'Navegar';

  @override
  String get navDashboard => 'Inicio';

  @override
  String get navCapture => 'Capturar';

  @override
  String get navWeek => 'Semana';

  @override
  String get navTasks => 'Tarefas';

  @override
  String get navHabits => 'Habitos';

  @override
  String get navMoney => 'Dinheiro';

  @override
  String get navPantry => 'Despensa';

  @override
  String get navCloset => 'Armario';

  @override
  String get navEveryday => 'Cotidiano';

  @override
  String get navCopilot => 'Copilot';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Padrao do sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Espanol';

  @override
  String get languagePortugueseBrazil => 'Portugues Brasil';

  @override
  String get languageJapanese => 'Japones';

  @override
  String get languageChineseSimplified => 'Chines simplificado';

  @override
  String get privacyTitle => 'Privacidade';

  @override
  String get privacyIntro =>
      'Cada evento fica local, salvo quando a permissao do dominio e o nivel de privacidade permitem IA. Esta tela tambem oferece exportacao local e limpeza completa.';

  @override
  String get privacyEncryptedActive =>
      'A criptografia local sensivel esta ativa para Journal, Quick Notes e Finance neste dispositivo.';

  @override
  String get privacyEncryptedUnavailable =>
      'A criptografia local sensivel nao esta disponivel neste ambiente. Trate Journal, Quick Notes e Finance como nao protegidos em repouso ate o secure storage voltar.';

  @override
  String get privacyCenter => 'Centro de privacidade';

  @override
  String get privacyDisclosureEncryptedTitle => 'Criptografado localmente';

  @override
  String get privacyDisclosureEncryptedBody =>
      'Estas colecoes ficam protegidas em repouso neste dispositivo.';

  @override
  String get privacyDisclosureLocalTitle => 'Sempre local';

  @override
  String get privacyDisclosureLocalBody =>
      'Esses itens ficam no dispositivo e nao entram no roteamento de IA.';

  @override
  String get privacyDisclosureAiTitle =>
      'Pode ser enviado para IA se permitido';

  @override
  String get privacyDisclosureAiBody =>
      'So dominios com permissao de IA e eventos AI-allowed podem ser enviados.';

  @override
  String get privacyMetricTotalEvents => 'Eventos totais';

  @override
  String get privacyMetricAiEligible => 'Elegiveis para IA';

  @override
  String get privacyMetricBlockedLocal => 'Bloqueados localmente';

  @override
  String get dataControls => 'Controles de dados';

  @override
  String get dataControlsBody =>
      'Exportar copia o snapshot local completo em JSON. Apagar tudo limpa os dados locais e desativa a semeadura demo.';

  @override
  String get exportJson => 'Exportar JSON';

  @override
  String get deleteAllLocalData => 'Apagar todos os dados locais';

  @override
  String get domainControls => 'Controles por dominio';

  @override
  String get exportCopied =>
      'A exportacao JSON local foi copiada para a area de transferencia.';

  @override
  String get deleteAllTitle => 'Apagar todos os dados locais?';

  @override
  String get deleteAllBody =>
      'Isso remove eventos locais, entidades, missoes, feedback, ajustes de privacidade, cache runtime e preferencia de idioma neste dispositivo.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deleteAll => 'Apagar tudo';

  @override
  String get deleteAllDone => 'Todos os dados locais foram apagados.';

  @override
  String domainEventsEligible(int eventCount, int aiCount) {
    return '$eventCount eventos · $aiCount elegiveis para IA agora';
  }

  @override
  String get permissionLocal => 'Local';

  @override
  String get permissionSync => 'Sync';

  @override
  String get permissionAi => 'IA';

  @override
  String get domainHabits => 'Habitos';

  @override
  String get domainTasks => 'Tarefas';

  @override
  String get domainWeek => 'Semana';

  @override
  String get domainFinance => 'Dinheiro';

  @override
  String get domainPantry => 'Despensa';

  @override
  String get domainWardrobe => 'Armario';

  @override
  String get domainCopilot => 'Copilot';

  @override
  String get collectionFinanceRecords => 'Registros financeiros';

  @override
  String get collectionJournalEntries => 'Entradas de journal';

  @override
  String get collectionQuickNotes => 'Notas rapidas';

  @override
  String get collectionPrivacySettings => 'Ajustes de privacidade';

  @override
  String get collectionRuntimeConfigCache => 'Cache de runtime config';

  @override
  String get collectionDeviceEncryptionKey =>
      'Chave de criptografia do dispositivo';

  @override
  String get nothingAiEnabled => 'Nenhum dominio esta com IA ativa agora';

  @override
  String get gatewayLive => 'Gateway ativo';

  @override
  String get gatewayNoConnection => 'Sem conexao';

  @override
  String get gatewayUnavailable => 'IA temporariamente indisponivel';

  @override
  String get gatewayLocalFallback => 'Usando fallback local';

  @override
  String get feedbackNone => 'Sem feedback ainda';

  @override
  String get feedbackUseful => 'Util';

  @override
  String get feedbackRejected => 'Rejeitado';

  @override
  String get feedbackAccepted => 'Aceito';

  @override
  String get feedbackCompleted => 'Concluido';

  @override
  String get feedbackEdited => 'Editado';

  @override
  String get missionDeliveryAi => 'Com ajuda de IA';

  @override
  String get missionDeliveryFallback => 'Fallback local';

  @override
  String get missionDeliveryLocal => 'Local';

  @override
  String get missionDeliverySummaryAi =>
      'GoLife usou IA para esta missao depois do filtro local de privacidade.';

  @override
  String get missionDeliverySummaryFallback =>
      'GoLife ficou local porque o gateway estava indisponivel ou degradado.';

  @override
  String get missionDeliverySummaryLocal =>
      'GoLife manteve esta missao local no dispositivo.';

  @override
  String get actionWrite => 'Escrever';

  @override
  String get actionChat => 'Conversar';

  @override
  String get actionExplain => 'Explicar';

  @override
  String get actionUseful => 'Util';

  @override
  String get actionDoNow => 'Fazer agora';

  @override
  String get actionNotUseful => 'Nao util';

  @override
  String get actionAccept => 'Aceitar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionRemove => 'Remover';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionParseCapture => 'Parsear captura';

  @override
  String get actionReparseCapture => 'Parsear de novo';

  @override
  String actionSaveCaptureItems(int count) {
    return 'Salvar $count itens';
  }

  @override
  String get statusReady => 'Pronto';

  @override
  String get statusBooting => 'Inicializando';

  @override
  String get labelEvidence => 'Evidencia';

  @override
  String get labelDataUsedForMission => 'Dados usados para esta missao';

  @override
  String get labelDataSentToAi => 'Dados enviados para IA';

  @override
  String get labelBlockedFromAi => 'Bloqueado para IA';

  @override
  String get labelAlwaysLocalOnDevice => 'Sempre local neste dispositivo';

  @override
  String get labelEncryptedLocally => 'Criptografado localmente';

  @override
  String get labelUncertainty => 'Incerteza';

  @override
  String get labelTrace => 'Trace';

  @override
  String get fieldDomain => 'Dominio';

  @override
  String get fieldPrivacy => 'Privacidade';

  @override
  String get dashboardDisclosurePending =>
      'GoLife mantem os dados locais ate uma missao ficar pronta.';

  @override
  String dashboardMissionCountTitle(int count) {
    return '$count missoes para hoje';
  }

  @override
  String get dashboardMissionIntro =>
      'Home Today transforma o grafo em acoes pequenas: uma missao principal, duas de apoio, evidencia visivel e feedback rapido.';

  @override
  String get dashboardLoadingMissions => 'Carregando missoes...';

  @override
  String get dashboardBootstrappingMission =>
      'Inicializando eventos locais, ranking de missoes e trace do gateway.';

  @override
  String dashboardRiskCount(int count) {
    return '$count riscos';
  }

  @override
  String dashboardConfidencePill(int percent) {
    return '$percent% de confianca';
  }

  @override
  String get dashboardAiDisclosureTitle => 'Disclosure de dados para IA';

  @override
  String dashboardAiDisclosureSummary(
      Object summary, int sentCount, int blockedCount) {
    return '$summary Enviado agora: $sentCount eventos locais. Bloqueados localmente: $blockedCount.';
  }

  @override
  String get dashboardRisksTitle => 'Riscos de hoje';

  @override
  String get dashboardNoRisks =>
      'Nenhum risco diario explicito foi detectado no grafo atual elegivel para IA.';

  @override
  String get dashboardSupportMissionsTitle => 'Missoes de apoio';

  @override
  String get dashboardNoSupportMissions =>
      'Missoes secundarias aparecerao quando o plano diario estiver disponivel.';

  @override
  String get signalCriticalTask => 'Tarefa critica';

  @override
  String get signalRecoveryHabit => 'Habito de recuperacao';

  @override
  String signalRecoveryHabitBody(Object cue, Object streak) {
    return 'Gatilho: $cue - $streak';
  }

  @override
  String get signalRelevantSpend => 'Gasto relevante';

  @override
  String get signalUseThisFood => 'Use este alimento';

  @override
  String get dashboardWhyThisToday => 'Por que esta hoje';

  @override
  String dashboardConfidenceWithType(int percent, Object type) {
    return 'Confianca $percent% - $type';
  }

  @override
  String get dashboardNothingSent =>
      'Nada foi enviado para esta missao. GoLife ficou local neste passo.';

  @override
  String get dashboardNothingBlocked =>
      'Nenhum item especifico desta missao foi bloqueado para IA.';

  @override
  String get dashboardNoAlwaysLocalCollections =>
      'Nenhuma colecao sempre local configurada.';

  @override
  String get dashboardNoEncryptedCollections =>
      'Nenhuma colecao criptografada configurada.';

  @override
  String dashboardRiskSeverityLabel(Object severity) {
    return 'risco $severity';
  }

  @override
  String get captureTitle => 'Capturar';

  @override
  String get captureIntro =>
      'Escreva uma frase. GoLife pode dividir em varios rascunhos, deixar voce editar dominio e privacidade por item, e salvar tudo junto.';

  @override
  String get captureRouteTitle => 'Rota';

  @override
  String get captureAutoRoute => 'Auto';

  @override
  String get captureAutoModeBody =>
      'O modo auto tenta dividir e classificar cada clausula primeiro.';

  @override
  String captureCurrentDefaultPrivacy(Object domain, Object permission) {
    return 'Privacidade padrao atual para $domain: $permission';
  }

  @override
  String get captureDraftsToConfirm => 'Rascunhos para confirmar';

  @override
  String get captureRecentEvents => 'Eventos recentes';

  @override
  String capturePrivacyLabel(Object privacy) {
    return 'Privacidade: $privacy';
  }

  @override
  String captureItemsCaptured(int count) {
    return '$count item(s) capturados.';
  }

  @override
  String get captureEditItemTitle => 'Editar item';

  @override
  String get captureHintAuto =>
      'Exemplo: comprei cafe por 4.50, a alface vence amanha e preciso pagar internet.';

  @override
  String get captureHintTasks =>
      'Exemplo: enviar recibo do aluguel antes do almoco';

  @override
  String get captureHintHabits =>
      'Exemplo: caminhei 15 minutos depois do jantar';

  @override
  String get captureHintWeek =>
      'Exemplo: o foco de sexta deve ficar em trabalho admin';

  @override
  String get captureHintFinance => 'Exemplo: comprei cafe e sanduiche por 8.50';

  @override
  String get captureHintPantry => 'Exemplo: o espinafre vence amanha';

  @override
  String get captureHintWardrobe =>
      'Exemplo: pensando em comprar outra jaqueta preta';

  @override
  String get captureHintCopilot => 'Exemplo: uma nota de missao';

  @override
  String get copilotTitle => 'Copilot';

  @override
  String get copilotIntro =>
      'O copilot agora trabalha em torno de um plano diario ranqueado: trace visivel, tres missoes e fallback local quando o gateway esta indisponivel.';

  @override
  String get copilotBoundariesTitle => 'Limites de reflexao';

  @override
  String get copilotBoundariesBody =>
      'GoLife ajuda com organizacao diaria e reflexao pratica. Nao diagnostica, nao oferece terapia e nao substitui cuidado profissional. Se algo parecer urgente ou inseguro, use suporte real de crise ou medico.';

  @override
  String get copilotTodayPlanTitle => 'Plano de hoje';

  @override
  String get copilotNoPlan => 'Nenhum plano de missoes carregado ainda.';

  @override
  String get copilotLatestTraceTitle => 'Ultimo trace';

  @override
  String get copilotNoTrace => 'Nenhuma missao carregada ainda.';
}

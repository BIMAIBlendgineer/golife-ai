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
  String get collectionOwnedItems => 'Owned items';

  @override
  String get collectionPurchaseProofs => 'Purchase proofs';

  @override
  String get collectionClaimDrafts => 'Claim drafts';

  @override
  String get collectionEvidenceAttachments => 'Evidence attachments';

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

  @override
  String get navJournal => 'Journal';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navRecipes => 'Recipes';

  @override
  String get homeMemoryEyebrow => 'RecallBox';

  @override
  String get homeMemoryTitle => 'HomeMemory';

  @override
  String get homeMemorySubtitle =>
      'Things, receipts, warranties, and reminders.';

  @override
  String get homeMemoryDisclosureTitle => 'Local purchase memory';

  @override
  String get homeMemoryDisclosureBody =>
      'Receipts, draft claims, and evidence stay local-first in this MVP. GoLife turns them into reminders and next actions without promising legal review.';

  @override
  String get homeMemoryWarrantySoonTitle => 'Warranty ending soon';

  @override
  String get homeMemoryWarrantySoonEmpty =>
      'No active warranty close to expiration.';

  @override
  String get homeMemoryRecentProofsTitle => 'Recent proofs';

  @override
  String get homeMemoryRecentProofsEmpty => 'No proofs captured yet.';

  @override
  String get homeMemoryRemindersTitle => 'Maintenance reminders';

  @override
  String get homeMemoryRemindersEmpty => 'No reminders scheduled.';

  @override
  String get homeMemoryClaimsTitle => 'Claim drafts';

  @override
  String get homeMemoryClaimsEmpty => 'No draft claims yet.';

  @override
  String get homeMemoryActionAddItem => 'Add item manually';

  @override
  String get homeMemoryActionAddProof => 'Add proof';

  @override
  String get homeMemoryActionCreateReminder => 'Create reminder';

  @override
  String get homeMemoryActionDraftClaim => 'Draft claim';

  @override
  String get homeMemoryActionOpen => 'Open HomeMemory';

  @override
  String get homeMemoryItemsTitle => 'Owned items';

  @override
  String get homeMemoryItemsEmpty => 'No owned items stored yet.';

  @override
  String homeMemoryWarrantyUntilLabel(Object date) {
    return 'Warranty until $date';
  }

  @override
  String get homeMemoryItemNoMeta => 'No purchase metadata yet.';

  @override
  String get homeMemorySectionItem => 'Item';

  @override
  String get homeMemorySectionProofs => 'Proofs';

  @override
  String get homeMemorySectionWarranty => 'Warranty';

  @override
  String get homeMemorySectionReminders => 'Reminders';

  @override
  String get homeMemorySectionClaims => 'Claim drafts';

  @override
  String get homeMemorySectionEvidence => 'Evidence';

  @override
  String get homeMemoryFieldProductName => 'Product name';

  @override
  String get homeMemoryFieldBrand => 'Brand';

  @override
  String get homeMemoryFieldModel => 'Model';

  @override
  String get homeMemoryFieldSerialNumber => 'Serial number';

  @override
  String get homeMemoryFieldStore => 'Store';

  @override
  String get homeMemoryFieldPurchaseDate => 'Purchase date';

  @override
  String get homeMemoryFieldPrice => 'Price';

  @override
  String get homeMemoryFieldCurrency => 'Currency';

  @override
  String get homeMemoryFieldWarrantyMonths => 'Warranty months';

  @override
  String get homeMemoryFieldWarrantyUntil => 'Warranty until';

  @override
  String get homeMemoryFieldDueDate => 'Due date';

  @override
  String get homeMemoryFieldRecurrence => 'Recurrence';

  @override
  String get homeMemoryFieldIssueDescription => 'Issue description';

  @override
  String get homeMemoryFieldRecipientHint => 'Recipient hint';

  @override
  String get homeMemoryCreateWarrantyReminder =>
      'Create a reminder before warranty expiration';

  @override
  String get homeMemoryDefaultReminderTitle =>
      'Review warranty before expiration';

  @override
  String get homeMemorySelectItem => 'Select item';

  @override
  String get homeMemoryClaimDisclaimer =>
      'No legal advice. Verify warranty and seller policies. Send outside the app.';

  @override
  String get homeMemoryNoNotes => 'No notes';

  @override
  String get homeMemoryUnknownMerchant => 'Unknown merchant';

  @override
  String get homeMemoryUnknownDate => 'Unknown date';

  @override
  String get homeMemoryUnknownValue => 'Unknown';

  @override
  String get homeMemoryNoProofs => 'No proofs attached yet.';

  @override
  String get homeMemoryWarrantyUnknown => 'Warranty unknown.';

  @override
  String get homeMemoryNoReminders => 'No reminders yet.';

  @override
  String get homeMemoryNoClaims => 'No claim drafts yet.';

  @override
  String get homeMemoryNoEvidence => 'No evidence attached yet.';

  @override
  String get homeMemoryEvidencePresent => 'Evidence attachment available.';

  @override
  String get homeMemoryWarrantyStatusUnknown => 'unknown';

  @override
  String get homeMemoryWarrantyStatusExpired => 'expired';

  @override
  String get homeMemoryWarrantyStatusActive => 'active warranty';

  @override
  String homeMemoryEverydaySubtitle(int itemCount, int warrantyCount) {
    return '$itemCount items | $warrantyCount warranties ending soon';
  }

  @override
  String get homeMemoryEverydayBody =>
      'Keep receipts, owned items, warranties, reminders, and draft claims in one local memory surface.';

  @override
  String get entityTask => 'task';

  @override
  String get entityHabit => 'habit';

  @override
  String get entityExpense => 'expense';

  @override
  String get entityPantryItem => 'pantry item';

  @override
  String get entityPurchaseIntention => 'purchase intention';

  @override
  String get entityWeekPlan => 'week plan';

  @override
  String get entityJournalEntry => 'journal entry';

  @override
  String get entityQuickNote => 'quick note';

  @override
  String get entityCalendarItem => 'calendar item';

  @override
  String get entityRecipeRescue => 'recipe rescue';

  @override
  String actionNewEntity(Object entity) {
    return 'New $entity';
  }

  @override
  String actionEditEntity(Object entity) {
    return 'Edit $entity';
  }

  @override
  String get actionComplete => 'Complete';

  @override
  String get actionDone => 'Done';

  @override
  String get actionCheckIn => 'Check in';

  @override
  String get actionReflect => 'Reflect';

  @override
  String get actionMarkUsed => 'Mark used';

  @override
  String get actionUsed => 'Used';

  @override
  String get actionPause24h => 'Pause 24h';

  @override
  String get actionReplan => 'Replan';

  @override
  String get actionReview => 'Review';

  @override
  String get actionKeepLocal => 'Keep local';

  @override
  String get actionOpenJournal => 'Open journal';

  @override
  String get actionOpenCalendar => 'Open calendar';

  @override
  String get actionOpenRecipes => 'Open recipes';

  @override
  String get actionCookNow => 'Cook now';

  @override
  String get actionCooked => 'Cooked';

  @override
  String get actionTimeBlock => 'Time block';

  @override
  String get actionSaving => 'Saving...';

  @override
  String get domainTasksEyebrow => 'Execution';

  @override
  String get domainTasksDescription =>
      'TaskDoctor is now a local-first task board with direct create, edit, and complete flows.';

  @override
  String get domainHabitsEyebrow => 'Continuity';

  @override
  String get domainHabitsDescription =>
      'LifeQuest now supports direct habit creation and recovery-friendly check-ins.';

  @override
  String get domainMoneyEyebrow => 'Awareness';

  @override
  String get domainMoneyDescription =>
      'MoneyMirror stays conservative: log, edit, and reflect locally without crossing into regulated advice.';

  @override
  String get domainPantryEyebrow => 'Rescue';

  @override
  String get domainPantryDescription =>
      'FridgeZero now keeps a rescue board where ingredients can be created, edited, and marked used.';

  @override
  String get domainClosetEyebrow => 'Anti-consumption';

  @override
  String get domainClosetDescription =>
      'ClosetLess remains an intention-first board, now with editable pauses and purchase reasons.';

  @override
  String get domainWeekEyebrow => 'Planner';

  @override
  String get domainWeekDescription =>
      'WeekPilot stays intentionally light, but now supports quick creation and direct replanning.';

  @override
  String get domainJournalEyebrow => 'Private by default';

  @override
  String get domainJournalDescription =>
      'Journal and notes stay local-first so the app can learn from your day without turning into therapy.';

  @override
  String get domainCalendarEyebrow => 'QuickCal';

  @override
  String get domainCalendarDescription =>
      'QuickCal starts as a fast local layer for time blocks and overload detection, not a full sync engine.';

  @override
  String get domainRecipesEyebrow => 'Recipe Rescue';

  @override
  String get domainRecipesDescription =>
      'Recipe Rescue turns pantry context into simple local meal plans that can mark ingredients as used.';

  @override
  String get domainEverydayEyebrow => 'Life OS';

  @override
  String get domainEverydayDescription =>
      'Journal, calendar, and recipes live together here so the shell stays lighter while everyday context keeps growing.';

  @override
  String get tasksEmpty => 'No tasks captured yet.';

  @override
  String get habitsEmpty => 'No habits captured yet.';

  @override
  String get moneyEmpty => 'No expenses captured yet.';

  @override
  String get pantryEmpty => 'No pantry items captured yet.';

  @override
  String get closetEmpty => 'No purchase intentions captured yet.';

  @override
  String get weekEmpty => 'No week plans captured yet.';

  @override
  String get journalEmpty => 'No journal entries yet.';

  @override
  String get quickNotesEmpty => 'No quick notes yet.';

  @override
  String get calendarEmpty => 'No calendar items yet.';

  @override
  String get recipesEmpty => 'No recipe rescues yet.';

  @override
  String get calendarOverloadTitle => 'Overload detected';

  @override
  String get calendarOverloadBody =>
      'There are already four or more local calendar items. Protect the smallest non-critical block first.';

  @override
  String get calendarCalmTitle => 'Calm calendar';

  @override
  String get calendarCalmBody =>
      'Use QuickCal for fast local blocks before adding full calendar sync.';

  @override
  String get everydayContextTitle => 'Everyday context';

  @override
  String get everydayContextBody =>
      'Use writing, time blocks, and recipe rescue to give Today better context without turning the app into six crowded tabs.';

  @override
  String get everydayJournalBody =>
      'Capture reflection and short notes locally, with privacy-first defaults.';

  @override
  String get everydayCalendarBody =>
      'Keep a quick local calendar before you need full sync.';

  @override
  String get everydayRecipesBody =>
      'Turn pantry context into low-friction meals and mark ingredients used.';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldEstimatedMinutes => 'Estimated minutes';

  @override
  String get fieldPriority => 'Priority';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldCue => 'Cue';

  @override
  String get fieldCadence => 'Cadence';

  @override
  String get fieldLabel => 'Label';

  @override
  String get fieldAmount => 'Amount';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldQuantity => 'Quantity';

  @override
  String get fieldRescueHint => 'Rescue hint';

  @override
  String get fieldReason => 'Reason';

  @override
  String get fieldTheme => 'Theme';

  @override
  String get fieldFocus => 'Focus';

  @override
  String get fieldMood => 'Mood';

  @override
  String get fieldBody => 'Body';

  @override
  String get fieldNote => 'Note';

  @override
  String get fieldStartIso => 'Start ISO';

  @override
  String get fieldEndIso => 'End ISO';

  @override
  String get fieldLocation => 'Location';

  @override
  String get fieldEnergy => 'Energy';

  @override
  String get fieldSummary => 'Summary';

  @override
  String get fieldIngredientsCommaSeparated => 'Ingredients (comma separated)';

  @override
  String get chipRescue => 'Rescue';

  @override
  String get chipPurchaseIntention => 'Purchase intention';

  @override
  String get chipJournal => 'Journal';

  @override
  String get chipNote => 'Note';

  @override
  String get chipLocalOnly => 'Local only';

  @override
  String get statusTaskInbox => 'Inbox';

  @override
  String get statusTaskActive => 'Active';

  @override
  String get statusTaskDone => 'Done';

  @override
  String get priorityGentle => 'Gentle';

  @override
  String get priorityStandard => 'Standard';

  @override
  String get priorityCritical => 'Critical';

  @override
  String get cadenceDaily => 'Daily';

  @override
  String get cadenceWeekdays => 'Weekdays';

  @override
  String get cadenceWeekly => 'Weekly';

  @override
  String get recipeStatusDraft => 'Draft';

  @override
  String get recipeStatusCooked => 'Cooked';

  @override
  String get unitMinutesShort => 'min';

  @override
  String get journalQuickNotesTitle => 'Quick notes';

  @override
  String get messageTaskUpdated => 'Task updated.';

  @override
  String get messageHabitCheckedIn => 'Habit checked in.';

  @override
  String get messageExpenseRevisited => 'Expense revisited.';

  @override
  String get messagePantryItemUpdated => 'Pantry item updated.';

  @override
  String get messagePurchaseIntentionPaused => 'Purchase intention paused.';

  @override
  String get messageWeekPlanUpdated => 'Week plan updated.';

  @override
  String get messageJournalLocalOnly => 'Journal stays local on this device.';

  @override
  String get messageNoteLocalOnly => 'Note stays local on this device.';

  @override
  String get messageOpeningEditor => 'Opening editor.';

  @override
  String get messageRecipeUpdated => 'Recipe rescue updated.';

  @override
  String messageEntitySaved(Object entity) {
    return '$entity saved.';
  }

  @override
  String taskTimeboxFirstBlock(int minutes) {
    return '$minutes min first block';
  }

  @override
  String habitStreakDays(int count) {
    return '$count-day streak';
  }

  @override
  String everydayJournalSubtitle(int entryCount, int noteCount) {
    return '$entryCount entries | $noteCount quick notes';
  }

  @override
  String get overloadDetected => 'detected';

  @override
  String get overloadNotDetected => 'not detected';

  @override
  String everydayCalendarSubtitle(int blockCount, Object status) {
    return '$blockCount local blocks | overload $status';
  }

  @override
  String everydayRecipesSubtitle(int count) {
    return '$count rescue ideas';
  }

  @override
  String get labelToday => 'Hoje';

  @override
  String get mockCriticalTaskTitle => 'Conclua a proxima tarefa critica';

  @override
  String mockCriticalTaskBody(int minutes, String priority) {
    return 'Proteja um bloco de $minutes minutos para a proxima etapa critica e mantenha a prioridade em $priority.';
  }

  @override
  String get mockRecoveryHabitTitle => 'Mantenha vivo o ritmo de recuperacao';

  @override
  String get mockFinanceSummaryTitle => 'Revise o sinal de gasto';

  @override
  String mockFinanceSummaryBody(String label, String amount) {
    return 'Revise $label e decida se $amount ainda responde a uma necessidade real.';
  }

  @override
  String get mockPantrySummaryTitle => 'Use um ingrediente que ja esta em casa';

  @override
  String get mockPantrySummaryBody =>
      'Comece pelo ingrediente mais antigo antes de abrir um novo ciclo de compra.';
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

  @override
  String get navJournal => 'Journal';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navRecipes => 'Receitas';

  @override
  String get entityTask => 'tarefa';

  @override
  String get entityHabit => 'habito';

  @override
  String get entityExpense => 'gasto';

  @override
  String get entityPantryItem => 'item da despensa';

  @override
  String get entityPurchaseIntention => 'intencao de compra';

  @override
  String get entityWeekPlan => 'plano semanal';

  @override
  String get entityJournalEntry => 'entrada do journal';

  @override
  String get entityQuickNote => 'nota rapida';

  @override
  String get entityCalendarItem => 'bloco de calendario';

  @override
  String get entityRecipeRescue => 'receita de resgate';

  @override
  String actionNewEntity(Object entity) {
    return 'Nova $entity';
  }

  @override
  String actionEditEntity(Object entity) {
    return 'Editar $entity';
  }

  @override
  String get actionComplete => 'Concluir';

  @override
  String get actionDone => 'Feita';

  @override
  String get actionCheckIn => 'Registrar';

  @override
  String get actionReflect => 'Revisar';

  @override
  String get actionMarkUsed => 'Marcar como usado';

  @override
  String get actionUsed => 'Usado';

  @override
  String get actionPause24h => 'Pausar 24 h';

  @override
  String get actionReplan => 'Replanejar';

  @override
  String get actionReview => 'Revisar';

  @override
  String get actionKeepLocal => 'Manter local';

  @override
  String get actionOpenJournal => 'Abrir journal';

  @override
  String get actionOpenCalendar => 'Abrir calendario';

  @override
  String get actionOpenRecipes => 'Abrir receitas';

  @override
  String get actionCookNow => 'Cozinhar agora';

  @override
  String get actionCooked => 'Cozinhado';

  @override
  String get actionTimeBlock => 'Bloco';

  @override
  String get actionSaving => 'Salvando...';

  @override
  String get domainTasksEyebrow => 'Execucao';

  @override
  String get domainTasksDescription =>
      'TaskDoctor agora e um quadro local-first com fluxos diretos para criar, editar e concluir.';

  @override
  String get domainHabitsEyebrow => 'Continuidade';

  @override
  String get domainHabitsDescription =>
      'LifeQuest agora suporta criacao direta de habitos e check-ins amigaveis para recuperacao.';

  @override
  String get domainMoneyEyebrow => 'Consciencia';

  @override
  String get domainMoneyDescription =>
      'MoneyMirror continua conservador: registrar, editar e revisar localmente sem cruzar para conselho regulado.';

  @override
  String get domainPantryEyebrow => 'Resgate';

  @override
  String get domainPantryDescription =>
      'FridgeZero agora mantem um quadro de resgate onde ingredientes podem ser criados, editados e marcados como usados.';

  @override
  String get domainClosetEyebrow => 'Anti-consumo';

  @override
  String get domainClosetDescription =>
      'ClosetLess continua um quadro orientado por intencao, agora com pausas editaveis e motivos de compra.';

  @override
  String get domainWeekEyebrow => 'Planner';

  @override
  String get domainWeekDescription =>
      'WeekPilot continua leve de proposito, mas agora suporta criacao rapida e replanejamento direto.';

  @override
  String get domainJournalEyebrow => 'Privado por padrao';

  @override
  String get domainJournalDescription =>
      'Journal e notas continuam local-first para que o app aprenda com seu dia sem virar terapia.';

  @override
  String get domainCalendarEyebrow => 'QuickCal';

  @override
  String get domainCalendarDescription =>
      'QuickCal comeca como uma camada local rapida para blocos de tempo e deteccao de sobrecarga, nao como um motor completo de sync.';

  @override
  String get domainRecipesEyebrow => 'Recipe Rescue';

  @override
  String get domainRecipesDescription =>
      'Recipe Rescue transforma o contexto da despensa em planos locais simples de refeicao que podem marcar ingredientes como usados.';

  @override
  String get domainEverydayEyebrow => 'Life OS';

  @override
  String get domainEverydayDescription =>
      'Journal, calendario e receitas vivem juntos aqui para que o shell continue leve enquanto o contexto do dia a dia cresce.';

  @override
  String get tasksEmpty => 'Nenhuma tarefa capturada ainda.';

  @override
  String get habitsEmpty => 'Nenhum habito capturado ainda.';

  @override
  String get moneyEmpty => 'Nenhum gasto capturado ainda.';

  @override
  String get pantryEmpty => 'Nenhum item de despensa ainda.';

  @override
  String get closetEmpty => 'Nenhuma intencao de compra ainda.';

  @override
  String get weekEmpty => 'Nenhum plano semanal ainda.';

  @override
  String get journalEmpty => 'Nenhuma entrada de journal ainda.';

  @override
  String get quickNotesEmpty => 'Nenhuma nota rapida ainda.';

  @override
  String get calendarEmpty => 'Nenhum bloco de calendario ainda.';

  @override
  String get recipesEmpty => 'Nenhuma receita de resgate ainda.';

  @override
  String get calendarOverloadTitle => 'Sobrecarga detectada';

  @override
  String get calendarOverloadBody =>
      'Ja existem quatro ou mais blocos locais no calendario. Proteja primeiro o menor bloco nao critico.';

  @override
  String get calendarCalmTitle => 'Calendario calmo';

  @override
  String get calendarCalmBody =>
      'Use o QuickCal para blocos locais rapidos antes de adicionar sync completo.';

  @override
  String get everydayContextTitle => 'Contexto cotidiano';

  @override
  String get everydayContextBody =>
      'Use escrita, blocos de tempo e recipe rescue para dar ao Today mais contexto sem transformar o app em seis abas cheias.';

  @override
  String get everydayJournalBody =>
      'Capture reflexao e notas curtas localmente, com padroes de privacidade em primeiro lugar.';

  @override
  String get everydayCalendarBody =>
      'Mantenha um calendario local rapido antes de precisar de sync completo.';

  @override
  String get everydayRecipesBody =>
      'Transforme o contexto da despensa em refeicoes de baixa friccao e marque ingredientes usados.';

  @override
  String get fieldTitle => 'Titulo';

  @override
  String get fieldEstimatedMinutes => 'Minutos estimados';

  @override
  String get fieldPriority => 'Prioridade';

  @override
  String get fieldNotes => 'Notas';

  @override
  String get fieldCue => 'Gatilho';

  @override
  String get fieldCadence => 'Cadencia';

  @override
  String get fieldLabel => 'Rotulo';

  @override
  String get fieldAmount => 'Valor';

  @override
  String get fieldCategory => 'Categoria';

  @override
  String get fieldName => 'Nome';

  @override
  String get fieldQuantity => 'Quantidade';

  @override
  String get fieldRescueHint => 'Dica de resgate';

  @override
  String get fieldReason => 'Motivo';

  @override
  String get fieldTheme => 'Tema';

  @override
  String get fieldFocus => 'Foco';

  @override
  String get fieldMood => 'Humor';

  @override
  String get fieldBody => 'Texto';

  @override
  String get fieldNote => 'Nota';

  @override
  String get fieldStartIso => 'Inicio ISO';

  @override
  String get fieldEndIso => 'Fim ISO';

  @override
  String get fieldLocation => 'Local';

  @override
  String get fieldEnergy => 'Energia';

  @override
  String get fieldSummary => 'Resumo';

  @override
  String get fieldIngredientsCommaSeparated =>
      'Ingredientes (separados por virgula)';

  @override
  String get chipRescue => 'Resgate';

  @override
  String get chipPurchaseIntention => 'Intencao de compra';

  @override
  String get chipJournal => 'Journal';

  @override
  String get chipNote => 'Nota';

  @override
  String get chipLocalOnly => 'So local';

  @override
  String get statusTaskInbox => 'Inbox';

  @override
  String get statusTaskActive => 'Ativa';

  @override
  String get statusTaskDone => 'Feita';

  @override
  String get priorityGentle => 'Suave';

  @override
  String get priorityStandard => 'Padrao';

  @override
  String get priorityCritical => 'Critica';

  @override
  String get cadenceDaily => 'Diaria';

  @override
  String get cadenceWeekdays => 'Dias uteis';

  @override
  String get cadenceWeekly => 'Semanal';

  @override
  String get recipeStatusDraft => 'Rascunho';

  @override
  String get recipeStatusCooked => 'Cozinhada';

  @override
  String get unitMinutesShort => 'min';

  @override
  String get journalQuickNotesTitle => 'Notas rapidas';

  @override
  String get messageTaskUpdated => 'Tarefa atualizada.';

  @override
  String get messageHabitCheckedIn => 'Habito registrado.';

  @override
  String get messageExpenseRevisited => 'Gasto revisitado.';

  @override
  String get messagePantryItemUpdated => 'Item da despensa atualizado.';

  @override
  String get messagePurchaseIntentionPaused => 'Intencao de compra pausada.';

  @override
  String get messageWeekPlanUpdated => 'Plano semanal atualizado.';

  @override
  String get messageJournalLocalOnly =>
      'O journal fica local neste dispositivo.';

  @override
  String get messageNoteLocalOnly => 'A nota fica local neste dispositivo.';

  @override
  String get messageOpeningEditor => 'Abrindo editor.';

  @override
  String get messageRecipeUpdated => 'Receita de resgate atualizada.';

  @override
  String messageEntitySaved(Object entity) {
    return '$entity salva.';
  }

  @override
  String taskTimeboxFirstBlock(int minutes) {
    return '$minutes min no primeiro bloco';
  }

  @override
  String habitStreakDays(int count) {
    return 'sequencia de $count dias';
  }

  @override
  String everydayJournalSubtitle(int entryCount, int noteCount) {
    return '$entryCount entradas | $noteCount notas rapidas';
  }

  @override
  String get overloadDetected => 'detectada';

  @override
  String get overloadNotDetected => 'nao detectada';

  @override
  String everydayCalendarSubtitle(int blockCount, Object status) {
    return '$blockCount blocos locais | sobrecarga $status';
  }

  @override
  String everydayRecipesSubtitle(int count) {
    return '$count ideias de resgate';
  }

  @override
  String get labelToday => 'Hoje';

  @override
  String get mockCriticalTaskTitle => 'Conclua a proxima tarefa critica';

  @override
  String mockCriticalTaskBody(int minutes, String priority) {
    return 'Proteja um bloco de $minutes minutos para a proxima etapa critica e mantenha a prioridade em $priority.';
  }

  @override
  String get mockRecoveryHabitTitle => 'Mantenha vivo o ritmo de recuperacao';

  @override
  String get mockFinanceSummaryTitle => 'Revise o sinal de gasto';

  @override
  String mockFinanceSummaryBody(String label, String amount) {
    return 'Revise $label e decida se $amount ainda responde a uma necessidade real.';
  }

  @override
  String get mockPantrySummaryTitle => 'Use um ingrediente que ja esta em casa';

  @override
  String get mockPantrySummaryBody =>
      'Comece pelo ingrediente mais antigo antes de abrir um novo ciclo de compra.';
}

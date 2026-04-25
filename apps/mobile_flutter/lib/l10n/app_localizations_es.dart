// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'GoLife AI';

  @override
  String get appShellTaglineReady =>
      'Shell del sistema de vida con limites de privacidad explicitos.';

  @override
  String get appShellTaglineBooting =>
      'Inicializando privacidad, misiones y grafo local...';

  @override
  String get navigate => 'Navegar';

  @override
  String get navDashboard => 'Inicio';

  @override
  String get navCapture => 'Capturar';

  @override
  String get navWeek => 'Semana';

  @override
  String get navTasks => 'Tareas';

  @override
  String get navHabits => 'Habitos';

  @override
  String get navMoney => 'Dinero';

  @override
  String get navPantry => 'Despensa';

  @override
  String get navCloset => 'Closet';

  @override
  String get navEveryday => 'Diario';

  @override
  String get navCopilot => 'Copilot';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Espanol';

  @override
  String get languagePortugueseBrazil => 'Portugues Brasil';

  @override
  String get languageJapanese => 'Japones';

  @override
  String get languageChineseSimplified => 'Chino simplificado';

  @override
  String get privacyTitle => 'Privacidad';

  @override
  String get privacyIntro =>
      'Cada evento queda local salvo que el permiso del dominio y el nivel de privacidad permitan IA. Esta pantalla tambien da exportacion local y borrado total.';

  @override
  String get privacyEncryptedActive =>
      'El cifrado local sensible esta activo para Journal, Quick Notes y Finance en este dispositivo.';

  @override
  String get privacyEncryptedUnavailable =>
      'El cifrado local sensible no esta disponible en este entorno. Trata Journal, Quick Notes y Finance como datos sin proteccion en reposo hasta que vuelva el secure storage.';

  @override
  String get privacyCenter => 'Centro de privacidad';

  @override
  String get privacyDisclosureEncryptedTitle => 'Cifrado local';

  @override
  String get privacyDisclosureEncryptedBody =>
      'Estas colecciones quedan protegidas en reposo en este dispositivo.';

  @override
  String get privacyDisclosureLocalTitle => 'Siempre local';

  @override
  String get privacyDisclosureLocalBody =>
      'Estos datos permanecen en el dispositivo y no entran en el routing de IA.';

  @override
  String get privacyDisclosureAiTitle => 'Puede enviarse a IA si se permite';

  @override
  String get privacyDisclosureAiBody =>
      'Solo se pueden enviar dominios con permiso de IA y eventos marcados como AI-allowed.';

  @override
  String get privacyMetricTotalEvents => 'Eventos totales';

  @override
  String get privacyMetricAiEligible => 'Aptos para IA';

  @override
  String get privacyMetricBlockedLocal => 'Bloqueados localmente';

  @override
  String get dataControls => 'Controles de datos';

  @override
  String get dataControlsBody =>
      'Exportar copia el snapshot local completo en JSON. Borrar todo limpia datos locales y desactiva la resiembra demo.';

  @override
  String get exportJson => 'Exportar JSON';

  @override
  String get deleteAllLocalData => 'Borrar todos los datos locales';

  @override
  String get domainControls => 'Controles por dominio';

  @override
  String get exportCopied =>
      'La exportacion JSON local se copio al portapapeles.';

  @override
  String get deleteAllTitle => 'Borrar todos los datos locales?';

  @override
  String get deleteAllBody =>
      'Esto elimina eventos locales, entidades, misiones, feedback, ajustes de privacidad, cache runtime y preferencia de idioma en este dispositivo.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deleteAll => 'Borrar todo';

  @override
  String get deleteAllDone => 'Todos los datos locales fueron borrados.';

  @override
  String domainEventsEligible(int eventCount, int aiCount) {
    return '$eventCount eventos · $aiCount aptos para IA ahora';
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
  String get domainTasks => 'Tareas';

  @override
  String get domainWeek => 'Semana';

  @override
  String get domainFinance => 'Dinero';

  @override
  String get domainPantry => 'Despensa';

  @override
  String get domainWardrobe => 'Closet';

  @override
  String get domainCopilot => 'Copilot';

  @override
  String get collectionFinanceRecords => 'Registros financieros';

  @override
  String get collectionJournalEntries => 'Entradas de journal';

  @override
  String get collectionQuickNotes => 'Notas rapidas';

  @override
  String get collectionPrivacySettings => 'Ajustes de privacidad';

  @override
  String get collectionRuntimeConfigCache => 'Cache de runtime config';

  @override
  String get collectionDeviceEncryptionKey =>
      'Clave de cifrado del dispositivo';

  @override
  String get nothingAiEnabled =>
      'Ahora mismo no hay ningun dominio con IA activa';

  @override
  String get gatewayLive => 'Gateway activo';

  @override
  String get gatewayNoConnection => 'Sin conexion';

  @override
  String get gatewayUnavailable => 'IA temporalmente no disponible';

  @override
  String get gatewayLocalFallback => 'Usando fallback local';

  @override
  String get feedbackNone => 'Sin feedback todavia';

  @override
  String get feedbackUseful => 'Util';

  @override
  String get feedbackRejected => 'Rechazado';

  @override
  String get feedbackAccepted => 'Aceptado';

  @override
  String get feedbackCompleted => 'Completado';

  @override
  String get feedbackEdited => 'Editado';

  @override
  String get missionDeliveryAi => 'Con ayuda de IA';

  @override
  String get missionDeliveryFallback => 'Fallback local';

  @override
  String get missionDeliveryLocal => 'Local';

  @override
  String get missionDeliverySummaryAi =>
      'GoLife uso IA para esta mision despues del filtrado local de privacidad.';

  @override
  String get missionDeliverySummaryFallback =>
      'GoLife se quedo en local porque el gateway no estaba disponible o estaba degradado.';

  @override
  String get missionDeliverySummaryLocal =>
      'GoLife mantuvo esta mision local en el dispositivo.';

  @override
  String get actionWrite => 'Escribir';

  @override
  String get actionChat => 'Conversar';

  @override
  String get actionExplain => 'Explicar';

  @override
  String get actionUseful => 'Util';

  @override
  String get actionDoNow => 'Hacer ahora';

  @override
  String get actionNotUseful => 'No util';

  @override
  String get actionAccept => 'Aceptar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionRemove => 'Quitar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionParseCapture => 'Parsear captura';

  @override
  String get actionReparseCapture => 'Volver a parsear';

  @override
  String actionSaveCaptureItems(int count) {
    return 'Guardar $count items';
  }

  @override
  String get statusReady => 'Listo';

  @override
  String get statusBooting => 'Inicializando';

  @override
  String get labelEvidence => 'Evidencia';

  @override
  String get labelDataUsedForMission => 'Datos usados para esta mision';

  @override
  String get labelDataSentToAi => 'Datos enviados a IA';

  @override
  String get labelBlockedFromAi => 'Bloqueado para IA';

  @override
  String get labelAlwaysLocalOnDevice => 'Siempre local en este dispositivo';

  @override
  String get labelEncryptedLocally => 'Cifrado local';

  @override
  String get labelUncertainty => 'Incertidumbre';

  @override
  String get labelTrace => 'Traza';

  @override
  String get fieldDomain => 'Dominio';

  @override
  String get fieldPrivacy => 'Privacidad';

  @override
  String get dashboardDisclosurePending =>
      'GoLife mantiene los datos locales hasta que una mision este lista.';

  @override
  String dashboardMissionCountTitle(int count) {
    return '$count misiones para hoy';
  }

  @override
  String get dashboardMissionIntro =>
      'Home Today convierte el grafo en acciones pequenas: una mision principal, dos de apoyo, evidencia visible y feedback rapido.';

  @override
  String get dashboardLoadingMissions => 'Cargando misiones...';

  @override
  String get dashboardBootstrappingMission =>
      'Inicializando eventos locales, ranking de misiones y traza del gateway.';

  @override
  String dashboardRiskCount(int count) {
    return '$count riesgos';
  }

  @override
  String dashboardConfidencePill(int percent) {
    return '$percent% de confianza';
  }

  @override
  String get dashboardAiDisclosureTitle => 'Disclosure de datos para IA';

  @override
  String dashboardAiDisclosureSummary(
      Object summary, int sentCount, int blockedCount) {
    return '$summary Enviado ahora: $sentCount eventos locales. Bloqueados localmente: $blockedCount.';
  }

  @override
  String get dashboardRisksTitle => 'Riesgos de hoy';

  @override
  String get dashboardNoRisks =>
      'No se detectaron riesgos diarios explicitos en el grafo actual apto para IA.';

  @override
  String get dashboardSupportMissionsTitle => 'Misiones de apoyo';

  @override
  String get dashboardNoSupportMissions =>
      'Las misiones secundarias apareceran cuando el plan diario este disponible.';

  @override
  String get signalCriticalTask => 'Tarea critica';

  @override
  String get signalRecoveryHabit => 'Habito de recuperacion';

  @override
  String signalRecoveryHabitBody(Object cue, Object streak) {
    return 'Disparador: $cue - $streak';
  }

  @override
  String get signalRelevantSpend => 'Gasto relevante';

  @override
  String get signalUseThisFood => 'Usa este alimento';

  @override
  String get dashboardWhyThisToday => 'Por que esta hoy';

  @override
  String dashboardConfidenceWithType(int percent, Object type) {
    return 'Confianza $percent% - $type';
  }

  @override
  String get dashboardNothingSent =>
      'No se envio nada para esta mision. GoLife se quedo en local para este paso.';

  @override
  String get dashboardNothingBlocked =>
      'No hubo items bloqueados para IA especificos de esta mision.';

  @override
  String get dashboardNoAlwaysLocalCollections =>
      'No hay colecciones siempre locales configuradas.';

  @override
  String get dashboardNoEncryptedCollections =>
      'No hay colecciones cifradas configuradas.';

  @override
  String dashboardRiskSeverityLabel(Object severity) {
    return 'riesgo $severity';
  }

  @override
  String get captureTitle => 'Capturar';

  @override
  String get captureIntro =>
      'Escribe una frase. GoLife puede dividirla en varios borradores, dejarte editar dominio y privacidad por item, y guardarlos juntos.';

  @override
  String get captureRouteTitle => 'Ruta';

  @override
  String get captureAutoRoute => 'Auto';

  @override
  String get captureAutoModeBody =>
      'El modo auto intenta dividir y clasificar cada clausula primero.';

  @override
  String captureCurrentDefaultPrivacy(Object domain, Object permission) {
    return 'Privacidad actual por defecto para $domain: $permission';
  }

  @override
  String get captureDraftsToConfirm => 'Borradores para confirmar';

  @override
  String get captureRecentEvents => 'Eventos recientes';

  @override
  String capturePrivacyLabel(Object privacy) {
    return 'Privacidad: $privacy';
  }

  @override
  String captureItemsCaptured(int count) {
    return '$count item(s) capturados.';
  }

  @override
  String get captureEditItemTitle => 'Editar item';

  @override
  String get captureHintAuto =>
      'Ejemplo: compre cafe por 4.50, la lechuga vence manana y debo pagar internet.';

  @override
  String get captureHintTasks =>
      'Ejemplo: enviar recibo del alquiler antes de comer';

  @override
  String get captureHintHabits => 'Ejemplo: camine 15 minutos despues de cenar';

  @override
  String get captureHintWeek =>
      'Ejemplo: el foco del viernes debe quedarse en trabajo admin';

  @override
  String get captureHintFinance => 'Ejemplo: compre cafe y sandwich por 8.50';

  @override
  String get captureHintPantry => 'Ejemplo: la espinaca vence manana';

  @override
  String get captureHintWardrobe =>
      'Ejemplo: estoy pensando en comprar otra chaqueta negra';

  @override
  String get captureHintCopilot => 'Ejemplo: una nota de mision';

  @override
  String get copilotTitle => 'Copilot';

  @override
  String get copilotIntro =>
      'El copilot ahora trabaja sobre un plan diario rankeado: traza visible, tres misiones y fallback local cuando el gateway no esta disponible.';

  @override
  String get copilotBoundariesTitle => 'Limites de reflexion';

  @override
  String get copilotBoundariesBody =>
      'GoLife ayuda con organizacion diaria y reflexion practica. No diagnostica, no da terapia y no reemplaza atencion profesional. Si algo se siente urgente o inseguro, usa soporte real de crisis o medico.';

  @override
  String get copilotTodayPlanTitle => 'Plan de hoy';

  @override
  String get copilotNoPlan => 'Todavia no hay plan de misiones cargado.';

  @override
  String get copilotLatestTraceTitle => 'Ultima traza';

  @override
  String get copilotNoTrace => 'Todavia no hay mision cargada.';
}

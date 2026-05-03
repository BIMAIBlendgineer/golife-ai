import '../../domains/missions/daily_mission.dart';
import '../../domains/missions/mission_feedback.dart';
import '../../features/app_state/golife_controller.dart';
import '../../l10n/app_localizations.dart';
import 'app_locale.dart';
import '../privacy/privacy_models.dart';

extension LocalizedDomainKey on DomainKey {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case DomainKey.habits:
        return l10n.domainHabits;
      case DomainKey.tasks:
        return l10n.domainTasks;
      case DomainKey.week:
        return l10n.domainWeek;
      case DomainKey.finance:
        return l10n.domainFinance;
      case DomainKey.pantry:
        return l10n.domainPantry;
      case DomainKey.wardrobe:
        return l10n.domainWardrobe;
      case DomainKey.copilot:
        return l10n.domainCopilot;
    }
  }
}

extension LocalizedDomainWireName on String {
  String localizedDomainLabel(AppLocalizations l10n) {
    final domain = domainKeyFromWireName(this);
    if (domain == null) {
      return this;
    }
    return domain.localizedLabel(l10n);
  }
}

extension LocalizedDataPermission on DataPermission {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case DataPermission.localOnly:
        return l10n.permissionLocal;
      case DataPermission.syncAllowed:
        return l10n.permissionSync;
      case DataPermission.aiAllowed:
        return l10n.permissionAi;
    }
  }
}

extension LocalizedPermissionStorageKey on String {
  String localizedPermissionLabel(AppLocalizations l10n) {
    for (final permission in DataPermission.values) {
      if (permission.storageKey == this) {
        return permission.localizedLabel(l10n);
      }
    }
    return this;
  }
}

extension LocalizedMissionFeedbackStatus on MissionFeedbackStatus {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case MissionFeedbackStatus.useful:
        return l10n.feedbackUseful;
      case MissionFeedbackStatus.rejected:
        return l10n.feedbackRejected;
      case MissionFeedbackStatus.accepted:
        return l10n.feedbackAccepted;
      case MissionFeedbackStatus.completed:
        return l10n.feedbackCompleted;
      case MissionFeedbackStatus.edited:
        return l10n.feedbackEdited;
    }
  }
}

extension LocalizedGoLifeController on GoLifeController {
  List<String> localizedEncryptedCollectionLabels(AppLocalizations l10n) {
    return <String>[
      'Life events',
      'Daily missions',
      'Daily risks',
      l10n.collectionFinanceRecords,
      'Calendar items',
      l10n.collectionJournalEntries,
      l10n.collectionQuickNotes,
      l10n.collectionOwnedItems,
      l10n.collectionPurchaseProofs,
      l10n.collectionClaimDrafts,
      l10n.collectionEvidenceAttachments,
    ];
  }

  List<String> localizedAlwaysLocalCollectionLabels(AppLocalizations l10n) {
    return <String>[
      l10n.collectionPrivacySettings,
      l10n.collectionJournalEntries,
      l10n.collectionQuickNotes,
      l10n.collectionOwnedItems,
      l10n.collectionPurchaseProofs,
      l10n.collectionClaimDrafts,
      l10n.collectionEvidenceAttachments,
      l10n.collectionRuntimeConfigCache,
      l10n.collectionDeviceEncryptionKey,
    ];
  }

  List<String> localizedAiSendableCollectionLabels(AppLocalizations l10n) {
    final labels = privacySettings.aiAllowedDomains
        .where((domain) => domain != DomainKey.copilot)
        .map((domain) => domain.localizedLabel(l10n))
        .toList(growable: false);
    if (labels.isEmpty) {
      return <String>[l10n.nothingAiEnabled];
    }
    return labels;
  }

  String localizedLatestFeedbackLabel(AppLocalizations l10n) {
    return latestMissionFeedback?.status.localizedLabel(l10n) ??
        l10n.feedbackNone;
  }

  String localizedGatewayStatusLabel(AppLocalizations l10n) {
    final trace = dailyMission?.trace ?? const <String, Object?>{};
    if (trace['remote'] == true) {
      return l10n.gatewayLive;
    }
    final reason = (trace['fallbackReason'] ?? '').toString();
    if (reason == 'no_connection') {
      return l10n.gatewayNoConnection;
    }
    if (reason == 'ai_temporarily_unavailable') {
      return l10n.gatewayUnavailable;
    }
    if (trace['clientFallback'] == true || trace['mock'] == true) {
      return l10n.gatewayLocalFallback;
    }
    return l10n.gatewayLive;
  }

  String localizedMissionDeliveryLabel(
    DailyMission mission,
    AppLocalizations l10n,
  ) {
    final trace = mission.trace;
    if (trace['remote'] == true) {
      return l10n.missionDeliveryAi;
    }
    if (trace['clientFallback'] == true || trace['mock'] == true) {
      return l10n.missionDeliveryFallback;
    }
    return l10n.missionDeliveryLocal;
  }

  String localizedMissionDeliverySummary(
    DailyMission mission,
    AppLocalizations l10n,
  ) {
    final trace = mission.trace;
    if (trace['remote'] == true) {
      return l10n.missionDeliverySummaryAi;
    }
    if (trace['clientFallback'] == true || trace['mock'] == true) {
      return l10n.missionDeliverySummaryFallback;
    }
    return l10n.missionDeliverySummaryLocal;
  }

  String localizedMissionTitle(
    DailyMission mission,
    AppLocalizations l10n,
  ) {
    final content = _localizedMockMissionContent(l10n.localeName, mission.id);
    return content?.title ?? mission.title;
  }

  String localizedMissionBody(
    DailyMission mission,
    AppLocalizations l10n,
  ) {
    final content = _localizedMockMissionContent(l10n.localeName, mission.id);
    return content?.body ?? mission.body;
  }

  List<String> localizedMissionEvidence(
    DailyMission mission,
    AppLocalizations l10n,
  ) {
    final content = _localizedMockMissionContent(l10n.localeName, mission.id);
    return content?.evidence ?? mission.evidence;
  }

  String localizedMissionUncertainty(
    DailyMission mission,
    AppLocalizations l10n,
  ) {
    final content = _localizedMockMissionContent(l10n.localeName, mission.id);
    return content?.uncertainty ?? mission.uncertainty;
  }
}

typedef _MissionContent = ({
  String title,
  String body,
  List<String> evidence,
  String uncertainty,
});

_MissionContent? _localizedMockMissionContent(
  String localeName,
  String missionId,
) {
  switch (missionId) {
    case 'mission-paused':
      return (
        title: _pickLocale(
          localeName,
          en: 'Copilot paused',
          es: 'Copilot en pausa',
          ptBr: 'Copiloto em pausa',
          ja: 'Copilotは一時停止中',
          zhHans: 'Copilot 已暂停',
        ),
        body: _pickLocale(
          localeName,
          en: 'Enable AI on at least one domain to generate daily missions.',
          es: 'Activa IA en al menos un dominio para generar misiones diarias.',
          ptBr:
              'Ative a IA em pelo menos um dominio para gerar missoes diarias.',
          ja: '毎日のミッションを生成するには、少なくとも1つのドメインでAIを有効にしてください。',
          zhHans: '请至少为一个领域启用 AI，才能生成今日任务。',
        ),
        evidence: _pickLocale(
          localeName,
          en: const ['No domain is currently marked as AI-allowed.'],
          es: const [
            'Ahora mismo no hay ningun dominio marcado como apto para IA.'
          ],
          ptBr: const [
            'Nenhum dominio esta marcado como permitido para IA no momento.'
          ],
          ja: const ['現在、AI利用可として設定されたドメインはありません。'],
          zhHans: const ['当前没有任何领域被标记为允许使用 AI。'],
        ),
        uncertainty: _pickLocale(
          localeName,
          en: 'No cross-domain inference was attempted.',
          es: 'No se intento ninguna inferencia entre dominios.',
          ptBr: 'Nenhuma inferencia entre dominios foi tentada.',
          ja: 'ドメイン横断の推論は実行されませんでした。',
          zhHans: '未尝试跨领域推断。',
        ),
      );
    case 'mission-task-habit':
      return (
        title: _pickLocale(
          localeName,
          en: 'Close one task, protect one ritual',
          es: 'Cierra una tarea y protege un ritual',
          ptBr: 'Feche uma tarefa e proteja um ritual',
          ja: '1つのタスクを閉じて、1つの習慣を守る',
          zhHans: '完成一项任务，并守住一个习惯',
        ),
        body: _pickLocale(
          localeName,
          en: 'Finish the shortest critical task first, then log one low-friction habit so the day ends with traction instead of spillover.',
          es: 'Termina primero la tarea critica mas corta y luego registra un habito de baja friccion para que el dia cierre con traccion y no con arrastre.',
          ptBr:
              'Conclua primeiro a tarefa critica mais curta e depois registre um habito de baixa friccao para terminar o dia com tracao, e nao com acumulacao.',
          ja: '最も短い重要タスクを先に終え、その後で負荷の低い習慣を1つ記録して、1日を惰性ではなく前進で締めます。',
          zhHans: '先完成最短的关键任务，再记录一个低摩擦习惯，让今天以推进感而不是拖延感结束。',
        ),
        evidence: _pickLocale(
          localeName,
          en: const [
            'Tasks and habits are both AI-allowed.',
            'The life graph already has events in both domains.',
          ],
          es: const [
            'Tareas y habitos estan permitidos para IA.',
            'El grafo ya tiene eventos en ambos dominios.',
          ],
          ptBr: const [
            'Tarefas e habitos estao permitidos para IA.',
            'O grafo ja tem eventos nos dois dominios.',
          ],
          ja: const [
            'タスクと習慣の両方でAIが許可されています。',
            'ライフグラフには両方のドメインのイベントがあります。',
          ],
          zhHans: const [
            '任务和习惯两个领域都允许使用 AI。',
            '生命图谱中已经有这两个领域的事件。',
          ],
        ),
        uncertainty: _pickLocale(
          localeName,
          en: 'Mock mission based on consented domains, not a real remote call.',
          es: 'Mision simulada basada en dominios consentidos, no en una llamada remota real.',
          ptBr:
              'Missao simulada com base nos dominios consentidos, nao em uma chamada remota real.',
          ja: '同意済みドメインに基づく模擬ミッションであり、実際のリモート呼び出しではありません。',
          zhHans: '这是基于已同意领域的模拟任务，不是真实的远程调用。',
        ),
      );
    case 'mission-task-focus':
      return (
        title: _pickLocale(
          localeName,
          en: 'Reduce friction in one important task',
          es: 'Reduce friccion en una tarea importante',
          ptBr: 'Reduza a friccao em uma tarefa importante',
          ja: '重要なタスク1件の摩擦を減らす',
          zhHans: '降低一项重要任务的阻力',
        ),
        body: _pickLocale(
          localeName,
          en: 'Define the next visible step for one task and finish that block before opening another thread.',
          es: 'Define el siguiente paso visible de una tarea y termina ese bloque antes de abrir otro frente.',
          ptBr:
              'Defina a proxima etapa visivel de uma tarefa e conclua esse bloco antes de abrir outra frente.',
          ja: '1つのタスクの次に見えるステップを定義し、そのブロックを終えてから別の作業を開きます。',
          zhHans: '先定义一项任务的下一步可见动作，并在开启新线程之前完成这一段。',
        ),
        evidence: _pickLocale(
          localeName,
          en: const ['Task activity is available for AI.'],
          es: const ['La actividad de tareas esta disponible para IA.'],
          ptBr: const ['A atividade de tarefas esta disponivel para IA.'],
          ja: const ['タスクの活動データをAIが利用できます。'],
          zhHans: const ['任务活动数据可供 AI 使用。'],
        ),
        uncertainty: _pickLocale(
          localeName,
          en: 'Mock mission with local prioritization only.',
          es: 'Mision simulada con priorizacion solo local.',
          ptBr: 'Missao simulada com priorizacao apenas local.',
          ja: 'ローカル優先度のみを使った模擬ミッションです。',
          zhHans: '这是只使用本地优先级的模拟任务。',
        ),
      );
    case 'mission-habit-recovery':
      return (
        title: _pickLocale(
          localeName,
          en: 'Keep one recovery habit alive',
          es: 'Mantene vivo un habito de recuperacion',
          ptBr: 'Mantenha vivo um habito de recuperacao',
          ja: '回復の習慣を1つ維持する',
          zhHans: '保持一个恢复习惯不断线',
        ),
        body: _pickLocale(
          localeName,
          en: 'Protect a 5 to 10 minute habit so the day does not become pure reaction mode.',
          es: 'Protege un habito de 5 a 10 minutos para que el dia no se convierta en pura reaccion.',
          ptBr:
              'Proteja um habito de 5 a 10 minutos para que o dia nao vire apenas reacao.',
          ja: '5〜10分の習慣を守り、1日が反応だけで終わらないようにします。',
          zhHans: '守住一个 5 到 10 分钟的习惯，别让今天完全变成被动应对。',
        ),
        evidence: _pickLocale(
          localeName,
          en: const ['Habit continuity is visible in the local graph.'],
          es: const ['La continuidad del habito es visible en el grafo local.'],
          ptBr: const ['A continuidade do habito esta visivel no grafo local.'],
          ja: const ['習慣の継続状況がローカルグラフに見えています。'],
          zhHans: const ['本地图谱中可以看到习惯连续性。'],
        ),
        uncertainty: _pickLocale(
          localeName,
          en: 'Mock mission; the final effort still depends on energy.',
          es: 'Mision simulada; el esfuerzo final sigue dependiendo de la energia.',
          ptBr: 'Missao simulada; o esforco final ainda depende da energia.',
          ja: '模擬ミッションです。最終的な実行量はその日のエネルギー次第です。',
          zhHans: '这是模拟任务；最终投入仍取决于你的精力。',
        ),
      );
    case 'mission-finance-pantry':
      return (
        title: _pickLocale(
          localeName,
          en: 'Use what is already paid for',
          es: 'Usa lo que ya esta pagado',
          ptBr: 'Use o que ja foi pago',
          ja: 'すでに支払ったものを使う',
          zhHans: '先用已经买过的东西',
        ),
        body: _pickLocale(
          localeName,
          en: 'Before adding anything to a shopping list, build one meal around an ingredient you already have at home.',
          es: 'Antes de agregar algo a la lista de compra, arma una comida con un ingrediente que ya tengas en casa.',
          ptBr:
              'Antes de adicionar algo a lista de compras, monte uma refeicao com um ingrediente que ja exista em casa.',
          ja: '買い物リストに追加する前に、家にある食材を中心に1食組み立てます。',
          zhHans: '在往购物清单里加东西之前，先用家里已有的食材做一顿饭。',
        ),
        evidence: _pickLocale(
          localeName,
          en: const [
            'Finance and pantry are both AI-allowed.',
            'The mission avoids purchase advice and focuses on using existing items.',
          ],
          es: const [
            'Finanzas y pantry estan permitidos para IA.',
            'La mision evita dar consejo de compra y se centra en usar lo que ya existe.',
          ],
          ptBr: const [
            'Financas e despensa estao permitidos para IA.',
            'A missao evita conselho de compra e foca em usar o que ja existe.',
          ],
          ja: const [
            '家計とパントリーの両方でAIが許可されています。',
            '購入助言は避け、手元にある物の活用に集中しています。',
          ],
          zhHans: const [
            '财务和 pantry 两个领域都允许使用 AI。',
            '该任务避免购买建议，而是聚焦于利用现有物品。',
          ],
        ),
        uncertainty: _pickLocale(
          localeName,
          en: 'Mock mission; pantry availability still needs human confirmation.',
          es: 'Mision simulada; la disponibilidad real en pantry aun necesita confirmacion humana.',
          ptBr:
              'Missao simulada; a disponibilidade real da despensa ainda precisa de confirmacao humana.',
          ja: '模擬ミッションです。実際の在庫有無は本人確認が必要です。',
          zhHans: '这是模拟任务；食材是否真的还有库存仍需人工确认。',
        ),
      );
    case 'mission-finance-pause':
      return (
        title: _pickLocale(
          localeName,
          en: 'Pause one avoidable spend',
          es: 'Pausa un gasto evitable',
          ptBr: 'Pause um gasto evitavel',
          ja: '避けられる支出を1つ止める',
          zhHans: '暂停一笔可以避免的支出',
        ),
        body: _pickLocale(
          localeName,
          en: 'Delay one small non-urgent purchase until you review whether it solves a real need today.',
          es: 'Retrasa una compra pequena y no urgente hasta revisar si realmente resuelve una necesidad hoy.',
          ptBr:
              'Adie uma compra pequena e nao urgente ate revisar se ela realmente resolve uma necessidade hoje.',
          ja: '小さくて緊急ではない購入を1件保留し、今日の本当の必要を満たすか確認します。',
          zhHans: '先延后一笔小额且不紧急的购买，确认它今天是否真的解决了实际需要。',
        ),
        evidence: _pickLocale(
          localeName,
          en: const ['Finance is AI-allowed.'],
          es: const ['Finanzas esta permitido para IA.'],
          ptBr: const ['Financas esta permitido para IA.'],
          ja: const ['家計ドメインでAIが許可されています。'],
          zhHans: const ['财务领域允许使用 AI。'],
        ),
        uncertainty: _pickLocale(
          localeName,
          en: 'Mock reflection; this is not financial advice or a universal rule.',
          es: 'Reflexion simulada; esto no es consejo financiero ni una regla universal.',
          ptBr:
              'Reflexao simulada; isto nao e aconselhamento financeiro nem uma regra universal.',
          ja: '模擬的な振り返りであり、金融助言でも普遍的なルールでもありません。',
          zhHans: '这是模拟反思，不构成财务建议，也不是通用规则。',
        ),
      );
    case 'mission-pantry-rescue':
      return (
        title: _pickLocale(
          localeName,
          en: 'Rescue one ingredient first',
          es: 'Rescata primero un ingrediente',
          ptBr: 'Resgate primeiro um ingrediente',
          ja: 'まず食材を1つ使い切る',
          zhHans: '先救回一个食材',
        ),
        body: _pickLocale(
          localeName,
          en: 'Turn one existing ingredient into a low-effort meal before opening a new buying decision.',
          es: 'Convierte un ingrediente existente en una comida simple antes de abrir una nueva decision de compra.',
          ptBr:
              'Transforme um ingrediente que ja existe em uma refeicao simples antes de abrir uma nova decisao de compra.',
          ja: '新しい購入判断を始める前に、今ある食材を1つ使って負荷の低い食事にします。',
          zhHans: '在开始新的购买决策之前，先把现有食材做成一顿低成本的餐食。',
        ),
        evidence: _pickLocale(
          localeName,
          en: const ['Pantry activity is visible to AI.'],
          es: const ['La actividad de pantry es visible para IA.'],
          ptBr: const ['A atividade da despensa esta visivel para IA.'],
          ja: const ['パントリーの活動がAIに見えています。'],
          zhHans: const ['AI 可以看到 pantry 领域的活动。'],
        ),
        uncertainty: _pickLocale(
          localeName,
          en: 'Mock mission; confirm real stock locally first.',
          es: 'Mision simulada; primero confirma el stock real localmente.',
          ptBr: 'Missao simulada; confirme primeiro o estoque real localmente.',
          ja: '模擬ミッションです。実在庫はまずローカルで確認してください。',
          zhHans: '这是模拟任务；请先在本地确认真实库存。',
        ),
      );
    case 'mission-wardrobe':
      return (
        title: _pickLocale(
          localeName,
          en: 'Compare before buying',
          es: 'Compara antes de comprar',
          ptBr: 'Compare antes de comprar',
          ja: '買う前に比較する',
          zhHans: '购买前先比较',
        ),
        body: _pickLocale(
          localeName,
          en: 'Review one outfit you already own before acting on any clothing purchase intention today.',
          es: 'Revisa una combinacion que ya tengas antes de actuar sobre cualquier intencion de compra de ropa hoy.',
          ptBr:
              'Revise uma combinacao que voce ja possui antes de agir sobre qualquer intencao de compra de roupa hoje.',
          ja: '今日服を買う前に、すでに持っているコーデを1つ見直します。',
          zhHans: '今天在为服装购买做决定之前，先回看一套你已经拥有的搭配。',
        ),
        evidence: _pickLocale(
          localeName,
          en: const [
            'Wardrobe is AI-allowed.',
            'The mission keeps the final decision with the user.',
          ],
          es: const [
            'Closet esta permitido para IA.',
            'La decision final sigue quedando en la persona.',
          ],
          ptBr: const [
            'Guarda-roupa esta permitido para IA.',
            'A decisao final continua com a pessoa.',
          ],
          ja: const [
            'ワードローブでAIが許可されています。',
            '最終判断は利用者本人に残されています。',
          ],
          zhHans: const [
            '衣橱领域允许使用 AI。',
            '最终决定仍然由用户自己做出。',
          ],
        ),
        uncertainty: _pickLocale(
          localeName,
          en: 'Mock mission; visual comparison still needs the person.',
          es: 'Mision simulada; la comparacion visual sigue necesitando a la persona.',
          ptBr: 'Missao simulada; a comparacao visual ainda depende da pessoa.',
          ja: '模擬ミッションです。視覚的な比較は本人が行う必要があります。',
          zhHans: '这是模拟任务；视觉比较仍然需要你本人完成。',
        ),
      );
    case 'mission-wardrobe-delay':
      return (
        title: _pickLocale(
          localeName,
          en: 'Delay the decision 24 hours',
          es: 'Retrasa la decision 24 horas',
          ptBr: 'Adie a decisao por 24 horas',
          ja: '判断を24時間遅らせる',
          zhHans: '将决定延后 24 小时',
        ),
        body: _pickLocale(
          localeName,
          en: 'If the purchase is not solving an immediate gap, wait one day and compare it again with what you already own.',
          es: 'Si la compra no resuelve una necesidad inmediata, espera un dia y comparala otra vez con lo que ya tienes.',
          ptBr:
              'Se a compra nao resolve uma necessidade imediata, espere um dia e compare novamente com o que voce ja possui.',
          ja: 'その購入が今すぐの不足を埋めないなら、1日待ってから手持ちともう一度比べます。',
          zhHans: '如果这次购买并不能解决眼前缺口，先等一天，再和你已有的物品重新比较。',
        ),
        evidence: _pickLocale(
          localeName,
          en: const ['Wardrobe intent can benefit from a pause.'],
          es: const [
            'La intencion de compra en closet puede beneficiarse de una pausa.'
          ],
          ptBr: const [
            'A intencao de compra no guarda-roupa pode se beneficiar de uma pausa.'
          ],
          ja: const ['ワードローブ関連の購買意図は一度止めると判断しやすくなります。'],
          zhHans: const ['衣橱相关的购买意图往往会因短暂停顿而更清晰。'],
        ),
        uncertainty: _pickLocale(
          localeName,
          en: 'Mock mission; the decision remains fully manual.',
          es: 'Mision simulada; la decision sigue siendo completamente manual.',
          ptBr: 'Missao simulada; a decisao continua totalmente manual.',
          ja: '模擬ミッションです。判断は完全に本人の手元にあります。',
          zhHans: '这是模拟任务；决定权仍完全在你手里。',
        ),
      );
    case 'mission-wardrobe-outfit':
      return (
        title: _pickLocale(
          localeName,
          en: 'Try one existing combination first',
          es: 'Prueba primero una combinacion existente',
          ptBr: 'Teste primeiro uma combinacao existente',
          ja: '手持ちの組み合わせを先に試す',
          zhHans: '先试一套现有搭配',
        ),
        body: _pickLocale(
          localeName,
          en: 'Build one outfit with a piece you already have before creating a new shopping loop.',
          es: 'Arma un outfit con una prenda que ya tienes antes de abrir un nuevo ciclo de compra.',
          ptBr:
              'Monte um look com uma peca que voce ja possui antes de abrir um novo ciclo de compra.',
          ja: '新しい買い物ループを始める前に、手持ちの服で1つコーデを作ってみます。',
          zhHans: '在开启新的购物循环之前，先用已有单品搭一套穿搭。',
        ),
        evidence: _pickLocale(
          localeName,
          en: const [
            'Closet context is available without needing a new purchase.'
          ],
          es: const [
            'El contexto del closet esta disponible sin necesidad de una compra nueva.'
          ],
          ptBr: const [
            'O contexto do guarda-roupa esta disponivel sem precisar de uma nova compra.'
          ],
          ja: const ['新しい購入をしなくてもクローゼット文脈は利用できます。'],
          zhHans: const ['无需新增购买，也能利用现有衣橱上下文。'],
        ),
        uncertainty: _pickLocale(
          localeName,
          en: 'Mock mission; still requires a visual check.',
          es: 'Mision simulada; aun requiere una comprobacion visual.',
          ptBr: 'Missao simulada; ainda requer uma verificacao visual.',
          ja: '模擬ミッションです。最終的には見た目の確認が必要です。',
          zhHans: '这是模拟任务；最终仍需要你做视觉确认。',
        ),
      );
    case 'mission-generic':
      return (
        title: _pickLocale(
          localeName,
          en: 'Pick one visible win',
          es: 'Elige una victoria visible',
          ptBr: 'Escolha uma vitoria visivel',
          ja: '見える前進を1つ選ぶ',
          zhHans: '选一个看得见的进展',
        ),
        body: _pickLocale(
          localeName,
          en: 'Choose the smallest action that clearly reduces friction in one AI-allowed area and review it once it is done.',
          es: 'Elige la accion mas pequena que reduzca claramente la friccion en un area con IA permitida y revisala al terminar.',
          ptBr:
              'Escolha a menor acao que reduza claramente a friccao em uma area com IA permitida e revise depois de concluir.',
          ja: 'AIが許可された領域で摩擦を確実に減らす最小の行動を1つ選び、終わったら見直します。',
          zhHans: '在允许使用 AI 的领域里，选一个能明确降低阻力的最小动作，完成后再回看。',
        ),
        evidence: _pickLocale(
          localeName,
          en: const ['At least one domain allows AI.'],
          es: const ['Al menos un dominio permite IA.'],
          ptBr: const ['Pelo menos um dominio permite IA.'],
          ja: const ['少なくとも1つのドメインでAIが許可されています。'],
          zhHans: const ['至少有一个领域允许使用 AI。'],
        ),
        uncertainty: _pickLocale(
          localeName,
          en: 'Mock mission with limited cross-domain context.',
          es: 'Mision simulada con contexto entre dominios limitado.',
          ptBr: 'Missao simulada com contexto entre dominios limitado.',
          ja: 'ドメイン横断の文脈が限られた模擬ミッションです。',
          zhHans: '这是跨领域上下文有限的模拟任务。',
        ),
      );
    case 'mission-generic-risk':
      return (
        title: _pickLocale(
          localeName,
          en: 'Prevent one small risk from rolling into tomorrow',
          es: 'Evita que un pequeno riesgo llegue a manana',
          ptBr: 'Evite que um pequeno risco chegue a amanha',
          ja: '小さなリスクを明日に持ち越さない',
          zhHans: '别让一个小风险滚到明天',
        ),
        body: _pickLocale(
          localeName,
          en: 'Identify one small friction point and take the minimum action that stops it from carrying over.',
          es: 'Identifica un pequeno punto de friccion y toma la accion minima que impida que se arrastre.',
          ptBr:
              'Identifique um pequeno ponto de friccao e tome a acao minima para impedir que ele siga adiante.',
          ja: '小さな摩擦点を1つ特定し、持ち越しを防ぐ最小の行動を取ります。',
          zhHans: '识别一个小摩擦点，并采取最小动作阻止它继续拖延下去。',
        ),
        evidence: _pickLocale(
          localeName,
          en: const [
            'The graph has enough local context for a small preventive action.',
          ],
          es: const [
            'El grafo tiene suficiente contexto local para una accion preventiva pequena.',
          ],
          ptBr: const [
            'O grafo tem contexto local suficiente para uma pequena acao preventiva.',
          ],
          ja: const [
            '小さな予防行動を取るには十分なローカル文脈があります。',
          ],
          zhHans: const [
            '图谱具备足够的本地上下文，可以支持一个小的预防动作。',
          ],
        ),
        uncertainty: _pickLocale(
          localeName,
          en: 'Mock mission with partial local context.',
          es: 'Mision simulada con contexto local parcial.',
          ptBr: 'Missao simulada com contexto local parcial.',
          ja: 'ローカル文脈が部分的な模擬ミッションです。',
          zhHans: '这是仅有部分本地上下文的模拟任务。',
        ),
      );
    case 'mission-generic-close':
      return (
        title: _pickLocale(
          localeName,
          en: 'Leave one clear closing signal',
          es: 'Deja una senal clara de cierre',
          ptBr: 'Deixe um sinal claro de fechamento',
          ja: '明確な締めのサインを1つ残す',
          zhHans: '留下一条清晰的收尾信号',
        ),
        body: _pickLocale(
          localeName,
          en: 'Finish one small closing action so tomorrow does not start with the same open loop.',
          es: 'Termina una pequena accion de cierre para que manana no empiece con el mismo bucle abierto.',
          ptBr:
              'Conclua uma pequena acao de fechamento para que amanha nao comece com o mesmo ciclo em aberto.',
          ja: '小さな締めの行動を1つ終え、明日が同じ未完了ループから始まらないようにします。',
          zhHans: '完成一个小的收尾动作，避免明天从同一个未闭环开始。',
        ),
        evidence: _pickLocale(
          localeName,
          en: const ['A small closure often reduces next-day friction.'],
          es: const [
            'Un pequeno cierre suele reducir la friccion del dia siguiente.'
          ],
          ptBr: const [
            'Um pequeno fechamento costuma reduzir a friccao do dia seguinte.'
          ],
          ja: const ['小さな締めは翌日の摩擦を減らすことがよくあります。'],
          zhHans: const ['一个小的收尾动作往往能减少次日的阻力。'],
        ),
        uncertainty: _pickLocale(
          localeName,
          en: 'Mock mission; the exact action still depends on the day.',
          es: 'Mision simulada; la accion exacta sigue dependiendo del dia.',
          ptBr: 'Missao simulada; a acao exata ainda depende do dia.',
          ja: '模擬ミッションです。具体的な行動はその日の状況に依存します。',
          zhHans: '这是模拟任务；具体动作仍取决于当天情况。',
        ),
      );
    default:
      return null;
  }
}

T _pickLocale<T>(
  String localeName, {
  required T en,
  required T es,
  required T ptBr,
  required T ja,
  required T zhHans,
}) {
  switch (normalizeLocaleTag(localeName)) {
    case 'es':
      return es;
    case 'pt-BR':
      return ptBr;
    case 'ja':
      return ja;
    case 'zh-Hans':
      return zhHans;
    default:
      return en;
  }
}

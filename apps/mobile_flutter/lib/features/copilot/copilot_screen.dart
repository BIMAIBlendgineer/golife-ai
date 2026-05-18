import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/app_localized_values.dart';
import '../../domains/mindflow/decision_card.dart';
import '../../domains/missions/daily_mission.dart';
import '../../domains/shopping/shopping_need.dart';
import '../../l10n/app_localizations.dart';
import '../app_state/golife_controller.dart';
import '../shared/premium_ui.dart';

class CopilotScreen extends StatefulWidget {
  const CopilotScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  State<CopilotScreen> createState() => _CopilotScreenState();
}

class _CopilotScreenState extends State<CopilotScreen> {
  late final TextEditingController _promptController;
  String _activePrompt = '';

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = widget.controller;
    final response = _buildResponse(controller, l10n, _activePrompt);

    return GoLifeScreen(
      title: _coachTitle(l10n),
      subtitle: _coachSubtitle(l10n),
      badge: GoLifeStatusPill(
        label: _usingAllowedDataLabel(l10n),
        icon: Icons.lock_outline_rounded,
        accent: GoLifeAccent.blue,
      ),
      children: [
        if (controller.gatewayStatusMessage != null) ...[
          GoLifeCard(
            accent: GoLifeAccent.amber,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_moon_outlined,
                  color: GoLifePalette.amber,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.gatewayStatusMessage!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        GoLifeCard(
          accent: GoLifeAccent.violet,
          filled: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _promptIntroTitle(l10n),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _promptIntroBody(l10n),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GoLifePalette.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PromptChip(
                    label: _promptWhyMission(l10n),
                    onTap: () => _selectPrompt(_promptWhyMission(l10n)),
                  ),
                  _PromptChip(
                    label: _promptAdjustTired(l10n),
                    onTap: () => _selectPrompt(_promptAdjustTired(l10n)),
                  ),
                  _PromptChip(
                    label: _promptDontBuy(l10n),
                    onTap: () => _selectPrompt(_promptDontBuy(l10n)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _promptController,
                onSubmitted: _selectPrompt,
                decoration: InputDecoration(
                  hintText: _inputHint(l10n),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        _selectPrompt(_promptController.text.trim()),
                    icon: const Icon(Icons.arrow_upward_rounded),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GoLifeSectionTitle(
          title: _privacyContextTitle(l10n),
          subtitle: _privacyContextBody(l10n),
        ),
        const SizedBox(height: 12),
        GoLifeCard(
          accent: GoLifeAccent.blue,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final domain in controller.privacySettings.aiAllowedDomains)
                GoLifeStatusPill(
                  label: domain.localizedLabel(l10n),
                  accent: GoLifeAccent.emerald,
                ),
              if (controller.privacySettings.aiAllowedDomains.isEmpty)
                Text(
                  l10n.nothingAiEnabled,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (response == null)
          GoLifeEmptyState(
            title: _coachEmptyTitle(l10n),
            body: _coachEmptyBody(l10n),
            icon: Icons.auto_awesome_motion_rounded,
          )
        else
          _CoachResponseCard(
            response: response,
            onPrimaryAction: () async {
              await _runAction(response.primaryAction);
            },
            onSecondaryAction: () async {
              await _runAction(response.secondaryAction);
            },
          ),
      ],
    );
  }

  void _selectPrompt(String prompt) {
    if (prompt.trim().isEmpty) {
      return;
    }
    setState(() {
      _activePrompt = prompt.trim();
      _promptController.text = prompt.trim();
    });
  }

  Future<void> _runAction(_CoachAction action) async {
    final controller = widget.controller;
    switch (action) {
      case _CoachAction.doMission:
        final mission = controller.dailyMission;
        if (mission != null) {
          await controller.completeMissionAction(mission);
        }
        return;
      case _CoachAction.rejectMission:
        final mission = controller.dailyMission;
        if (mission != null) {
          await controller.rejectMission(mission);
        }
        return;
      case _CoachAction.acceptDecision:
        final card = controller.primaryDecisionCard;
        if (card != null) {
          await controller.acceptDecisionCard(card.id);
        }
        return;
      case _CoachAction.postponeDecision:
        final card = controller.primaryDecisionCard;
        if (card != null) {
          await controller.postponeDecisionCard(card.id);
        }
        return;
      case _CoachAction.openCapture:
        if (mounted) {
          context.go('/capture');
        }
        return;
      case _CoachAction.openShopping:
        if (mounted) {
          context.go('/shopping');
        }
        return;
      case _CoachAction.openToday:
        if (mounted) {
          context.go('/dashboard');
        }
        return;
    }
  }
}

class _CoachResponseCard extends StatelessWidget {
  const _CoachResponseCard({
    required this.response,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
  });

  final _CoachResponse response;
  final Future<void> Function() onPrimaryAction;
  final Future<void> Function() onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GoLifeCard(
      accent: response.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GoLifeStatusPill(
            label: response.heading,
            icon: Icons.auto_awesome_rounded,
            accent: response.accent,
          ),
          const SizedBox(height: 14),
          Text(
            response.recommendation,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          if (response.evidence.isNotEmpty) ...[
            Text(
              l10n.labelEvidence,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final item in response.evidence)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '- $item',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
          ],
          const SizedBox(height: 12),
          Text(
            response.uncertainty,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: GoLifePalette.textMuted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  await onPrimaryAction();
                },
                icon: Icon(response.primaryIcon),
                label: Text(response.primaryActionLabel),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await onSecondaryAction();
                },
                icon: Icon(response.secondaryIcon),
                label: Text(response.secondaryActionLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}

class _CoachResponse {
  const _CoachResponse({
    required this.heading,
    required this.recommendation,
    required this.evidence,
    required this.uncertainty,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
    required this.primaryIcon,
    required this.secondaryIcon,
    required this.primaryAction,
    required this.secondaryAction,
    required this.accent,
  });

  final String heading;
  final String recommendation;
  final List<String> evidence;
  final String uncertainty;
  final String primaryActionLabel;
  final String secondaryActionLabel;
  final IconData primaryIcon;
  final IconData secondaryIcon;
  final _CoachAction primaryAction;
  final _CoachAction secondaryAction;
  final GoLifeAccent accent;
}

enum _CoachAction {
  doMission,
  rejectMission,
  acceptDecision,
  postponeDecision,
  openCapture,
  openShopping,
  openToday,
}

_CoachResponse? _buildResponse(
  GoLifeController controller,
  AppLocalizations l10n,
  String prompt,
) {
  if (prompt.trim().isEmpty) {
    return null;
  }

  final normalized = prompt.toLowerCase();
  if (normalized.contains('buy') ||
      normalized.contains('compr') ||
      normalized.contains('shop')) {
    final ShoppingNeed? need = controller.activeShoppingNeeds.isEmpty
        ? null
        : controller.activeShoppingNeeds.first;
    return _shoppingResponse(controller, l10n, need);
  }

  if (normalized.contains('tired') ||
      normalized.contains('cans') ||
      normalized.contains('adjust') ||
      normalized.contains('ajust')) {
    return _decisionResponse(controller, l10n, controller.primaryDecisionCard);
  }

  return _missionResponse(controller, l10n, controller.dailyMission);
}

_CoachResponse _missionResponse(
  GoLifeController controller,
  AppLocalizations l10n,
  DailyMission? mission,
) {
  if (mission == null) {
    return _CoachResponse(
      heading: _coachFallbackHeading(l10n),
      recommendation: _coachNoMission(l10n),
      evidence: const <String>[],
      uncertainty: _coachNoMissionUncertainty(l10n),
      primaryActionLabel: l10n.navCapture,
      secondaryActionLabel: l10n.labelToday,
      primaryIcon: Icons.edit_note_rounded,
      secondaryIcon: Icons.today_rounded,
      primaryAction: _CoachAction.openCapture,
      secondaryAction: _CoachAction.openToday,
      accent: GoLifeAccent.amber,
    );
  }
  return _CoachResponse(
    heading: _promptWhyMission(l10n),
    recommendation: controller.localizedMissionBody(mission, l10n),
    evidence: controller
        .localizedMissionEvidence(mission, l10n)
        .take(3)
        .toList(),
    uncertainty: mission.uncertainty,
    primaryActionLabel: l10n.actionDoNow,
    secondaryActionLabel: l10n.actionNotUseful,
    primaryIcon: Icons.check_circle_outline,
    secondaryIcon: Icons.thumb_down_alt_outlined,
    primaryAction: _CoachAction.doMission,
    secondaryAction: _CoachAction.rejectMission,
    accent: GoLifeAccent.violet,
  );
}

_CoachResponse _decisionResponse(
  GoLifeController controller,
  AppLocalizations l10n,
  DecisionCard? card,
) {
  if (card == null) {
    return _missionResponse(controller, l10n, controller.dailyMission);
  }
  return _CoachResponse(
    heading: _promptAdjustTired(l10n),
    recommendation: card.recommendedAction,
    evidence: card.evidence.take(3).toList(growable: false),
    uncertainty: card.uncertainty,
    primaryActionLabel: l10n.actionAccept,
    secondaryActionLabel: _postponeLabel(l10n),
    primaryIcon: Icons.thumb_up_alt_outlined,
    secondaryIcon: Icons.schedule_outlined,
    primaryAction: _CoachAction.acceptDecision,
    secondaryAction: _CoachAction.postponeDecision,
    accent: GoLifeAccent.blue,
  );
}

_CoachResponse _shoppingResponse(
  GoLifeController controller,
  AppLocalizations l10n,
  ShoppingNeed? need,
) {
  if (need == null) {
    return _missionResponse(controller, l10n, controller.dailyMission);
  }
  final evidence = controller.productEvidenceForTitle(need.title);
  return _CoachResponse(
    heading: _promptDontBuy(l10n),
    recommendation: need.title,
    evidence: <String>[
      _shoppingNeedSummary(
        l10n,
        need.sourceDomain.localizedDomainLabel(l10n),
        (need.urgencyScore * 100).round(),
      ),
      if (evidence != null) evidence.disclaimer,
    ],
    uncertainty: evidence?.reviewSummary ?? _shoppingUncertainty(l10n),
    primaryActionLabel: _openShoppingLabel(l10n),
    secondaryActionLabel: l10n.labelToday,
    primaryIcon: Icons.shopping_bag_outlined,
    secondaryIcon: Icons.today_rounded,
    primaryAction: _CoachAction.openShopping,
    secondaryAction: _CoachAction.openToday,
    accent: GoLifeAccent.amber,
  );
}

String _coachTitle(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Coach',
  es: 'Coach',
  ptBr: 'Coach',
  ptPt: 'Coach',
  fr: 'Coach',
  it: 'Coach',
  de: 'Coach',
  ja: 'Coach',
  zhHans: 'Coach',
  zhHant: 'Coach',
);

String _coachSubtitle(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Ask about your day.',
  es: 'Pregunta sobre tu dia.',
  ptBr: 'Pergunte sobre o seu dia.',
  ptPt: 'Pergunta sobre o teu dia.',
  fr: 'Pose une question sur ta journee.',
  it: 'Chiedi del tuo giorno.',
  de: 'Frage nach deinem Tag.',
  ja: 'Ask about your day.',
  zhHans: 'Ask about your day.',
  zhHant: 'Ask about your day.',
);

String _usingAllowedDataLabel(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Using allowed data',
  es: 'Usando datos permitidos',
  ptBr: 'Usando dados permitidos',
  ptPt: 'A usar dados permitidos',
  fr: 'Utilise les donnees autorisees',
  it: 'Usando dati consentiti',
  de: 'Verwendet erlaubte Daten',
  ja: 'Using allowed data',
  zhHans: 'Using allowed data',
  zhHant: 'Using allowed data',
);

String _promptIntroTitle(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Explain, adjust, or slow a decision down.',
  es: 'Explica, ajusta o frena una decision.',
  ptBr: 'Explique, ajuste ou desacelere uma decisao.',
  ptPt: 'Explica, ajusta ou abranda uma decisao.',
  fr: 'Explique, ajuste ou ralentis une decision.',
  it: 'Spiega, regola o rallenta una decisione.',
  de: 'Erklaere, passe an oder verlangsame eine Entscheidung.',
  ja: 'Explain, adjust, or slow a decision down.',
  zhHans: 'Explain, adjust, or slow a decision down.',
  zhHant: 'Explain, adjust, or slow a decision down.',
);

String _promptIntroBody(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Coach stays contextual. It reads the mission plan, the allowed memory, and the current fallback state before answering.',
  es: 'Coach se mantiene contextual. Lee el plan de misiones, la memoria permitida y el estado de fallback antes de responder.',
  ptBr:
      'O Coach permanece contextual. Ele le o plano de missoes, a memoria permitida e o estado de fallback antes de responder.',
  ptPt:
      'O Coach mantem-se contextual. Le o plano de missoes, a memoria permitida e o estado de fallback antes de responder.',
  fr: 'Coach reste contextuel. Il lit le plan de mission, la memoire autorisee et l etat de repli avant de repondre.',
  it: 'Coach resta contestuale. Legge il piano missioni, la memoria consentita e lo stato di fallback prima di rispondere.',
  de: 'Coach bleibt kontextbezogen. Er liest Missionsplan, erlaubte Erinnerung und Fallback-Status vor der Antwort.',
  ja: 'Coach stays contextual. It reads the mission plan, the allowed memory, and the current fallback state before answering.',
  zhHans:
      'Coach stays contextual. It reads the mission plan, the allowed memory, and the current fallback state before answering.',
  zhHant:
      'Coach stays contextual. It reads the mission plan, the allowed memory, and the current fallback state before answering.',
);

String _promptWhyMission(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Why this mission?',
  es: 'Por que esta mision?',
  ptBr: 'Por que esta missao?',
  ptPt: 'Porque esta missao?',
  fr: 'Pourquoi cette mission ?',
  it: 'Perche questa missione?',
  de: 'Warum diese Mission?',
  ja: 'Why this mission?',
  zhHans: 'Why this mission?',
  zhHant: 'Why this mission?',
);

String _promptAdjustTired(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'I am tired, adjust.',
  es: 'Estoy cansado, ajusta.',
  ptBr: 'Estou cansado, ajuste.',
  ptPt: 'Estou cansado, ajusta.',
  fr: 'Je suis fatigue, ajuste.',
  it: 'Sono stanco, adatta.',
  de: 'Ich bin muede, passe an.',
  ja: 'I am tired, adjust.',
  zhHans: 'I am tired, adjust.',
  zhHant: 'I am tired, adjust.',
);

String _promptDontBuy(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'What should I not buy today?',
  es: 'Que no deberia comprar hoy?',
  ptBr: 'O que eu nao deveria comprar hoje?',
  ptPt: 'O que nao devo comprar hoje?',
  fr: 'Que ne devrais-je pas acheter aujourd hui ?',
  it: 'Cosa non dovrei comprare oggi?',
  de: 'Was sollte ich heute nicht kaufen?',
  ja: 'What should I not buy today?',
  zhHans: 'What should I not buy today?',
  zhHant: 'What should I not buy today?',
);

String _inputHint(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Type a short question...',
  es: 'Escribe una pregunta corta...',
  ptBr: 'Escreva uma pergunta curta...',
  ptPt: 'Escreve uma pergunta curta...',
  fr: 'Ecris une question courte...',
  it: 'Scrivi una domanda breve...',
  de: 'Schreibe eine kurze Frage...',
  ja: 'Type a short question...',
  zhHans: 'Type a short question...',
  zhHant: 'Type a short question...',
);

String _privacyContextTitle(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Privacy context',
  es: 'Contexto de privacidad',
  ptBr: 'Contexto de privacidade',
  ptPt: 'Contexto de privacidade',
  fr: 'Contexte de confidentialite',
  it: 'Contesto privacy',
  de: 'Datenschutzkontext',
  ja: 'Privacy context',
  zhHans: 'Privacy context',
  zhHant: 'Privacy context',
);

String _privacyContextBody(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Coach only uses the domains already allowed for AI or local explanation.',
  es: 'Coach solo usa los dominios ya permitidos para IA o explicacion local.',
  ptBr:
      'O Coach usa apenas os dominios ja permitidos para IA ou explicacao local.',
  ptPt:
      'O Coach usa apenas os dominios ja permitidos para IA ou explicacao local.',
  fr: 'Coach utilise uniquement les domaines deja autorises pour l IA ou l explication locale.',
  it: 'Coach usa solo i domini gia consentiti per IA o spiegazione locale.',
  de: 'Coach nutzt nur bereits erlaubte Bereiche fuer KI oder lokale Erklaerung.',
  ja: 'Coach only uses the domains already allowed for AI or local explanation.',
  zhHans:
      'Coach only uses the domains already allowed for AI or local explanation.',
  zhHant:
      'Coach only uses the domains already allowed for AI or local explanation.',
);

String _coachEmptyTitle(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Choose a prompt',
  es: 'Elige un prompt',
  ptBr: 'Escolha um prompt',
  ptPt: 'Escolhe um prompt',
  fr: 'Choisis un prompt',
  it: 'Scegli un prompt',
  de: 'Waehle einen Prompt',
  ja: 'Choose a prompt',
  zhHans: 'Choose a prompt',
  zhHant: 'Choose a prompt',
);

String _coachEmptyBody(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Start with the mission, the load, or the shopping tension you want explained.',
  es: 'Empieza por la mision, la carga o la tension de compra que quieres entender.',
  ptBr:
      'Comece pela missao, pela carga ou pela tensao de compra que voce quer entender.',
  ptPt:
      'Comeca pela missao, pela carga ou pela tensao de compra que queres perceber.',
  fr: 'Commence par la mission, la charge ou la tension d achat que tu veux comprendre.',
  it: 'Inizia dalla missione, dal carico o dalla tensione di acquisto che vuoi capire.',
  de: 'Starte mit Mission, Belastung oder Kaufspannung, die du erklaert haben willst.',
  ja: 'Start with the mission, the load, or the shopping tension you want explained.',
  zhHans:
      'Start with the mission, the load, or the shopping tension you want explained.',
  zhHant:
      'Start with the mission, the load, or the shopping tension you want explained.',
);

String _coachFallbackHeading(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Local mode',
  es: 'Modo local',
  ptBr: 'Modo local',
  ptPt: 'Modo local',
  fr: 'Mode local',
  it: 'Modalita locale',
  de: 'Lokaler Modus',
  ja: 'Local mode',
  zhHans: 'Local mode',
  zhHant: 'Local mode',
);

String _coachNoMission(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Capture something first so Coach has context.',
  es: 'Captura algo primero para que Coach tenga contexto.',
  ptBr: 'Capture algo primeiro para que o Coach tenha contexto.',
  ptPt: 'Captura algo primeiro para que o Coach tenha contexto.',
  fr: 'Capture quelque chose d abord pour donner du contexte a Coach.',
  it: 'Cattura qualcosa prima cosi Coach avra contesto.',
  de: 'Erfasse zuerst etwas, damit Coach Kontext hat.',
  ja: 'Capture something first so Coach has context.',
  zhHans: 'Capture something first so Coach has context.',
  zhHant: 'Capture something first so Coach has context.',
);

String _coachNoMissionUncertainty(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'There is not enough day context yet.',
  es: 'Todavia no hay suficiente contexto del dia.',
  ptBr: 'Ainda nao ha contexto suficiente do dia.',
  ptPt: 'Ainda nao ha contexto suficiente do dia.',
  fr: 'Il n y a pas encore assez de contexte sur la journee.',
  it: 'Non c e ancora abbastanza contesto sulla giornata.',
  de: 'Es gibt noch nicht genug Tageskontext.',
  ja: 'There is not enough day context yet.',
  zhHans: 'There is not enough day context yet.',
  zhHant: 'There is not enough day context yet.',
);

String _shoppingUncertainty(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Evidence is still partial. Review before treating it as a firm recommendation.',
  es: 'La evidencia sigue siendo parcial. Revisala antes de tomarla como recomendacion firme.',
  ptBr:
      'A evidencia ainda e parcial. Revise antes de tratá-la como recomendacao firme.',
  ptPt:
      'A evidencia continua parcial. Revê-a antes de a tratar como recomendacao firme.',
  fr: 'Les preuves restent partielles. Verifie avant de la prendre comme recommandation ferme.',
  it: 'L evidenza e ancora parziale. Verificala prima di prenderla come raccomandazione definitiva.',
  de: 'Die Evidenz ist noch unvollstaendig. Pruefe sie, bevor du sie als feste Empfehlung nimmst.',
  ja: 'Evidence is still partial. Review before treating it as a firm recommendation.',
  zhHans:
      'Evidence is still partial. Review before treating it as a firm recommendation.',
  zhHant:
      'Evidence is still partial. Review before treating it as a firm recommendation.',
);

String _shoppingNeedSummary(
  AppLocalizations l10n,
  String domainLabel,
  int urgencyPercent,
) => pickLocalizedValue(
  l10n.localeName,
  en: '$domainLabel - urgency $urgencyPercent%',
  es: '$domainLabel - urgencia $urgencyPercent%',
  ptBr: '$domainLabel - urgencia $urgencyPercent%',
  ptPt: '$domainLabel - urgencia $urgencyPercent%',
  fr: '$domainLabel - urgence $urgencyPercent%',
  it: '$domainLabel - urgenza $urgencyPercent%',
  de: '$domainLabel - Dringlichkeit $urgencyPercent%',
  ja: '$domainLabel - urgency $urgencyPercent%',
  zhHans: '$domainLabel - urgency $urgencyPercent%',
  zhHant: '$domainLabel - urgency $urgencyPercent%',
);

String _openShoppingLabel(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Open shopping',
  es: 'Abrir shopping',
  ptBr: 'Abrir shopping',
  ptPt: 'Abrir shopping',
  fr: 'Ouvrir les achats',
  it: 'Apri shopping',
  de: 'Shopping oeffnen',
  ja: 'Open shopping',
  zhHans: 'Open shopping',
  zhHant: 'Open shopping',
);

String _postponeLabel(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Postpone',
  es: 'Posponer',
  ptBr: 'Adiar',
  ptPt: 'Adiar',
  fr: 'Reporter',
  it: 'Posticipa',
  de: 'Verschieben',
  ja: 'Postpone',
  zhHans: 'Postpone',
  zhHant: 'Postpone',
);

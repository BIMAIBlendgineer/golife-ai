import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/app_localized_values.dart';
import '../../domains/mindflow/decision_card.dart';
import '../../domains/shopping/product_evidence_card.dart';
import '../../domains/shopping/shopping_need.dart';
import '../../l10n/app_localizations.dart';
import '../app_state/golife_controller.dart';
import '../shared/premium_ui.dart';

enum _DecisionTab { active, completed, rejected }

enum _ShoppingTab { needs, evidence, context }

class DecisionsScreen extends StatefulWidget {
  const DecisionsScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  State<DecisionsScreen> createState() => _DecisionsScreenState();
}

class _DecisionsScreenState extends State<DecisionsScreen> {
  _DecisionTab _tab = _DecisionTab.active;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = widget.controller;
    final cards = _cardsForTab(controller);
    final fallbackActive =
        controller.primaryDecisionCard?.trace['clientFallback'] == true ||
        controller.primaryDecisionCard?.trace['mock'] == true;

    return GoLifeScreen(
      title: _decisionsLabel(l10n),
      subtitle: _decisionsIntro(l10n),
      badge: GoLifeStatusPill(
        label: fallbackActive
            ? controller.localizedGatewayStatusLabel(l10n)
            : _tradeoffsBadge(l10n),
        icon: fallbackActive
            ? Icons.shield_moon_outlined
            : Icons.balance_rounded,
        accent: fallbackActive ? GoLifeAccent.amber : GoLifeAccent.blue,
      ),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _TabChip(
              label: _decisionTabActive(l10n),
              selected: _tab == _DecisionTab.active,
              onTap: () => setState(() => _tab = _DecisionTab.active),
            ),
            _TabChip(
              label: _decisionTabCompleted(l10n),
              selected: _tab == _DecisionTab.completed,
              onTap: () => setState(() => _tab = _DecisionTab.completed),
            ),
            _TabChip(
              label: _decisionTabRejected(l10n),
              selected: _tab == _DecisionTab.rejected,
              onTap: () => setState(() => _tab = _DecisionTab.rejected),
            ),
          ],
        ),
        if (fallbackActive) ...[
          const SizedBox(height: 16),
          _Banner(
            title: controller.localizedGatewayStatusLabel(l10n),
            body: _decisionsFallbackBody(l10n),
          ),
        ],
        if (controller.primaryMentalLoadItem != null) ...[
          const SizedBox(height: 16),
          GoLifeCard(
            accent: GoLifeAccent.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GoLifeSectionTitle(
                  title: _mentalLoadSummaryTitle(l10n),
                  subtitle: _mentalLoadSummaryBody(
                    l10n,
                    controller.pendingMentalLoadItems.length,
                    controller.primaryMentalLoadItem!.title,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.primaryMentalLoadItem!.summary,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (cards.isEmpty)
          GoLifeEmptyState(
            title: _decisionsEmptyTitle(l10n),
            body: _tab == _DecisionTab.active
                ? _decisionsEmptyActive(l10n)
                : _decisionsEmptyForStatus(l10n),
            icon: Icons.balance_outlined,
          )
        else
          for (final card in cards)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DecisionCardPanel(
                card: card,
                onExplain: () => _showDecisionExplanation(context, card),
                onAccept: () async {
                  await controller.acceptDecisionCard(card.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_decisionAcceptedMessage(l10n))),
                    );
                  }
                },
                onComplete: () async {
                  await controller.completeDecisionCard(card.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_decisionCompletedMessage(l10n))),
                    );
                  }
                },
                onPostpone: () async {
                  await controller.postponeDecisionCard(card.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_decisionPostponedMessage(l10n))),
                    );
                  }
                },
                onReject: () async {
                  await controller.rejectDecisionCard(card.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_decisionRejectedMessage(l10n))),
                    );
                  }
                },
                onCreateReminder: () async {
                  final message = await controller
                      .createReminderFromDecisionCard(card.id);
                  if (context.mounted && message != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  }
                },
              ),
            ),
      ],
    );
  }

  List<DecisionCard> _cardsForTab(GoLifeController controller) {
    switch (_tab) {
      case _DecisionTab.active:
        return controller.activeDecisionCards;
      case _DecisionTab.completed:
        return controller.decisionCards
            .where((card) => card.status == 'completed')
            .toList(growable: false);
      case _DecisionTab.rejected:
        return controller.decisionCards
            .where((card) => card.status == 'rejected')
            .toList(growable: false);
    }
  }

  void _showDecisionExplanation(BuildContext context, DecisionCard card) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: GoLifePalette.surface800,
      showDragHandle: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(card.recommendedAction, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                Text(l10n.labelEvidence, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final item in card.evidence)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('- $item', style: theme.textTheme.bodyMedium),
                  ),
                const SizedBox(height: 16),
                Text(
                  l10n.labelBlockedFromAi,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  card.privacySummary.blockedDomains.isEmpty
                      ? l10n.dashboardNothingBlocked
                      : card.privacySummary.blockedDomains.join(', '),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.labelAlwaysLocalOnDevice,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  card.privacySummary.localOnlyCollections.join(', '),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(l10n.labelUncertainty, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(card.uncertainty, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  _ShoppingTab _tab = _ShoppingTab.needs;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final l10n = AppLocalizations.of(context)!;
    final externalSourcesEnabled = controller.featureFlagEnabled(
      'shopping_external_sources',
      fallback: false,
    );

    return GoLifeScreen(
      title: _shoppingLabel(l10n),
      subtitle: _shoppingIntro(l10n),
      badge: GoLifeStatusPill(
        label: externalSourcesEnabled
            ? _shoppingExternalEnabled(l10n)
            : _shoppingExternalSourcesTitle(l10n),
        icon: externalSourcesEnabled
            ? Icons.verified_outlined
            : Icons.shield_moon_outlined,
        accent: externalSourcesEnabled
            ? GoLifeAccent.emerald
            : GoLifeAccent.amber,
      ),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _TabChip(
              label: _shoppingTabNeeds(l10n),
              selected: _tab == _ShoppingTab.needs,
              onTap: () => setState(() => _tab = _ShoppingTab.needs),
            ),
            _TabChip(
              label: _shoppingTabEvidence(l10n),
              selected: _tab == _ShoppingTab.evidence,
              onTap: () => setState(() => _tab = _ShoppingTab.evidence),
            ),
            _TabChip(
              label: _shoppingTabContext(l10n),
              selected: _tab == _ShoppingTab.context,
              onTap: () => setState(() => _tab = _ShoppingTab.context),
            ),
          ],
        ),
        if (!externalSourcesEnabled) ...[
          const SizedBox(height: 16),
          _Banner(
            title: _shoppingExternalSourcesTitle(l10n),
            body: _shoppingExternalSourcesBody(l10n),
          ),
        ],
        const SizedBox(height: 20),
        switch (_tab) {
          _ShoppingTab.needs => _ShoppingNeedsSection(
            controller: controller,
            externalSourcesEnabled: externalSourcesEnabled,
          ),
          _ShoppingTab.evidence => _ShoppingEvidenceSection(
            controller: controller,
          ),
          _ShoppingTab.context => const _ShoppingContextSection(),
        },
      ],
    );
  }
}

class _ShoppingNeedsSection extends StatelessWidget {
  const _ShoppingNeedsSection({
    required this.controller,
    required this.externalSourcesEnabled,
  });

  final GoLifeController controller;
  final bool externalSourcesEnabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final needs = controller.activeShoppingNeeds;
    if (needs.isEmpty) {
      return GoLifeEmptyState(
        title: _shoppingNeedsTitle(l10n),
        body: _shoppingNeedsEmpty(l10n),
        icon: Icons.shopping_bag_outlined,
      );
    }

    return Column(
      children: [
        for (final need in needs)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ShoppingNeedPanel(
              controller: controller,
              need: need,
              externalSourcesEnabled: externalSourcesEnabled,
            ),
          ),
      ],
    );
  }
}

class _ShoppingNeedPanel extends StatelessWidget {
  const _ShoppingNeedPanel({
    required this.controller,
    required this.need,
    required this.externalSourcesEnabled,
  });

  final GoLifeController controller;
  final ShoppingNeed need;
  final bool externalSourcesEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final evidence = controller.productEvidenceForTitle(need.title);
    return GoLifeCard(
      accent: GoLifeAccent.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(need.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            _shoppingNeedSummary(
              l10n,
              need.sourceDomain.localizedDomainLabel(l10n),
              (need.urgencyScore * 100).round(),
            ),
            style: theme.textTheme.bodyMedium,
          ),
          if (need.sustainabilityPreference != null) ...[
            const SizedBox(height: 6),
            Text(
              _shoppingSustainabilityLabel(
                l10n,
                need.sustainabilityPreference!,
              ),
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              GoLifeStatusPill(label: need.needType, accent: GoLifeAccent.blue),
              GoLifeStatusPill(label: need.state, accent: GoLifeAccent.neutral),
              if (need.currency != null)
                GoLifeStatusPill(
                  label: need.currency!,
                  accent: GoLifeAccent.neutral,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () async {
                  await controller.fetchProductEvidenceForNeed(need);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          externalSourcesEnabled
                              ? _shoppingEvidenceUpdated(l10n, need.title)
                              : _shoppingEvidenceLocalOnly(l10n, need.title),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.verified_outlined),
                label: Text(
                  externalSourcesEnabled
                      ? _shoppingLoadEvidence(l10n)
                      : _shoppingLocalOnlyEvidence(l10n),
                ),
              ),
            ],
          ),
          if (evidence != null) ...[
            const SizedBox(height: 12),
            _EvidenceSummaryChip(card: evidence),
          ],
        ],
      ),
    );
  }
}

class _ShoppingEvidenceSection extends StatelessWidget {
  const _ShoppingEvidenceSection({required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cards = controller.productEvidenceCards;
    if (cards.isEmpty) {
      return GoLifeEmptyState(
        title: l10n.labelEvidence,
        body: _shoppingEvidenceEmpty(l10n),
        icon: Icons.verified_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoLifeCard(
          accent: GoLifeAccent.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _shoppingSustainabilitySectionTitle(l10n),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _shoppingSustainabilitySectionBody(l10n),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final card in cards)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ProductEvidencePanel(card: card),
          ),
      ],
    );
  }
}

class _ShoppingContextSection extends StatelessWidget {
  const _ShoppingContextSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _NavigationPanel(
          title: l10n.navPantry,
          body: _shoppingPantryBody(l10n),
          actionLabel: _shoppingOpenPantry(l10n),
          onTap: () => context.go('/pantry'),
        ),
        _NavigationPanel(
          title: l10n.navCloset,
          body: _shoppingClosetBody(l10n),
          actionLabel: _shoppingOpenCloset(l10n),
          onTap: () => context.go('/closet'),
        ),
        _NavigationPanel(
          title: l10n.navRecipes,
          body: _shoppingRecipesBody(l10n),
          actionLabel: _shoppingOpenRecipes(l10n),
          onTap: () => context.go('/recipes'),
        ),
        _NavigationPanel(
          title: l10n.homeMemoryTitle,
          body: _shoppingHomeMemoryBody(l10n),
          actionLabel: l10n.homeMemoryActionOpen,
          onTap: () => context.go('/homememory'),
        ),
      ],
    );
  }
}

class _DecisionCardPanel extends StatelessWidget {
  const _DecisionCardPanel({
    required this.card,
    required this.onExplain,
    required this.onAccept,
    required this.onComplete,
    required this.onPostpone,
    required this.onReject,
    required this.onCreateReminder,
  });

  final DecisionCard card;
  final VoidCallback onExplain;
  final VoidCallback onAccept;
  final VoidCallback onComplete;
  final VoidCallback onPostpone;
  final VoidCallback onReject;
  final VoidCallback onCreateReminder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return GoLifeCard(
      accent: GoLifeAccent.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(card.recommendedAction, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              GoLifeStatusPill(label: card.status, accent: GoLifeAccent.blue),
              GoLifeStatusPill(
                label: _decisionEvidenceStatusLabel(l10n, card.evidenceStatus),
                accent: GoLifeAccent.amber,
              ),
              GoLifeStatusPill(
                label: l10n.dashboardConfidencePill(
                  (card.confidence * 100).round(),
                ),
                accent: GoLifeAccent.emerald,
              ),
              for (final domain in card.domainTargets)
                GoLifeStatusPill(
                  label: domain.localizedDomainLabel(l10n),
                  accent: GoLifeAccent.neutral,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: onExplain,
                icon: const Icon(Icons.visibility_outlined),
                label: Text(l10n.actionExplain),
              ),
              FilledButton.icon(
                onPressed: onAccept,
                icon: const Icon(Icons.thumb_up_alt_outlined),
                label: Text(l10n.actionAccept),
              ),
              FilledButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(l10n.actionDoNow),
              ),
              OutlinedButton.icon(
                onPressed: onPostpone,
                icon: const Icon(Icons.schedule_outlined),
                label: Text(_postponeLabel(l10n)),
              ),
              OutlinedButton.icon(
                onPressed: onCreateReminder,
                icon: const Icon(Icons.notifications_active_outlined),
                label: Text(l10n.homeMemoryActionCreateReminder),
              ),
              OutlinedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.thumb_down_alt_outlined),
                label: Text(l10n.actionNotUseful),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductEvidencePanel extends StatelessWidget {
  const _ProductEvidencePanel({required this.card});

  final ProductEvidenceCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return GoLifeCard(
      accent: GoLifeAccent.emerald,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.productName, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            card.reviewSummary ?? card.disclaimer,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              GoLifeStatusPill(
                label: _decisionEvidenceStatusLabel(
                  l10n,
                  card.sustainabilityStatus,
                ),
                accent: GoLifeAccent.blue,
              ),
              GoLifeStatusPill(
                label: l10n.dashboardConfidencePill(
                  (card.confidence * 100).round(),
                ),
                accent: GoLifeAccent.emerald,
              ),
              if (card.currency != null && card.price != null)
                GoLifeStatusPill(
                  label: '${card.price!.toStringAsFixed(2)} ${card.currency}',
                  accent: GoLifeAccent.neutral,
                ),
              if (card.source != null)
                GoLifeStatusPill(
                  label: card.source!,
                  accent: GoLifeAccent.neutral,
                ),
            ],
          ),
          if (card.sustainabilityStatus == 'insufficient_verified_data') ...[
            const SizedBox(height: 12),
            Text(
              _shoppingInsufficientDataWarning(l10n),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF8A6C2F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EvidenceSummaryChip extends StatelessWidget {
  const _EvidenceSummaryChip({required this.card});

  final ProductEvidenceCard card;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GoLifeCard(
      accent: GoLifeAccent.amber,
      padding: const EdgeInsets.all(12),
      child: Text(_shoppingEvidenceCardSummary(l10n, card)),
    );
  }
}

class _NavigationPanel extends StatelessWidget {
  const _NavigationPanel({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _Panel(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(body, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.tonal(onPressed: onTap, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

String _decisionsLabel(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Decisions',
  es: 'Decisiones',
  ptBr: 'Decisoes',
  ptPt: 'Decisoes',
  fr: 'Decisions',
  it: 'Decisioni',
  de: 'Entscheidungen',
  ja: 'Decisions',
  zhHans: 'Decisions',
  zhHant: 'Decisions',
);

String _mentalLoadSummaryTitle(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Mental load summary',
  es: 'Resumen de carga mental',
  ptBr: 'Resumo da carga mental',
  ptPt: 'Resumo da carga mental',
  fr: 'Resume de charge mentale',
  it: 'Riepilogo del carico mentale',
  de: 'Zusammenfassung der mentalen Last',
  ja: 'Mental load summary',
  zhHans: 'Mental load summary',
  zhHant: 'Mental load summary',
);

String _mentalLoadSummaryBody(AppLocalizations l10n, int count, String title) =>
    pickLocalizedValue(
      l10n.localeName,
      en: '$count pending items. Top item: $title',
      es: '$count items pendientes. Tema principal: $title',
      ptBr: '$count itens pendentes. Item principal: $title',
      ptPt: '$count itens pendentes. Item principal: $title',
      fr: '$count elements en attente. Principal: $title',
      it: '$count elementi in sospeso. Priorita: $title',
      de: '$count offene Elemente. Oberstes Thema: $title',
      ja: '$count pending items. Top item: $title',
      zhHans: '$count pending items. Top item: $title',
      zhHant: '$count pending items. Top item: $title',
    );

String _decisionsIntro(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Review one clear recommendation at a time. Every action stays confirmable and local-safe.',
  es: 'Revisa una recomendacion clara cada vez. Toda accion sigue siendo confirmable y segura en local.',
  ptBr:
      'Revise uma recomendacao clara por vez. Toda acao continua confirmavel e segura no modo local.',
  ptPt:
      'Reve uma recomendacao clara de cada vez. Toda a acao continua confirmavel e segura em local.',
  fr: 'Examine une recommandation claire a la fois. Chaque action reste confirmable et sure en local.',
  it: 'Rivedi una raccomandazione chiara alla volta. Ogni azione resta confermabile e sicura in locale.',
  de: 'Pruefe jeweils eine klare Empfehlung. Jede Aktion bleibt bestaetigbar und lokal sicher.',
  ja: 'Decisions',
  zhHans: 'Decisions',
  zhHant: 'Decisions',
);

String _tradeoffsBadge(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Trade-offs clear',
  es: 'Trade-offs claros',
  ptBr: 'Trade-offs claros',
  ptPt: 'Trade-offs claros',
  fr: 'Arbitrages clairs',
  it: 'Trade-off chiari',
  de: 'Klare Abwaegungen',
  ja: 'Trade-offs clear',
  zhHans: 'Trade-offs clear',
  zhHant: 'Trade-offs clear',
);

String _decisionsEmptyTitle(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'No decision needs your attention',
  es: 'Ninguna decision necesita tu atencion',
  ptBr: 'Nenhuma decisao precisa da sua atencao',
  ptPt: 'Nenhuma decisao precisa da tua atencao',
  fr: 'Aucune decision ne demande ton attention',
  it: 'Nessuna decisione richiede la tua attenzione',
  de: 'Keine Entscheidung braucht gerade deine Aufmerksamkeit',
  ja: 'No decision needs your attention',
  zhHans: 'No decision needs your attention',
  zhHant: 'No decision needs your attention',
);

String _decisionTabActive(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Active',
  es: 'Activas',
  ptBr: 'Ativas',
  ptPt: 'Ativas',
  fr: 'Actives',
  it: 'Attive',
  de: 'Aktiv',
  ja: 'Active',
  zhHans: 'Active',
  zhHant: 'Active',
);

String _decisionTabCompleted(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Completed',
  es: 'Completadas',
  ptBr: 'Concluidas',
  ptPt: 'Concluidas',
  fr: 'Terminees',
  it: 'Completate',
  de: 'Abgeschlossen',
  ja: 'Completed',
  zhHans: 'Completed',
  zhHant: 'Completed',
);

String _decisionTabRejected(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Rejected',
  es: 'Rechazadas',
  ptBr: 'Rejeitadas',
  ptPt: 'Rejeitadas',
  fr: 'Refusees',
  it: 'Rifiutate',
  de: 'Abgelehnt',
  ja: 'Rejected',
  zhHans: 'Rejected',
  zhHant: 'Rejected',
);

String _decisionsFallbackBody(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Remote decision planning is unavailable right now. GoLife is showing a local fallback.',
  es: 'La planificacion remota de decisiones no esta disponible ahora. GoLife muestra un fallback local.',
  ptBr:
      'O planejamento remoto de decisoes nao esta disponivel agora. O GoLife mostra um fallback local.',
  ptPt:
      'O planeamento remoto de decisoes nao esta disponivel agora. O GoLife mostra um fallback local.',
  fr: 'La planification distante des decisions est indisponible. GoLife affiche un fallback local.',
  it: 'La pianificazione remota delle decisioni non e disponibile. GoLife mostra un fallback locale.',
  de: 'Die entfernte Entscheidungsplanung ist derzeit nicht verfuegbar. GoLife zeigt einen lokalen Fallback.',
  ja: 'Decisions',
  zhHans: 'Decisions',
  zhHant: 'Decisions',
);

String _decisionsEmptyActive(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'No decisions yet. Capture something or wait for today\'s plan.',
  es: 'Todavia no hay decisiones. Captura algo o espera el plan de hoy.',
  ptBr: 'Ainda nao ha decisoes. Capture algo ou espere o plano de hoje.',
  ptPt: 'Ainda nao ha decisoes. Captura algo ou espera o plano de hoje.',
  fr: 'Pas encore de decisions. Capture quelque chose ou attends le plan du jour.',
  it: 'Nessuna decisione ancora. Cattura qualcosa o attendi il piano di oggi.',
  de: 'Noch keine Entscheidungen. Erfasse etwas oder warte auf den heutigen Plan.',
  ja: 'Decisions',
  zhHans: 'Decisions',
  zhHant: 'Decisions',
);

String _decisionsEmptyForStatus(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Nothing to show in this status.',
  es: 'No hay nada que mostrar en este estado.',
  ptBr: 'Nada para mostrar neste estado.',
  ptPt: 'Nada para mostrar neste estado.',
  fr: 'Rien a afficher pour cet etat.',
  it: 'Niente da mostrare in questo stato.',
  de: 'In diesem Status gibt es nichts anzuzeigen.',
  ja: 'Decisions',
  zhHans: 'Decisions',
  zhHant: 'Decisions',
);

String _decisionAcceptedMessage(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Decision accepted.',
  es: 'Decision aceptada.',
  ptBr: 'Decisao aceita.',
  ptPt: 'Decisao aceite.',
  fr: 'Decision acceptee.',
  it: 'Decisione accettata.',
  de: 'Entscheidung akzeptiert.',
  ja: 'Decision accepted.',
  zhHans: 'Decision accepted.',
  zhHant: 'Decision accepted.',
);

String _decisionCompletedMessage(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Decision completed.',
  es: 'Decision completada.',
  ptBr: 'Decisao concluida.',
  ptPt: 'Decisao concluida.',
  fr: 'Decision terminee.',
  it: 'Decisione completata.',
  de: 'Entscheidung abgeschlossen.',
  ja: 'Decision completed.',
  zhHans: 'Decision completed.',
  zhHant: 'Decision completed.',
);

String _decisionPostponedMessage(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Decision postponed.',
  es: 'Decision pospuesta.',
  ptBr: 'Decisao adiada.',
  ptPt: 'Decisao adiada.',
  fr: 'Decision reportee.',
  it: 'Decisione rimandata.',
  de: 'Entscheidung verschoben.',
  ja: 'Decision postponed.',
  zhHans: 'Decision postponed.',
  zhHant: 'Decision postponed.',
);

String _decisionRejectedMessage(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Decision rejected.',
  es: 'Decision rechazada.',
  ptBr: 'Decisao rejeitada.',
  ptPt: 'Decisao rejeitada.',
  fr: 'Decision refusee.',
  it: 'Decisione rifiutata.',
  de: 'Entscheidung abgelehnt.',
  ja: 'Decision rejected.',
  zhHans: 'Decision rejected.',
  zhHant: 'Decision rejected.',
);

String _shoppingLabel(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Shopping',
  es: 'Shopping',
  ptBr: 'Shopping',
  ptPt: 'Shopping',
  fr: 'Achats',
  it: 'Shopping',
  de: 'Einkaufen',
  ja: 'Shopping',
  zhHans: 'Shopping',
  zhHant: 'Shopping',
);

String _shoppingIntro(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'GoLife keeps shopping suggestions grounded in your pantry, closet, recipes, and HomeMemory context.',
  es: 'GoLife mantiene las sugerencias de shopping ancladas en tu despensa, closet, recetas y HomeMemory.',
  ptBr:
      'O GoLife mantém as sugestoes de shopping ancoradas em despensa, closet, receitas e HomeMemory.',
  ptPt:
      'O GoLife mantem as sugestoes de shopping ancoradas na despensa, closet, receitas e HomeMemory.',
  fr: 'GoLife garde les suggestions d achats ancrees dans ton garde-manger, ton placard, tes recettes et HomeMemory.',
  it: 'GoLife mantiene i suggerimenti di shopping ancorati a dispensa, armadio, ricette e HomeMemory.',
  de: 'GoLife haelt Shopping-Vorschlaege an Vorrat, Kleiderschrank, Rezepten und HomeMemory ausgerichtet.',
  ja: 'Shopping',
  zhHans: 'Shopping',
  zhHant: 'Shopping',
);

String _shoppingExternalEnabled(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Evidence available',
  es: 'Evidencia disponible',
  ptBr: 'Evidencia disponivel',
  ptPt: 'Evidencia disponivel',
  fr: 'Preuves disponibles',
  it: 'Evidenza disponibile',
  de: 'Evidenz verfuegbar',
  ja: 'Evidence available',
  zhHans: 'Evidence available',
  zhHant: 'Evidence available',
);

String _shoppingNeedsTitle(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Nothing urgent to buy',
  es: 'Nada urgente que comprar',
  ptBr: 'Nada urgente para comprar',
  ptPt: 'Nada urgente para comprar',
  fr: 'Rien d urgent a acheter',
  it: 'Niente di urgente da comprare',
  de: 'Nichts Dringendes zu kaufen',
  ja: 'Nothing urgent to buy',
  zhHans: 'Nothing urgent to buy',
  zhHant: 'Nothing urgent to buy',
);

String _shoppingTabNeeds(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Needs',
  es: 'Needs',
  ptBr: 'Needs',
  ptPt: 'Needs',
  fr: 'Besoins',
  it: 'Needs',
  de: 'Bedarfe',
  ja: 'Needs',
  zhHans: 'Needs',
  zhHant: 'Needs',
);

String _shoppingTabEvidence(AppLocalizations l10n) => l10n.labelEvidence;

String _shoppingTabContext(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Context',
  es: 'Contexto',
  ptBr: 'Contexto',
  ptPt: 'Contexto',
  fr: 'Contexte',
  it: 'Contesto',
  de: 'Kontext',
  ja: 'Context',
  zhHans: 'Context',
  zhHant: 'Context',
);

String _shoppingExternalSourcesTitle(AppLocalizations l10n) =>
    pickLocalizedValue(
      l10n.localeName,
      en: 'External sources disabled',
      es: 'Fuentes externas desactivadas',
      ptBr: 'Fontes externas desativadas',
      ptPt: 'Fontes externas desativadas',
      fr: 'Sources externes desactivees',
      it: 'Fonti esterne disattivate',
      de: 'Externe Quellen deaktiviert',
      ja: 'External sources disabled',
      zhHans: 'External sources disabled',
      zhHant: 'External sources disabled',
    );

String _shoppingExternalSourcesBody(
  AppLocalizations l10n,
) => pickLocalizedValue(
  l10n.localeName,
  en: 'Product evidence stays local-only because the external shopping source flag is off.',
  es: 'La evidencia de producto sigue siendo solo local porque la bandera de fuentes externas esta apagada.',
  ptBr:
      'A evidencia de produto permanece local porque a flag de fontes externas esta desligada.',
  ptPt:
      'A evidencia de produto permanece local porque a flag de fontes externas esta desligada.',
  fr: 'Les preuves produit restent locales car la fonctionnalite de sources externes est desactivee.',
  it: 'L evidenza prodotto resta locale perche il flag delle fonti esterne e disattivato.',
  de: 'Produktevidenz bleibt lokal, weil das Flag fuer externe Quellen deaktiviert ist.',
  ja: 'External sources disabled',
  zhHans: 'External sources disabled',
  zhHant: 'External sources disabled',
);

String _shoppingNeedsEmpty(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'No shopping needs yet. Pantry rescues, wardrobe pauses, and HomeMemory warranty signals will appear here.',
  es: 'Todavia no hay needs de shopping. Aqui apareceran rescates de despensa, pausas de compras y senales de garantia.',
  ptBr:
      'Ainda nao ha needs de shopping. Aqui aparecerao sinais de despensa, pausas de compra e garantia.',
  ptPt:
      'Ainda nao ha needs de shopping. Aqui aparecerao sinais de despensa, pausas de compra e garantia.',
  fr: 'Aucun besoin d achat pour le moment. Les rescues de garde-manger, pauses d achat et signaux de garantie apparaitront ici.',
  it: 'Nessun need di shopping per ora. Qui appariranno dispensa, pause acquisti e segnali di garanzia.',
  de: 'Noch keine Shopping-Bedarfe. Hier erscheinen Vorratsrettungen, Kaufpausen und Garantiesignale.',
  ja: 'Shopping',
  zhHans: 'Shopping',
  zhHant: 'Shopping',
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

String _shoppingSustainabilityLabel(AppLocalizations l10n, String preference) =>
    pickLocalizedValue(
      l10n.localeName,
      en: 'Sustainability: $preference',
      es: 'Sostenibilidad: $preference',
      ptBr: 'Sustentabilidade: $preference',
      ptPt: 'Sustentabilidade: $preference',
      fr: 'Durabilite : $preference',
      it: 'Sostenibilita: $preference',
      de: 'Nachhaltigkeit: $preference',
      ja: 'Sustainability: $preference',
      zhHans: 'Sustainability: $preference',
      zhHant: 'Sustainability: $preference',
    );

String _shoppingEvidenceUpdated(AppLocalizations l10n, String title) =>
    pickLocalizedValue(
      l10n.localeName,
      en: 'Evidence updated for $title.',
      es: 'Evidencia actualizada para $title.',
      ptBr: 'Evidencia atualizada para $title.',
      ptPt: 'Evidencia atualizada para $title.',
      fr: 'Preuves mises a jour pour $title.',
      it: 'Evidenza aggiornata per $title.',
      de: 'Evidenz fuer $title aktualisiert.',
      ja: 'Evidence updated for $title.',
      zhHans: 'Evidence updated for $title.',
      zhHant: 'Evidence updated for $title.',
    );

String _shoppingEvidenceLocalOnly(AppLocalizations l10n, String title) =>
    pickLocalizedValue(
      l10n.localeName,
      en: 'Evidence remained local-only for $title.',
      es: 'La evidencia siguio siendo solo local para $title.',
      ptBr: 'A evidencia permaneceu apenas local para $title.',
      ptPt: 'A evidencia permaneceu apenas local para $title.',
      fr: 'Les preuves sont restees locales pour $title.',
      it: 'L evidenza e rimasta solo locale per $title.',
      de: 'Evidenz blieb fuer $title nur lokal.',
      ja: 'Evidence remained local-only for $title.',
      zhHans: 'Evidence remained local-only for $title.',
      zhHant: 'Evidence remained local-only for $title.',
    );

String _shoppingLoadEvidence(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Load evidence',
  es: 'Cargar evidencia',
  ptBr: 'Carregar evidencia',
  ptPt: 'Carregar evidencia',
  fr: 'Charger les preuves',
  it: 'Carica evidenza',
  de: 'Evidenz laden',
  ja: 'Load evidence',
  zhHans: 'Load evidence',
  zhHant: 'Load evidence',
);

String _shoppingLocalOnlyEvidence(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Local-only evidence',
  es: 'Evidencia solo local',
  ptBr: 'Evidencia so local',
  ptPt: 'Evidencia so local',
  fr: 'Preuves locales uniquement',
  it: 'Evidenza solo locale',
  de: 'Nur lokale Evidenz',
  ja: 'Local-only evidence',
  zhHans: 'Local-only evidence',
  zhHant: 'Local-only evidence',
);

String _shoppingEvidenceEmpty(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'No product evidence yet. Request evidence from a shopping need to populate this section.',
  es: 'Todavia no hay evidencia de producto. Solicitala desde una need de shopping para llenar esta seccion.',
  ptBr:
      'Ainda nao ha evidencia de produto. Solicite a partir de uma need de shopping.',
  ptPt:
      'Ainda nao ha evidencia de produto. Solicita-a a partir de uma need de shopping.',
  fr: 'Aucune preuve produit pour le moment. Demande des preuves depuis un besoin d achat.',
  it: 'Nessuna evidenza prodotto. Richiedila da un need di shopping.',
  de: 'Noch keine Produktevidenz. Fordere sie aus einem Shopping-Bedarf an.',
  ja: 'Shopping',
  zhHans: 'Shopping',
  zhHant: 'Shopping',
);

String _shoppingSustainabilitySectionTitle(AppLocalizations l10n) =>
    pickLocalizedValue(
      l10n.localeName,
      en: 'Sustainability section',
      es: 'Seccion de sostenibilidad',
      ptBr: 'Secao de sustentabilidade',
      ptPt: 'Secao de sustentabilidade',
      fr: 'Section durabilite',
      it: 'Sezione sostenibilita',
      de: 'Nachhaltigkeitsbereich',
      ja: 'Shopping',
      zhHans: 'Shopping',
      zhHant: 'Shopping',
    );

String _shoppingSustainabilitySectionBody(
  AppLocalizations l10n,
) => pickLocalizedValue(
  l10n.localeName,
  en: 'Evidence cards never claim verified sustainability when the data is incomplete.',
  es: 'Las tarjetas de evidencia no afirman sostenibilidad verificada cuando faltan datos.',
  ptBr:
      'Os cartoes de evidencia nunca afirmam sustentabilidade verificada quando faltam dados.',
  ptPt:
      'Os cartoes de evidencia nunca afirmam sustentabilidade verificada quando faltam dados.',
  fr: 'Les cartes de preuve ne revendiquent jamais une durabilite verifiee lorsque les donnees sont incompletes.',
  it: 'Le carte evidenza non dichiarano sostenibilita verificata quando i dati sono incompleti.',
  de: 'Evidenzkarten behaupten keine verifizierte Nachhaltigkeit bei unvollstaendigen Daten.',
  ja: 'Shopping',
  zhHans: 'Shopping',
  zhHant: 'Shopping',
);

String _shoppingPantryBody(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Use pantry context to avoid buying what you already have.',
  es: 'Usa la despensa para evitar comprar lo que ya tienes.',
  ptBr: 'Use a despensa para evitar comprar o que voce ja tem.',
  ptPt: 'Usa a despensa para evitar comprar o que ja tens.',
  fr: 'Utilise le garde-manger pour eviter d acheter ce que tu as deja.',
  it: 'Usa la dispensa per evitare acquisti duplicati.',
  de: 'Nutze den Vorrat, um Doppelkaeufe zu vermeiden.',
  ja: 'Shopping',
  zhHans: 'Shopping',
  zhHant: 'Shopping',
);

String _shoppingOpenPantry(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Open pantry',
  es: 'Abrir despensa',
  ptBr: 'Abrir despensa',
  ptPt: 'Abrir despensa',
  fr: 'Ouvrir le garde-manger',
  it: 'Apri dispensa',
  de: 'Vorrat oeffnen',
  ja: 'Shopping',
  zhHans: 'Shopping',
  zhHant: 'Shopping',
);

String _shoppingClosetBody(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Pause wardrobe purchases and compare with existing items first.',
  es: 'Pausa compras de ropa y compara primero con lo que ya tienes.',
  ptBr: 'Pause compras de roupa e compare primeiro com o que voce ja tem.',
  ptPt: 'Pausa compras de roupa e compara primeiro com o que ja tens.',
  fr: 'Mets en pause les achats de vetements et compare d abord avec l existant.',
  it: 'Metti in pausa gli acquisti di abbigliamento e confronta prima cio che possiedi.',
  de: 'Stoppe Kleiderkaeufe und vergleiche zuerst mit vorhandenen Teilen.',
  ja: 'Shopping',
  zhHans: 'Shopping',
  zhHant: 'Shopping',
);

String _shoppingOpenCloset(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Open closet',
  es: 'Abrir closet',
  ptBr: 'Abrir closet',
  ptPt: 'Abrir closet',
  fr: 'Ouvrir le placard',
  it: 'Apri armadio',
  de: 'Kleiderschrank oeffnen',
  ja: 'Shopping',
  zhHans: 'Shopping',
  zhHant: 'Shopping',
);

String _shoppingRecipesBody(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Reuse recipe rescues before turning them into new shopping needs.',
  es: 'Reutiliza rescates de recetas antes de convertirlos en nuevas necesidades de shopping.',
  ptBr:
      'Reutilize resgates de receitas antes de virar novas needs de shopping.',
  ptPt:
      'Reutiliza resgates de receitas antes de virar novas needs de shopping.',
  fr: 'Reutilise les rescues de recettes avant de les transformer en nouveaux besoins d achat.',
  it: 'Riusa i recuperi ricetta prima di trasformarli in nuovi needs di shopping.',
  de: 'Nutze Rezept-Rettungen erneut, bevor daraus neue Shopping-Bedarfe werden.',
  ja: 'Shopping',
  zhHans: 'Shopping',
  zhHant: 'Shopping',
);

String _shoppingOpenRecipes(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Open recipes',
  es: 'Abrir recetas',
  ptBr: 'Abrir receitas',
  ptPt: 'Abrir receitas',
  fr: 'Ouvrir les recettes',
  it: 'Apri ricette',
  de: 'Rezepte oeffnen',
  ja: 'Shopping',
  zhHans: 'Shopping',
  zhHant: 'Shopping',
);

String _shoppingHomeMemoryBody(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'Warranty and proof data can become replacement or repair research needs.',
  es: 'Garantias y pruebas pueden convertirse en necesidades de reemplazo o reparacion.',
  ptBr: 'Garantia e comprovantes podem virar needs de reposicao ou reparo.',
  ptPt: 'Garantia e comprovativos podem virar needs de reposicao ou reparacao.',
  fr: 'Les garanties et preuves peuvent devenir des besoins de recherche de reparation ou remplacement.',
  it: 'Garanzie e prove possono diventare needs di riparazione o sostituzione.',
  de: 'Garantie- und Belegdaten koennen zu Reparatur- oder Ersatzbedarf werden.',
  ja: 'Shopping',
  zhHans: 'Shopping',
  zhHant: 'Shopping',
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

String _decisionEvidenceStatusLabel(AppLocalizations l10n, String value) {
  switch (value) {
    case 'local_only':
      return pickLocalizedValue(
        l10n.localeName,
        en: 'Local only',
        es: 'Solo local',
        ptBr: 'So local',
        ptPt: 'So local',
        fr: 'Local uniquement',
        it: 'Solo locale',
        de: 'Nur lokal',
        ja: 'Local only',
        zhHans: 'Local only',
        zhHant: 'Local only',
      );
    case 'insufficient_verified_data':
      return pickLocalizedValue(
        l10n.localeName,
        en: 'Insufficient evidence',
        es: 'Evidencia insuficiente',
        ptBr: 'Evidencia insuficiente',
        ptPt: 'Evidencia insuficiente',
        fr: 'Preuves insuffisantes',
        it: 'Evidenza insufficiente',
        de: 'Unzureichende Evidenz',
        ja: 'Insufficient evidence',
        zhHans: 'Insufficient evidence',
        zhHant: 'Insufficient evidence',
      );
    default:
      return value;
  }
}

String _shoppingEvidenceCardSummary(
  AppLocalizations l10n,
  ProductEvidenceCard card,
) =>
    '${_decisionEvidenceStatusLabel(l10n, card.sustainabilityStatus)}: ${card.disclaimer}';

String _shoppingInsufficientDataWarning(
  AppLocalizations l10n,
) => pickLocalizedValue(
  l10n.localeName,
  en: 'Insufficient verified data. Do not treat this as a verified sustainability claim.',
  es: 'Datos verificados insuficientes. No lo trates como un claim de sostenibilidad verificado.',
  ptBr:
      'Dados verificados insuficientes. Nao trate isto como claim de sustentabilidade verificado.',
  ptPt:
      'Dados verificados insuficientes. Nao trate isto como claim de sustentabilidade verificado.',
  fr: 'Donnees verifiees insuffisantes. Ne traite pas cela comme une revendication de durabilite verifiee.',
  it: 'Dati verificati insufficienti. Non trattarlo come un claim di sostenibilita verificato.',
  de: 'Unzureichende verifizierte Daten. Nicht als bestaetigte Nachhaltigkeitsaussage behandeln.',
  ja: 'Shopping',
  zhHans: 'Shopping',
  zhHant: 'Shopping',
);

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GoLifeCard(child: child);
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GoLifeCard(
      accent: GoLifeAccent.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
    );
  }
}

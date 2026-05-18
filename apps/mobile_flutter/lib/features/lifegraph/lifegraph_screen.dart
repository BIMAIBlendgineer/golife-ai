import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/app_localized_values.dart';
import '../../core/lifegraph/life_event.dart';
import '../../core/lifegraph/lifegraph_relation.dart';
import '../../core/privacy/privacy_models.dart';
import '../../domains/privacy/evidence_item.dart';
import '../../domains/privacy/privacy_audit_entry.dart';
import '../../l10n/app_localizations.dart';
import '../app_state/golife_controller.dart';
import '../shared/premium_ui.dart';

class LifeGraphScreen extends StatefulWidget {
  const LifeGraphScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  State<LifeGraphScreen> createState() => _LifeGraphScreenState();
}

class _LifeGraphScreenState extends State<LifeGraphScreen> {
  String _searchQuery = '';
  String? _selectedDomain;
  _DateWindow _dateWindow = _DateWindow.all;
  _PrivacyFilter _privacyFilter = _PrivacyFilter.all;
  Timer? _searchDebounce;
  bool _viewTracked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _viewTracked) {
        return;
      }
      _viewTracked = true;
      unawaited(_trackLifeGraphViewed());
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allEvents = widget.controller.lifeEvents;
    final analyticsSnapshot = _buildAnalyticsSnapshot(allEvents);
    final viewModels = analyticsSnapshot.viewModels;
    final grouped = _groupByDate(viewModels, l10n);

    return GoLifeScreen(
      title: _memoryTitle(l10n),
      subtitle: _memorySubtitle(l10n),
      badge: GoLifeStatusPill(
        label: '${viewModels.length}',
        icon: Icons.hub_rounded,
        accent: GoLifeAccent.blue,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: GoLifeMetricCard(
                label: _eventsLabel(l10n),
                value: '${viewModels.length}',
                subtitle: _totalEventsLabel(allEvents.length, l10n),
                icon: Icons.bolt_outlined,
                accent: GoLifeAccent.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GoLifeMetricCard(
                label: _usedByAiLabel(l10n),
                value: '${widget.controller.aiEligibleEventCount}',
                subtitle: controllerLabel(_selectedDomain, l10n),
                icon: Icons.auto_awesome_rounded,
                accent: GoLifeAccent.emerald,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GoLifeMetricCard(
                label: _protectedLocalLabel(l10n),
                value:
                    '${widget.controller.totalEventCount - widget.controller.aiEligibleEventCount}',
                icon: Icons.shield_outlined,
                accent: GoLifeAccent.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GoLifeMetricCard(
                label: _relationsLabel(l10n),
                value: '${analyticsSnapshot.visibleRelationCount}',
                subtitle: _evidenceCountLabel(
                  analyticsSnapshot.visibleEvidenceCount,
                  l10n,
                ),
                icon: Icons.alt_route_rounded,
                accent: GoLifeAccent.violet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GoLifeCard(
          accent: GoLifeAccent.violet,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GoLifeSectionTitle(
                title: _memorySearchTitle(l10n),
                subtitle: _memorySearchBody(l10n),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey<String>('lifegraph-search-field'),
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.lifeGraphSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 14),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(
                  _filtersLabel(l10n),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  _filtersBody(l10n),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                children: [
                  const SizedBox(height: 10),
                  _FilterSection(
                    title: _domainFilterTitle(l10n),
                    children: [
                      ChoiceChip(
                        label: Text(l10n.lifeGraphFilterAll),
                        selected: _selectedDomain == null,
                        onSelected: (_) => _updateDomainFilter(null),
                      ),
                      for (final domain in _distinctDomains(allEvents))
                        ChoiceChip(
                          label: Text(domain.localizedDomainLabel(l10n)),
                          selected: _selectedDomain == domain,
                          onSelected: (_) => _updateDomainFilter(domain),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FilterSection(
                    title: _dateFilterTitle(l10n),
                    children: [
                      for (final window in _DateWindow.values)
                        ChoiceChip(
                          label: Text(_dateWindowLabel(window, l10n)),
                          selected: _dateWindow == window,
                          onSelected: (_) => _updateDateWindow(window),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FilterSection(
                    title: l10n.lifeGraphFilterPrivacyTitle,
                    children: [
                      for (final filter in _PrivacyFilter.values)
                        ChoiceChip(
                          label: Text(_privacyFilterLabel(filter, l10n)),
                          selected: _privacyFilter == filter,
                          onSelected: (_) => _updatePrivacyFilter(filter),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GoLifeSectionTitle(
          title: _domainsTitle(l10n),
          subtitle: _domainsBody(l10n),
        ),
        const SizedBox(height: 12),
        GoLifeShortcutGrid(
          items: [
            GoLifeShortcutItem(
              label: l10n.navTasks,
              icon: Icons.checklist_rounded,
              onTap: () => context.go('/tasks'),
            ),
            GoLifeShortcutItem(
              label: l10n.navHabits,
              icon: Icons.self_improvement_rounded,
              onTap: () => context.go('/habits'),
            ),
            GoLifeShortcutItem(
              label: l10n.navMoney,
              icon: Icons.stacked_line_chart_rounded,
              onTap: () => context.go('/money'),
            ),
            GoLifeShortcutItem(
              label: l10n.navPantry,
              icon: Icons.kitchen_rounded,
              onTap: () => context.go('/pantry'),
            ),
            GoLifeShortcutItem(
              label: l10n.navWeek,
              icon: Icons.view_week_rounded,
              onTap: () => context.go('/week'),
            ),
            GoLifeShortcutItem(
              label: l10n.navCloset,
              icon: Icons.checkroom_rounded,
              onTap: () => context.go('/closet'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GoLifeShortcutGrid(
          items: [
            GoLifeShortcutItem(
              label: _shoppingLabel(l10n),
              icon: Icons.shopping_bag_outlined,
              onTap: () => context.go('/shopping'),
            ),
            GoLifeShortcutItem(
              label: _decisionsLabel(l10n),
              icon: Icons.rule_folder_outlined,
              onTap: () => context.go('/decisions'),
            ),
            GoLifeShortcutItem(
              label: l10n.navCalendar,
              icon: Icons.calendar_month_rounded,
              onTap: () => context.go('/calendar'),
            ),
            GoLifeShortcutItem(
              label: l10n.navRecipes,
              icon: Icons.restaurant_menu_rounded,
              onTap: () => context.go('/recipes'),
            ),
            GoLifeShortcutItem(
              label: l10n.navJournal,
              icon: Icons.menu_book_rounded,
              onTap: () => context.go('/journal'),
            ),
            GoLifeShortcutItem(
              label: l10n.homeMemoryTitle,
              icon: Icons.home_work_outlined,
              onTap: () => context.go('/homememory'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GoLifeSectionTitle(
          title: _timelineTitle(l10n),
          subtitle: _timelineBody(l10n),
        ),
        const SizedBox(height: 12),
        if (viewModels.isEmpty)
          GoLifeEmptyState(
            title: _emptyMemoryTitle(l10n),
            body: l10n.lifeGraphNoEvents,
            icon: Icons.history_toggle_off_rounded,
          )
        else
          for (final entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final item in entry.value) ...[
              _MemoryEventCard(viewModel: item, controller: widget.controller),
              const SizedBox(height: 12),
            ],
          ],
      ],
    );
  }

  List<_LifeGraphEventViewModel> _buildViewModels(List<LifeEvent> events) {
    final byId = <String, LifeEvent>{
      for (final event in widget.controller.lifeEvents) event.eventId: event,
    };
    final filtered = events.where(_matchesFilters).toList(growable: false);
    return filtered
        .map(
          (event) => _LifeGraphEventViewModel(
            event: event,
            evidenceItems: _evidenceForEvent(event),
            relations: _relationsForEvent(event),
            auditEntries: _auditsForEvent(event),
            relatedEventsById: byId,
          ),
        )
        .toList(growable: false);
  }

  _LifeGraphAnalyticsSnapshot _buildAnalyticsSnapshot(List<LifeEvent> events) {
    final viewModels = _buildViewModels(events);
    final visibleEvidenceIds = <String>{
      for (final item in viewModels)
        ...item.evidenceItems.map((e) => e.evidenceId),
    };
    final visibleRelationIds = <String>{
      for (final item in viewModels) ...item.relations.map((r) => r.relationId),
    };
    final visibleAuditIds = <String>{
      for (final item in viewModels) ...item.auditEntries.map((a) => a.auditId),
    };
    return _LifeGraphAnalyticsSnapshot(
      viewModels: viewModels,
      visibleEvidenceCount: visibleEvidenceIds.length,
      visibleRelationCount: visibleRelationIds.length,
      visibleAuditCount: visibleAuditIds.length,
    );
  }

  void _onSearchChanged(String value) {
    final trimmed = value.trim();
    setState(() => _searchQuery = trimmed);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted || trimmed.isEmpty) {
        return;
      }
      unawaited(_trackLifeGraphSearchUsed());
    });
  }

  void _updateDomainFilter(String? domain) {
    setState(() => _selectedDomain = domain);
    unawaited(_trackLifeGraphFiltered());
  }

  void _updateDateWindow(_DateWindow window) {
    setState(() => _dateWindow = window);
    unawaited(_trackLifeGraphFiltered());
  }

  void _updatePrivacyFilter(_PrivacyFilter filter) {
    setState(() => _privacyFilter = filter);
    unawaited(_trackLifeGraphFiltered());
  }

  Future<void> _trackLifeGraphViewed() async {
    final allEvents = widget.controller.lifeEvents;
    final snapshot = _buildAnalyticsSnapshot(allEvents);
    await widget.controller.trackLifeGraphViewed(
      resultCount: snapshot.viewModels.length,
      eventCount: allEvents.length,
      relationCount: snapshot.visibleRelationCount,
      evidenceCount: snapshot.visibleEvidenceCount,
      auditCount: snapshot.visibleAuditCount,
      domainFilter: _selectedDomain,
      privacyFilter: _privacyFilter.analyticsKey,
      dateWindow: _dateWindow.analyticsKey,
    );
  }

  Future<void> _trackLifeGraphFiltered() async {
    final allEvents = widget.controller.lifeEvents;
    final snapshot = _buildAnalyticsSnapshot(allEvents);
    await widget.controller.trackLifeGraphFiltered(
      resultCount: snapshot.viewModels.length,
      eventCount: allEvents.length,
      relationCount: snapshot.visibleRelationCount,
      evidenceCount: snapshot.visibleEvidenceCount,
      auditCount: snapshot.visibleAuditCount,
      domainFilter: _selectedDomain,
      privacyFilter: _privacyFilter.analyticsKey,
      dateWindow: _dateWindow.analyticsKey,
    );
  }

  Future<void> _trackLifeGraphSearchUsed() async {
    final allEvents = widget.controller.lifeEvents;
    final snapshot = _buildAnalyticsSnapshot(allEvents);
    await widget.controller.trackLifeGraphSearchUsed(
      resultCount: snapshot.viewModels.length,
      eventCount: allEvents.length,
      relationCount: snapshot.visibleRelationCount,
      evidenceCount: snapshot.visibleEvidenceCount,
      auditCount: snapshot.visibleAuditCount,
      domainFilter: _selectedDomain,
      privacyFilter: _privacyFilter.analyticsKey,
      dateWindow: _dateWindow.analyticsKey,
      queryLengthBucket: _queryLengthBucket(_searchQuery),
    );
  }

  bool _matchesFilters(LifeEvent event) {
    if (_selectedDomain != null && event.domain != _selectedDomain) {
      return false;
    }
    if (!_matchesDateWindow(event, _dateWindow)) {
      return false;
    }
    if (!_matchesPrivacyFilter(event, _privacyFilter)) {
      return false;
    }
    if (_searchQuery.isEmpty) {
      return true;
    }
    final haystack = <String>[
      event.summary,
      event.domain,
      event.eventType,
      event.source,
      event.privacyLevel,
    ].join(' ').toLowerCase();
    return haystack.contains(_searchQuery.toLowerCase());
  }

  List<String> _distinctDomains(List<LifeEvent> events) {
    final values = <String>{for (final event in events) event.domain};
    final sorted = values.toList()..sort();
    return sorted;
  }

  bool _matchesDateWindow(LifeEvent event, _DateWindow window) {
    if (window == _DateWindow.all) {
      return true;
    }
    final timestamp = DateTime.tryParse(event.timestampIso)?.toUtc();
    if (timestamp == null) {
      return true;
    }
    final now = DateTime.now().toUtc();
    final days = switch (window) {
      _DateWindow.last7Days => 7,
      _DateWindow.last30Days => 30,
      _DateWindow.last90Days => 90,
      _DateWindow.all => 0,
    };
    return !timestamp.isBefore(now.subtract(Duration(days: days)));
  }

  bool _matchesPrivacyFilter(LifeEvent event, _PrivacyFilter filter) {
    switch (filter) {
      case _PrivacyFilter.all:
        return true;
      case _PrivacyFilter.localOnly:
        return event.privacyLevel == DataPermission.localOnly.storageKey;
      case _PrivacyFilter.syncAllowed:
        return event.privacyLevel == DataPermission.syncAllowed.storageKey;
      case _PrivacyFilter.aiAllowed:
        return event.privacyLevel == DataPermission.aiAllowed.storageKey;
    }
  }

  List<EvidenceItem> _evidenceForEvent(LifeEvent event) {
    final matches = widget.controller.evidenceItems.where((item) {
      final samePayloadRef =
          item.localPayloadRef == 'life_event:${event.eventId}';
      final sameHash = event.evidenceHash != null &&
          event.evidenceHash!.isNotEmpty &&
          item.hash == event.evidenceHash;
      return samePayloadRef || sameHash;
    });
    return matches.toList(growable: false);
  }

  List<LifeGraphRelation> _relationsForEvent(LifeEvent event) {
    return widget.controller.lifeGraphRelations
        .where(
          (relation) =>
              relation.fromEventId == event.eventId ||
              relation.toEventId == event.eventId,
        )
        .toList(growable: false);
  }

  List<PrivacyAuditEntry> _auditsForEvent(LifeEvent event) {
    final entries = widget.controller.privacyAuditEntries
        .where((entry) => entry.eventId == event.eventId)
        .toList(growable: false);
    entries.sort((a, b) => b.changedAt.compareTo(a.changedAt));
    return entries;
  }

  Map<String, List<_LifeGraphEventViewModel>> _groupByDate(
    List<_LifeGraphEventViewModel> items,
    AppLocalizations l10n,
  ) {
    final grouped = <String, List<_LifeGraphEventViewModel>>{};
    for (final item in items) {
      final label = _dateGroupLabel(item.event.timestampIso, l10n);
      grouped.putIfAbsent(label, () => <_LifeGraphEventViewModel>[]).add(item);
    }
    return grouped;
  }
}

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

class _MemoryEventCard extends StatelessWidget {
  const _MemoryEventCard({required this.viewModel, required this.controller});

  final _LifeGraphEventViewModel viewModel;
  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final event = viewModel.event;
    final latestAudit =
        viewModel.auditEntries.isEmpty ? null : viewModel.auditEntries.first;

    return GoLifeTimelineCard(
      title: event.summary,
      subtitle: event.timestampIso,
      accent: _eventAccent(event),
      meta: [
        GoLifeStatusPill(
          label: event.domain.localizedDomainLabel(l10n),
          accent: GoLifeAccent.violet,
        ),
        GoLifeStatusPill(
          label: event.privacyLevel.localizedPermissionLabel(l10n),
          accent: _privacyAccent(event.privacyLevel),
        ),
        GoLifeStatusPill(label: event.source, accent: GoLifeAccent.blue),
        if (latestAudit != null)
          Container(
            key: ValueKey<String>('lifegraph-audit-${event.eventId}'),
            child: GoLifeStatusPill(
              label: AppLocalizations.of(context)!.privacyAuditChangedAt,
              accent: GoLifeAccent.amber,
            ),
          ),
      ],
      actions: [
        OutlinedButton.icon(
          onPressed: () =>
              _showEventDetails(context, controller, event.eventId),
          icon: const Icon(Icons.visibility_outlined),
          label: Text(_detailsLabel(l10n)),
        ),
      ],
    );
  }
}

void _showEventDetails(
  BuildContext context,
  GoLifeController controller,
  String eventId,
) {
  showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final l10n = AppLocalizations.of(context)!;
          final event = controller.lifeEvents.firstWhere(
            (item) => item.eventId == eventId,
          );
          final evidence = controller.evidenceItems.where((item) {
            return item.localPayloadRef == 'life_event:${event.eventId}' ||
                item.hash == event.evidenceHash;
          }).toList(growable: false);
          final relations = controller.lifeGraphRelations.where((relation) {
            return relation.fromEventId == event.eventId ||
                relation.toEventId == event.eventId;
          }).toList(growable: false);
          final audits = controller.privacyAuditEntries.where((entry) {
            return entry.eventId == event.eventId;
          }).toList(growable: false)
            ..sort((a, b) => b.changedAt.compareTo(a.changedAt));

          final usedInMission = controller.dailyMission != null &&
              controller
                  .missionDataUsed(controller.dailyMission!)
                  .contains(event.summary);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.summary,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        GoLifeStatusPill(
                          label: event.domain.localizedDomainLabel(l10n),
                          accent: GoLifeAccent.violet,
                        ),
                        GoLifeStatusPill(
                          label: event.privacyLevel.localizedPermissionLabel(
                            l10n,
                          ),
                          accent: _privacyAccent(event.privacyLevel),
                        ),
                        GoLifeStatusPill(
                          label: event.source,
                          accent: GoLifeAccent.blue,
                        ),
                        if (usedInMission)
                          GoLifeStatusPill(
                            label: _usedInMissionLabel(l10n),
                            accent: GoLifeAccent.emerald,
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GoLifeCard(
                      accent: GoLifeAccent.blue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _privacyChangeTitle(l10n),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final permission in DataPermission.values)
                                ChoiceChip(
                                  label: Text(permission.localizedLabel(l10n)),
                                  selected: event.privacyLevel ==
                                      permission.storageKey,
                                  onSelected: (_) async {
                                    await controller.updateEventPrivacy(
                                      event.eventId,
                                      permission,
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GoLifeCard(
                      accent: GoLifeAccent.emerald,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.lifeGraphEvidenceTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _DetailList(
                            items: evidence
                                .map(
                                  (item) =>
                                      '${item.sourceType} | ${item.privacyClass.storageKey}',
                                )
                                .toList(growable: false),
                            emptyLabel: l10n.lifeGraphEvidenceEmpty,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l10n.lifeGraphRelationsTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _DetailList(
                            items: relations
                                .map((relation) => relation.relationType)
                                .toList(growable: false),
                            emptyLabel: l10n.lifeGraphRelationsEmpty,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l10n.privacyAuditTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _DetailList(
                            items: audits
                                .map(
                                  (audit) =>
                                      '${audit.oldPrivacyLevel.localizedPermissionLabel(l10n)} → ${audit.newPrivacyLevel.localizedPermissionLabel(l10n)} | ${audit.changedAt}',
                                )
                                .toList(growable: false),
                            emptyLabel: l10n.lifeGraphAuditNone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => context.go('/settings'),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text(l10n.lifeGraphOpenPrivacyAudit),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

class _DetailList extends StatelessWidget {
  const _DetailList({required this.items, this.emptyLabel});

  final List<String> items;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        emptyLabel ?? '',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '• $item',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}

class _LifeGraphEventViewModel {
  const _LifeGraphEventViewModel({
    required this.event,
    required this.evidenceItems,
    required this.relations,
    required this.auditEntries,
    required this.relatedEventsById,
  });

  final LifeEvent event;
  final List<EvidenceItem> evidenceItems;
  final List<LifeGraphRelation> relations;
  final List<PrivacyAuditEntry> auditEntries;
  final Map<String, LifeEvent> relatedEventsById;
}

class _LifeGraphAnalyticsSnapshot {
  const _LifeGraphAnalyticsSnapshot({
    required this.viewModels,
    required this.visibleEvidenceCount,
    required this.visibleRelationCount,
    required this.visibleAuditCount,
  });

  final List<_LifeGraphEventViewModel> viewModels;
  final int visibleEvidenceCount;
  final int visibleRelationCount;
  final int visibleAuditCount;
}

enum _DateWindow { all, last7Days, last30Days, last90Days }

enum _PrivacyFilter { all, localOnly, syncAllowed, aiAllowed }

extension on _DateWindow {
  String get analyticsKey {
    switch (this) {
      case _DateWindow.all:
        return 'all';
      case _DateWindow.last7Days:
        return 'last_7_days';
      case _DateWindow.last30Days:
        return 'last_30_days';
      case _DateWindow.last90Days:
        return 'last_90_days';
    }
  }
}

extension on _PrivacyFilter {
  String get analyticsKey {
    switch (this) {
      case _PrivacyFilter.all:
        return 'all';
      case _PrivacyFilter.localOnly:
        return DataPermission.localOnly.storageKey;
      case _PrivacyFilter.syncAllowed:
        return DataPermission.syncAllowed.storageKey;
      case _PrivacyFilter.aiAllowed:
        return DataPermission.aiAllowed.storageKey;
    }
  }
}

String _queryLengthBucket(String query) {
  final length = query.trim().length;
  if (length <= 50) {
    return '1_50';
  }
  if (length <= 200) {
    return '51_200';
  }
  return '200_plus';
}

String _dateWindowLabel(_DateWindow value, AppLocalizations l10n) {
  switch (value) {
    case _DateWindow.all:
      return l10n.lifeGraphFilterAll;
    case _DateWindow.last7Days:
      return l10n.lifeGraphFilterDate7d;
    case _DateWindow.last30Days:
      return l10n.lifeGraphFilterDate30d;
    case _DateWindow.last90Days:
      return l10n.lifeGraphFilterDate90d;
  }
}

String _privacyFilterLabel(_PrivacyFilter value, AppLocalizations l10n) {
  switch (value) {
    case _PrivacyFilter.all:
      return l10n.lifeGraphFilterAll;
    case _PrivacyFilter.localOnly:
      return l10n.permissionLocal;
    case _PrivacyFilter.syncAllowed:
      return l10n.permissionSync;
    case _PrivacyFilter.aiAllowed:
      return l10n.permissionAi;
  }
}

String controllerLabel(String? selectedDomain, AppLocalizations l10n) {
  if (selectedDomain == null) {
    return l10n.lifeGraphFilterAll;
  }
  return selectedDomain.localizedDomainLabel(l10n);
}

String _dateGroupLabel(String iso, AppLocalizations l10n) {
  final date = DateTime.tryParse(iso)?.toLocal();
  if (date == null) {
    return iso.split('T').first;
  }
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final eventDay = DateTime(date.year, date.month, date.day);
  if (eventDay == today) {
    return l10n.labelToday;
  }
  if (eventDay == today.subtract(const Duration(days: 1))) {
    return pickLocalizedValue(
      l10n.localeName,
      en: 'Yesterday',
      es: 'Ayer',
      ptBr: 'Ontem',
      ptPt: 'Ontem',
      fr: 'Hier',
      it: 'Ieri',
      de: 'Gestern',
      ja: 'Yesterday',
      zhHans: 'Yesterday',
      zhHant: 'Yesterday',
    );
  }
  return iso.split('T').first;
}

GoLifeAccent _eventAccent(LifeEvent event) {
  if (event.domain == 'finance' || event.domain == 'money') {
    return GoLifeAccent.amber;
  }
  if (event.domain == 'pantry') {
    return GoLifeAccent.emerald;
  }
  if (event.domain == 'task') {
    return GoLifeAccent.violet;
  }
  return GoLifeAccent.blue;
}

GoLifeAccent _privacyAccent(String privacyLevel) {
  if (privacyLevel == DataPermission.aiAllowed.storageKey) {
    return GoLifeAccent.emerald;
  }
  if (privacyLevel == DataPermission.syncAllowed.storageKey) {
    return GoLifeAccent.blue;
  }
  return GoLifeAccent.amber;
}

String _memoryTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Memory',
      es: 'Memory',
      ptBr: 'Memory',
      ptPt: 'Memory',
      fr: 'Memory',
      it: 'Memory',
      de: 'Memory',
      ja: 'Memory',
      zhHans: 'Memory',
      zhHant: 'Memory',
    );

String _memorySubtitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Your recent life.',
      es: 'Tu vida reciente.',
      ptBr: 'Sua vida recente.',
      ptPt: 'A tua vida recente.',
      fr: 'Ta vie recente.',
      it: 'La tua vita recente.',
      de: 'Dein aktuelles Leben.',
      ja: 'Your recent life.',
      zhHans: 'Your recent life.',
      zhHant: 'Your recent life.',
    );

String _eventsLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Events',
      es: 'Eventos',
      ptBr: 'Eventos',
      ptPt: 'Eventos',
      fr: 'Evenements',
      it: 'Eventi',
      de: 'Ereignisse',
      ja: 'Events',
      zhHans: 'Events',
      zhHant: 'Events',
    );

String _usedByAiLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Usable by AI',
      es: 'Usables por IA',
      ptBr: 'Usaveis pela IA',
      ptPt: 'Usaveis pela IA',
      fr: 'Utilisables par IA',
      it: 'Usabili dall IA',
      de: 'Von KI nutzbar',
      ja: 'Usable by AI',
      zhHans: 'Usable by AI',
      zhHant: 'Usable by AI',
    );

String _protectedLocalLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Protected local',
      es: 'Protegidos local',
      ptBr: 'Protegidos no local',
      ptPt: 'Protegidos no local',
      fr: 'Proteges en local',
      it: 'Protetti in locale',
      de: 'Lokal geschuetzt',
      ja: 'Protected local',
      zhHans: 'Protected local',
      zhHant: 'Protected local',
    );

String _relationsLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Relations',
      es: 'Relaciones',
      ptBr: 'Relacoes',
      ptPt: 'Relacoes',
      fr: 'Relations',
      it: 'Relazioni',
      de: 'Beziehungen',
      ja: 'Relations',
      zhHans: 'Relations',
      zhHant: 'Relations',
    );

String _totalEventsLabel(int count, AppLocalizations l10n) =>
    pickLocalizedValue(
      l10n.localeName,
      en: '$count total',
      es: '$count total',
      ptBr: '$count total',
      ptPt: '$count total',
      fr: '$count total',
      it: '$count totale',
      de: '$count gesamt',
      ja: '$count total',
      zhHans: '$count total',
      zhHant: '$count total',
    );

String _evidenceCountLabel(
  int count,
  AppLocalizations l10n,
) =>
    pickLocalizedValue(
      l10n.localeName,
      en: '$count evidence',
      es: '$count evidencias',
      ptBr: '$count evidencias',
      ptPt: '$count evidencias',
      fr: '$count preuves',
      it: '$count evidenze',
      de: '$count Evidenzen',
      ja: '$count evidence',
      zhHans: '$count evidence',
      zhHant: '$count evidence',
    );

String _memorySearchTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Search memory',
      es: 'Buscar en memoria',
      ptBr: 'Buscar na memoria',
      ptPt: 'Procurar na memoria',
      fr: 'Rechercher dans la memoire',
      it: 'Cerca nella memoria',
      de: 'Erinnerung durchsuchen',
      ja: 'Search memory',
      zhHans: 'Search memory',
      zhHant: 'Search memory',
    );

String _memorySearchBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Search first, then narrow by domain, time or privacy.',
      es: 'Busca primero y luego ajusta por dominio, tiempo o privacidad.',
      ptBr:
          'Busque primeiro e depois ajuste por dominio, tempo ou privacidade.',
      ptPt:
          'Procura primeiro e depois ajusta por dominio, tempo ou privacidade.',
      fr: 'Cherche d abord puis affine par domaine, date ou confidentialite.',
      it: 'Cerca prima e poi restringi per dominio, tempo o privacy.',
      de: 'Erst suchen, dann nach Bereich, Zeit oder Datenschutz eingrenzen.',
      ja: 'Search first, then narrow by domain, time or privacy.',
      zhHans: 'Search first, then narrow by domain, time or privacy.',
      zhHant: 'Search first, then narrow by domain, time or privacy.',
    );

String _filtersLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Search and filters',
      es: 'Busqueda y filtros',
      ptBr: 'Busca e filtros',
      ptPt: 'Pesquisa e filtros',
      fr: 'Recherche et filtres',
      it: 'Ricerca e filtri',
      de: 'Suche und Filter',
      ja: 'Search and filters',
      zhHans: 'Search and filters',
      zhHant: 'Search and filters',
    );

String _filtersBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Keep the timeline readable on a small screen.',
      es: 'Mantiene la timeline legible en pantalla pequena.',
      ptBr: 'Mantem a timeline legivel em tela pequena.',
      ptPt: 'Mantem a timeline legivel em ecra pequeno.',
      fr: 'Garde la timeline lisible sur petit ecran.',
      it: 'Mantiene la timeline leggibile su schermo piccolo.',
      de: 'Haelt die Timeline auf kleinen Bildschirmen lesbar.',
      ja: 'Keep the timeline readable on a small screen.',
      zhHans: 'Keep the timeline readable on a small screen.',
      zhHant: 'Keep the timeline readable on a small screen.',
    );

String _domainFilterTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Domain',
      es: 'Dominio',
      ptBr: 'Dominio',
      ptPt: 'Dominio',
      fr: 'Domaine',
      it: 'Dominio',
      de: 'Bereich',
      ja: 'Domain',
      zhHans: 'Domain',
      zhHant: 'Domain',
    );

String _dateFilterTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Time',
      es: 'Tiempo',
      ptBr: 'Tempo',
      ptPt: 'Tempo',
      fr: 'Temps',
      it: 'Tempo',
      de: 'Zeit',
      ja: 'Time',
      zhHans: 'Time',
      zhHant: 'Time',
    );

String _domainsTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Domains',
      es: 'Dominios',
      ptBr: 'Dominios',
      ptPt: 'Dominios',
      fr: 'Domaines',
      it: 'Domini',
      de: 'Bereiche',
      ja: 'Domains',
      zhHans: 'Domains',
      zhHant: 'Domains',
    );

String _domainsBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'These routes still exist, but Memory keeps them in one place.',
      es: 'Estas rutas siguen existiendo, pero Memory las mantiene en un solo lugar.',
      ptBr:
          'Essas rotas continuam existindo, mas o Memory as mantem num so lugar.',
      ptPt:
          'Estas rotas continuam a existir, mas o Memory mantem-nas num so lugar.',
      fr: 'Ces routes existent toujours, mais Memory les garde au meme endroit.',
      it: 'Queste rotte esistono ancora, ma Memory le tiene insieme.',
      de: 'Diese Routen existieren weiter, aber Memory haelt sie an einem Ort.',
      ja: 'These routes still exist, but Memory keeps them in one place.',
      zhHans: 'These routes still exist, but Memory keeps them in one place.',
      zhHant: 'These routes still exist, but Memory keeps them in one place.',
    );

String _timelineTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Timeline',
      es: 'Timeline',
      ptBr: 'Timeline',
      ptPt: 'Timeline',
      fr: 'Timeline',
      it: 'Timeline',
      de: 'Timeline',
      ja: 'Timeline',
      zhHans: 'Timeline',
      zhHant: 'Timeline',
    );

String _timelineBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Readable cards first. Detail only when you ask for it.',
      es: 'Cards legibles primero. El detalle solo cuando lo pides.',
      ptBr: 'Cards legiveis primeiro. O detalhe so quando voce pedir.',
      ptPt: 'Cards legiveis primeiro. O detalhe so quando pedires.',
      fr: 'Des cartes lisibles d abord. Le detail seulement si tu le demandes.',
      it: 'Carte leggibili prima. Il dettaglio solo quando lo chiedi.',
      de: 'Zuerst lesbare Karten. Details nur auf Wunsch.',
      ja: 'Readable cards first. Detail only when you ask for it.',
      zhHans: 'Readable cards first. Detail only when you ask for it.',
      zhHant: 'Readable cards first. Detail only when you ask for it.',
    );

String _emptyMemoryTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'No memory yet',
      es: 'Todavia no hay memoria',
      ptBr: 'Ainda nao ha memoria',
      ptPt: 'Ainda nao ha memoria',
      fr: 'Pas encore de memoire',
      it: 'Nessuna memoria ancora',
      de: 'Noch keine Erinnerung',
      ja: 'No memory yet',
      zhHans: 'No memory yet',
      zhHant: 'No memory yet',
    );

String _detailsLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Details',
      es: 'Detalles',
      ptBr: 'Detalhes',
      ptPt: 'Detalhes',
      fr: 'Details',
      it: 'Dettagli',
      de: 'Details',
      ja: 'Details',
      zhHans: 'Details',
      zhHant: 'Details',
    );

String _usedInMissionLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Used in mission',
      es: 'Usado en mision',
      ptBr: 'Usado na missao',
      ptPt: 'Usado na missao',
      fr: 'Utilise dans la mission',
      it: 'Usato nella missione',
      de: 'In Mission verwendet',
      ja: 'Used in mission',
      zhHans: 'Used in mission',
      zhHant: 'Used in mission',
    );

String _privacyChangeTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Privacy',
      es: 'Privacidad',
      ptBr: 'Privacidade',
      ptPt: 'Privacidade',
      fr: 'Confidentialite',
      it: 'Privacy',
      de: 'Datenschutz',
      ja: 'Privacy',
      zhHans: 'Privacy',
      zhHant: 'Privacy',
    );

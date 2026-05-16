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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final allEvents = widget.controller.lifeEvents;
    final viewModels = _buildViewModels(allEvents);
    final grouped = _groupByDate(viewModels);
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.lifeGraphTitle,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.lifeGraphIntro,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => context.go('/settings'),
                icon: const Icon(Icons.verified_user_outlined),
                label: Text(l10n.lifeGraphOpenPrivacyAudit),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: _MetricCard(
                  label: l10n.lifeGraphMetricVisibleEvents,
                  value: '${viewModels.length}/${allEvents.length}',
                  tone: const Color(0xFF1F4C5B),
                ),
              ),
              SizedBox(
                width: 220,
                child: _MetricCard(
                  label: l10n.lifeGraphMetricEvidenceItems,
                  value: visibleEvidenceIds.length.toString(),
                  tone: const Color(0xFF6C5B3D),
                ),
              ),
              SizedBox(
                width: 220,
                child: _MetricCard(
                  label: l10n.lifeGraphMetricRelations,
                  value: visibleRelationIds.length.toString(),
                  tone: const Color(0xFF7A5167),
                ),
              ),
              SizedBox(
                width: 220,
                child: _MetricCard(
                  label: l10n.lifeGraphMetricAuditEntries,
                  value: visibleAuditIds.length.toString(),
                  tone: const Color(0xFF5D7A68),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(theme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.lifeGraphFiltersTitle,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.lifeGraphFiltersBody,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const ValueKey<String>('lifegraph-search-field'),
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.trim()),
                  decoration: InputDecoration(
                    hintText: l10n.lifeGraphSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? const Color(0xFF211915)
                        : const Color(0xFFF6EEE7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _FilterSection(
                  title: l10n.lifeGraphFilterDomainTitle,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.lifeGraphFilterAll),
                      selected: _selectedDomain == null,
                      onSelected: (_) => setState(() => _selectedDomain = null),
                    ),
                    for (final domain in _distinctDomains(allEvents))
                      ChoiceChip(
                        label: Text(domain.localizedDomainLabel(l10n)),
                        selected: _selectedDomain == domain,
                        onSelected: (_) =>
                            setState(() => _selectedDomain = domain),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _FilterSection(
                  title: l10n.lifeGraphFilterDateTitle,
                  children: [
                    for (final window in _DateWindow.values)
                      ChoiceChip(
                        label: Text(_dateWindowLabel(window, l10n)),
                        selected: _dateWindow == window,
                        onSelected: (_) => setState(() => _dateWindow = window),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _FilterSection(
                  title: l10n.lifeGraphFilterPrivacyTitle,
                  children: [
                    for (final filter in _PrivacyFilter.values)
                      ChoiceChip(
                        label: Text(_privacyFilterLabel(filter, l10n)),
                        selected: _privacyFilter == filter,
                        onSelected: (_) =>
                            setState(() => _privacyFilter = filter),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.lifeGraphTimelineTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.lifeGraphTimelineBody,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (viewModels.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(theme),
              child: Text(
                l10n.lifeGraphNoEvents,
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            for (final entry in grouped.entries) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  l10n.lifeGraphDateGroupTitle(entry.key, entry.value.length),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              for (final item in entry.value)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LifeGraphEventCard(
                    viewModel: item,
                    controller: widget.controller,
                  ),
                ),
            ],
        ],
      ),
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
  ) {
    final grouped = <String, List<_LifeGraphEventViewModel>>{};
    for (final item in items) {
      final dateLabel = item.event.timestampIso.split('T').first;
      grouped
          .putIfAbsent(dateLabel, () => <_LifeGraphEventViewModel>[])
          .add(item);
    }
    return grouped;
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(value, style: theme.textTheme.headlineSmall),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      ],
    );
  }
}

class _LifeGraphEventCard extends StatelessWidget {
  const _LifeGraphEventCard({
    required this.viewModel,
    required this.controller,
  });

  final _LifeGraphEventViewModel viewModel;
  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final event = viewModel.event;
    final aiEligible = _isEventAiEligible(controller, event);
    final latestAudit =
        viewModel.auditEntries.isEmpty ? null : viewModel.auditEntries.first;

    return Container(
      key: ValueKey<String>('lifegraph-event-${event.eventId}'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.summary, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '${event.timestampIso} | ${event.eventType}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(
                    '${l10n.fieldDomain}: ${event.domain.localizedDomainLabel(l10n)}'),
              ),
              Chip(
                label: Text(
                    '${l10n.fieldPrivacy}: ${event.privacyLevel.localizedPermissionLabel(l10n)}'),
              ),
              Chip(
                label: Text('${l10n.privacyEventSource}: ${event.source}'),
              ),
              Chip(
                label: Text(
                  '${l10n.privacyEventAiEligible}: ${aiEligible ? l10n.valueYes : l10n.valueNo}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.lifeGraphEvidenceTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (viewModel.evidenceItems.isEmpty)
            Text(l10n.lifeGraphEvidenceEmpty, style: theme.textTheme.bodyMedium)
          else
            for (final evidence in viewModel.evidenceItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '- ${evidence.sourceType} | ${evidence.privacyClass.storageKey} | ${evidence.hash}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
          const SizedBox(height: 16),
          Text(l10n.lifeGraphRelationsTitle,
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (viewModel.relations.isEmpty)
            Text(l10n.lifeGraphRelationsEmpty,
                style: theme.textTheme.bodyMedium)
          else
            for (final relation in viewModel.relations)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '- ${relation.relationType} -> ${viewModel.relatedEventLabel(relation, l10n)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
          const SizedBox(height: 16),
          Text(l10n.privacyAuditTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (latestAudit == null)
            Text(l10n.lifeGraphAuditNone, style: theme.textTheme.bodyMedium)
          else
            Container(
              key: ValueKey<String>('lifegraph-audit-${event.eventId}'),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EEE7).withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.12 : 1,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${latestAudit.oldPrivacyLevel.localizedPermissionLabel(l10n)} -> ${latestAudit.newPrivacyLevel.localizedPermissionLabel(l10n)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${l10n.privacyAuditChangedAt}: ${latestAudit.changedAt}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/settings'),
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(l10n.lifeGraphOpenPrivacyAudit),
            ),
          ),
        ],
      ),
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

  String relatedEventLabel(
    LifeGraphRelation relation,
    AppLocalizations l10n,
  ) {
    final relatedId = relation.fromEventId == event.eventId
        ? relation.toEventId
        : relation.fromEventId;
    final relatedEvent = relatedEventsById[relatedId];
    if (relatedEvent == null) {
      return relatedId;
    }
    return '${relatedEvent.summary} (${relatedEvent.domain.localizedDomainLabel(l10n)})';
  }
}

enum _DateWindow {
  all,
  last7Days,
  last30Days,
  last90Days,
}

enum _PrivacyFilter {
  all,
  localOnly,
  syncAllowed,
  aiAllowed,
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

bool _isEventAiEligible(GoLifeController controller, LifeEvent event) {
  final domain = domainKeyFromWireName(event.domain);
  if (domain == null) {
    return false;
  }
  return controller.privacySettings.permissionFor(domain) ==
          DataPermission.aiAllowed &&
      event.privacyLevel == DataPermission.aiAllowed.storageKey;
}

BoxDecoration _cardDecoration(ThemeData theme) {
  final isDark = theme.brightness == Brightness.dark;
  return BoxDecoration(
    color: isDark
        ? const Color(0xFF241C18).withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.76),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: isDark ? const Color(0x33E6CDB9) : const Color(0x12FFFFFF),
    ),
  );
}

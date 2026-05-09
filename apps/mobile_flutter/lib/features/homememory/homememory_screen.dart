import 'package:flutter/material.dart';

import '../../core/i18n/app_localized_values.dart';
import '../../core/privacy/privacy_models.dart';
import '../../domains/homememory/claim_draft.dart';
import '../../domains/homememory/evidence_attachment.dart';
import '../../domains/homememory/maintenance_reminder.dart';
import '../../domains/homememory/owned_item.dart';
import '../../domains/homememory/purchase_proof.dart';
import '../../domains/homememory/warranty_record.dart';
import '../../l10n/app_localizations.dart';
import '../app_state/golife_controller.dart';

class HomeMemoryScreen extends StatelessWidget {
  const HomeMemoryScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeMemoryEyebrow.toUpperCase(),
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          Text(l10n.homeMemoryTitle, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            l10n.homeMemorySubtitle,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeMemoryDisclosureTitle,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.homeMemoryDisclosureBody,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SummaryCard(
                title: l10n.homeMemoryWarrantySoonTitle,
                value: controller.warrantyEndingSoonItems.length.toString(),
                subtitle: controller.warrantyEndingSoonItems.isEmpty
                    ? l10n.homeMemoryWarrantySoonEmpty
                    : _compactWarrantyDate(
                        controller.warrantyEndingSoonItems.first.warrantyUntil,
                        l10n,
                      ),
              ),
              _SummaryCard(
                title: l10n.homeMemoryRecentProofsTitle,
                value: controller.recentPurchaseProofs.length.toString(),
                subtitle: controller.recentPurchaseProofs.isEmpty
                    ? l10n.homeMemoryRecentProofsEmpty
                    : controller.recentPurchaseProofs.first.merchantName,
              ),
              _SummaryCard(
                title: l10n.homeMemoryRemindersTitle,
                value:
                    controller.upcomingMaintenanceReminders.length.toString(),
                subtitle: controller.upcomingMaintenanceReminders.isEmpty
                    ? l10n.homeMemoryRemindersEmpty
                    : controller.upcomingMaintenanceReminders.first.title,
              ),
              _SummaryCard(
                title: l10n.homeMemoryClaimsTitle,
                value: controller.activeClaimDrafts.length.toString(),
                subtitle: controller.activeClaimDrafts.isEmpty
                    ? l10n.homeMemoryClaimsEmpty
                    : controller.activeClaimDrafts.first.title,
              ),
            ],
          ),
          if (controller.homeMemoryMentalLoadItems.isNotEmpty) ...[
            const SizedBox(height: 20),
            _HomeMemoryDerivedPanel(
              title: _homeMemorySignalsTitle(l10n),
              body: _homeMemorySignalsBody(l10n),
              children: controller.homeMemoryMentalLoadItems
                  .take(3)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '- ${item.title}: ${item.summary}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          if (controller.homeMemoryDecisionCards.isNotEmpty) ...[
            const SizedBox(height: 20),
            _HomeMemoryDerivedPanel(
              title: _homeMemoryGeneratedDecisionsTitle(l10n),
              body: _homeMemoryGeneratedDecisionsBody(l10n),
              children: controller.homeMemoryDecisionCards
                  .take(3)
                  .map(
                    (card) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '- ${card.title}: ${card.recommendedAction}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => _showOwnedItemEditor(context, controller),
                icon: const Icon(Icons.inventory_2_outlined),
                label: Text(l10n.homeMemoryActionAddItem),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _showManualProofEditor(context, controller),
                icon: const Icon(Icons.receipt_long_outlined),
                label: Text(l10n.homeMemoryActionAddProof),
              ),
              OutlinedButton.icon(
                onPressed: controller.ownedItems.isEmpty
                    ? null
                    : () => _showReminderEditor(context, controller),
                icon: const Icon(Icons.event_repeat_outlined),
                label: Text(l10n.homeMemoryActionCreateReminder),
              ),
              OutlinedButton.icon(
                onPressed: controller.ownedItems.isEmpty
                    ? null
                    : () => _showClaimDraftEditor(context, controller),
                icon: const Icon(Icons.gavel_outlined),
                label: Text(l10n.homeMemoryActionDraftClaim),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.homeMemoryItemsTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (controller.ownedItems.isEmpty)
            Text(
              l10n.homeMemoryItemsEmpty,
              style: theme.textTheme.bodyLarge,
            )
          else
            Column(
              children: controller.ownedItems.map((item) {
                final warranty = controller.warrantyRecordForItem(item.id);
                final proofs = controller.purchaseProofsForItem(item.id);
                final reminders =
                    controller.maintenanceRemindersForItem(item.id);
                final claims = controller.claimDraftsForItem(item.id);
                final evidence = controller.evidenceAttachmentsForItem(item.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OwnedItemCard(
                    item: item,
                    warranty: warranty,
                    proofs: proofs,
                    reminders: reminders,
                    claims: claims,
                    evidence: evidence,
                    onReminder: () => _showReminderEditor(
                      context,
                      controller,
                      initialItemId: item.id,
                    ),
                    onClaim: () => _showClaimDraftEditor(
                      context,
                      controller,
                      initialItemId: item.id,
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
        ],
      ),
    );
  }
}

class _HomeMemoryDerivedPanel extends StatelessWidget {
  const _HomeMemoryDerivedPanel({
    required this.title,
    required this.body,
    required this.children,
  });

  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F0E4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

String _homeMemorySignalsTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Derived review signals',
      es: 'Senales de revision derivadas',
      ptBr: 'Sinais de revisao derivados',
      ptPt: 'Sinais de revisao derivados',
      fr: 'Signaux de revision derives',
      it: 'Segnali di revisione derivati',
      de: 'Abgeleitete Pruefsignale',
      ja: 'Derived review signals',
      zhHans: 'Derived review signals',
      zhHant: 'Derived review signals',
    );

String _homeMemorySignalsBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Warranty, maintenance, and claim events can become local mental-load items before any external action is considered.',
      es: 'Garantias, mantenimiento y reclamaciones pueden convertirse en carga mental local antes de considerar cualquier accion externa.',
      ptBr: 'Garantia, manutencao e reclamacoes podem virar carga mental local antes de qualquer acao externa.',
      ptPt: 'Garantia, manutencao e reclamacoes podem virar carga mental local antes de qualquer acao externa.',
      fr: 'Garantie, maintenance et reclamations peuvent devenir une charge mentale locale avant toute action externe.',
      it: 'Garanzie, manutenzione e reclami possono diventare carico mentale locale prima di qualsiasi azione esterna.',
      de: 'Garantie-, Wartungs- und Reklamationsereignisse koennen zuerst als lokale mentale Last sichtbar werden.',
      ja: 'Derived review signals',
      zhHans: 'Derived review signals',
      zhHant: 'Derived review signals',
    );

String _homeMemoryGeneratedDecisionsTitle(AppLocalizations l10n) =>
    pickLocalizedValue(
      l10n.localeName,
      en: 'Generated decisions',
      es: 'Decisiones generadas',
      ptBr: 'Decisoes geradas',
      ptPt: 'Decisoes geradas',
      fr: 'Decisions generees',
      it: 'Decisioni generate',
      de: 'Generierte Entscheidungen',
      ja: 'Generated decisions',
      zhHans: 'Generated decisions',
      zhHant: 'Generated decisions',
    );

String _homeMemoryGeneratedDecisionsBody(AppLocalizations l10n) =>
    pickLocalizedValue(
      l10n.localeName,
      en: 'GoLife can turn HomeMemory signals into decision cards while still requiring human confirmation for anything external.',
      es: 'GoLife puede convertir senales de HomeMemory en tarjetas de decision, manteniendo la confirmacion humana para cualquier accion externa.',
      ptBr: 'GoLife pode transformar sinais do HomeMemory em cartoes de decisao, mantendo confirmacao humana para acoes externas.',
      ptPt: 'GoLife pode transformar sinais do HomeMemory em cartoes de decisao, mantendo confirmacao humana para acoes externas.',
      fr: 'GoLife peut transformer les signaux HomeMemory en cartes de decision tout en exigeant une confirmation humaine pour toute action externe.',
      it: 'GoLife puo trasformare i segnali di HomeMemory in decisioni, mantenendo la conferma umana per qualsiasi azione esterna.',
      de: 'GoLife kann HomeMemory-Signale in Entscheidungskarten umwandeln und verlangt weiterhin menschliche Bestaetigung fuer externe Aktionen.',
      ja: 'Generated decisions',
      zhHans: 'Generated decisions',
      zhHant: 'Generated decisions',
    );

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _OwnedItemCard extends StatelessWidget {
  const _OwnedItemCard({
    required this.item,
    required this.warranty,
    required this.proofs,
    required this.reminders,
    required this.claims,
    required this.evidence,
    required this.onReminder,
    required this.onClaim,
  });

  final OwnedItem item;
  final WarrantyRecord? warranty;
  final List<PurchaseProof> proofs;
  final List<MaintenanceReminder> reminders;
  final List<ClaimDraft> claims;
  final List<EvidenceAttachment> evidence;
  final VoidCallback onReminder;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final status = _warrantyStatusLabel(item, l10n);
    final warrantyRecord = warranty;
    final purchaseMeta = <String>[
      if (item.brand.isNotEmpty || item.model.isNotEmpty)
        [item.brand, item.model]
            .where((value) => value.trim().isNotEmpty)
            .join(' '),
      if (item.store.isNotEmpty) item.store,
      if (item.purchaseDate != null && item.purchaseDate!.isNotEmpty)
        item.purchaseDate!,
      if (item.warrantyUntil != null && item.warrantyUntil!.isNotEmpty)
        l10n.homeMemoryWarrantyUntilLabel(item.warrantyUntil!),
    ].where((value) => value.trim().isNotEmpty).join(' | ');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        title: Text(item.displayName, style: theme.textTheme.titleLarge),
        subtitle: Text(
          purchaseMeta.isEmpty ? l10n.homeMemoryItemNoMeta : purchaseMeta,
          style: theme.textTheme.bodyMedium,
        ),
        trailing: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatusChip(label: status),
            Text(item.privacyLevel.localizedPermissionLabel(l10n)),
          ],
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onReminder,
                  icon: const Icon(Icons.event_repeat_outlined),
                  label: Text(l10n.homeMemoryActionCreateReminder),
                ),
                FilledButton.tonalIcon(
                  onPressed: onClaim,
                  icon: const Icon(Icons.gavel_outlined),
                  label: Text(l10n.homeMemoryActionDraftClaim),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionBlock(
            title: l10n.homeMemorySectionItem,
            children: [
              _KeyValueRow(label: l10n.fieldCategory, value: item.category),
              _KeyValueRow(label: l10n.homeMemoryFieldStore, value: item.store),
              _KeyValueRow(
                label: l10n.homeMemoryFieldSerialNumber,
                value: item.serialNumber,
              ),
              _KeyValueRow(
                label: l10n.fieldNotes,
                value: item.notes,
                empty: l10n.homeMemoryNoNotes,
              ),
            ],
          ),
          _SectionBlock(
            title: l10n.homeMemorySectionProofs,
            children: proofs.isEmpty
                ? [Text(l10n.homeMemoryNoProofs)]
                : proofs
                    .map(
                      (proof) => Text(
                        '- ${proof.merchantName.isEmpty ? l10n.homeMemoryUnknownMerchant : proof.merchantName} | ${proof.purchaseDate ?? l10n.homeMemoryUnknownDate}',
                      ),
                    )
                    .toList(growable: false),
          ),
          _SectionBlock(
            title: l10n.homeMemorySectionWarranty,
            children: [
              if (warrantyRecord == null)
                Text(l10n.homeMemoryWarrantyUnknown)
              else ...[
                _KeyValueRow(
                  label: l10n.homeMemoryFieldWarrantyMonths,
                  value: warrantyRecord.warrantyMonths?.toString() ??
                      l10n.homeMemoryUnknownValue,
                ),
                _KeyValueRow(
                  label: l10n.homeMemoryFieldWarrantyUntil,
                  value: warrantyRecord.warrantyUntil ??
                      l10n.homeMemoryUnknownValue,
                ),
                Text(warrantyRecord.disclaimer),
              ],
            ],
          ),
          _SectionBlock(
            title: l10n.homeMemorySectionReminders,
            children: reminders.isEmpty
                ? [Text(l10n.homeMemoryNoReminders)]
                : reminders
                    .map((reminder) =>
                        Text('- ${reminder.title} | ${reminder.dueDate}'))
                    .toList(growable: false),
          ),
          _SectionBlock(
            title: l10n.homeMemorySectionClaims,
            children: claims.isEmpty
                ? [Text(l10n.homeMemoryNoClaims)]
                : claims
                    .map((claim) => Text('- ${claim.title} | ${claim.status}'))
                    .toList(growable: false),
          ),
          _SectionBlock(
            title: l10n.homeMemorySectionEvidence,
            children: evidence.isEmpty
                ? [Text(l10n.homeMemoryNoEvidence)]
                : evidence
                    .map((_) => Text(l10n.homeMemoryEvidencePresent))
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E6D8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({
    required this.label,
    required this.value,
    this.empty,
  });

  final String label;
  final String value;
  final String? empty;

  @override
  Widget build(BuildContext context) {
    final shown = value.trim().isEmpty ? (empty ?? '-') : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('$label: $shown'),
    );
  }
}

Future<void> _showOwnedItemEditor(
  BuildContext context,
  GoLifeController controller,
) {
  final l10n = AppLocalizations.of(context)!;
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final serialController = TextEditingController();
  final categoryController = TextEditingController(text: 'general');
  final storeController = TextEditingController();
  final purchaseDateController = TextEditingController(
    text: DateTime.now().toUtc().toIso8601String(),
  );
  final priceController = TextEditingController();
  final currencyController = TextEditingController(text: 'EUR');
  final warrantyMonthsController = TextEditingController();
  final notesController = TextEditingController();
  DataPermission privacy = DataPermission.localOnly;
  bool createReminder = false;

  return _showHomeMemoryDialog(
    context,
    title: l10n.homeMemoryActionAddItem,
    builder: (setState) => [
      TextField(
        controller: nameController,
        decoration: InputDecoration(labelText: l10n.homeMemoryFieldProductName),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: brandController,
        decoration: InputDecoration(labelText: l10n.homeMemoryFieldBrand),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: modelController,
        decoration: InputDecoration(labelText: l10n.homeMemoryFieldModel),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: serialController,
        decoration:
            InputDecoration(labelText: l10n.homeMemoryFieldSerialNumber),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: categoryController,
        decoration: InputDecoration(labelText: l10n.fieldCategory),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: storeController,
        decoration: InputDecoration(labelText: l10n.homeMemoryFieldStore),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: purchaseDateController,
        decoration:
            InputDecoration(labelText: l10n.homeMemoryFieldPurchaseDate),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: priceController,
        decoration: InputDecoration(labelText: l10n.homeMemoryFieldPrice),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: currencyController,
        decoration: InputDecoration(labelText: l10n.homeMemoryFieldCurrency),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: warrantyMonthsController,
        decoration:
            InputDecoration(labelText: l10n.homeMemoryFieldWarrantyMonths),
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<DataPermission>(
        initialValue: privacy,
        decoration: InputDecoration(labelText: l10n.fieldPrivacy),
        items: DataPermission.values
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(value.localizedLabel(l10n)),
              ),
            )
            .toList(growable: false),
        onChanged: (value) =>
            setState(() => privacy = value ?? DataPermission.localOnly),
      ),
      const SizedBox(height: 12),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: createReminder,
        title: Text(l10n.homeMemoryCreateWarrantyReminder),
        onChanged: (value) => setState(() => createReminder = value),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: notesController,
        decoration: InputDecoration(labelText: l10n.fieldNotes),
        minLines: 2,
        maxLines: 4,
      ),
    ],
    onSave: () async {
      final message = await controller.saveOwnedItemManual(
        name: nameController.text.trim(),
        brand: brandController.text.trim(),
        model: modelController.text.trim(),
        serialNumber: serialController.text.trim(),
        category: categoryController.text.trim(),
        purchaseDate: purchaseDateController.text.trim(),
        purchasePrice:
            double.tryParse(priceController.text.trim().replaceAll(',', '.')),
        currency: currencyController.text.trim(),
        store: storeController.text.trim(),
        warrantyMonths: int.tryParse(warrantyMonthsController.text.trim()),
        notes: notesController.text.trim(),
        privacyLevel: privacy.storageKey,
        createWarrantyReminder: createReminder,
      );
      return message ?? l10n.homeMemoryActionAddItem;
    },
  );
}

Future<void> _showManualProofEditor(
  BuildContext context,
  GoLifeController controller,
) {
  final l10n = AppLocalizations.of(context)!;
  final productNameController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final serialController = TextEditingController();
  final categoryController = TextEditingController(text: 'general');
  final storeController = TextEditingController();
  final purchaseDateController = TextEditingController(
    text: DateTime.now().toUtc().toIso8601String(),
  );
  final priceController = TextEditingController();
  final currencyController = TextEditingController(text: 'EUR');
  final warrantyMonthsController = TextEditingController();
  final notesController = TextEditingController();
  DataPermission privacy = DataPermission.localOnly;
  bool createReminder = true;

  return _showHomeMemoryDialog(
    context,
    title: l10n.homeMemoryActionAddProof,
    builder: (setState) => [
      TextField(
        controller: productNameController,
        decoration: InputDecoration(labelText: l10n.homeMemoryFieldProductName),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: brandController,
        decoration: InputDecoration(labelText: l10n.homeMemoryFieldBrand),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: modelController,
        decoration: InputDecoration(labelText: l10n.homeMemoryFieldModel),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: serialController,
        decoration:
            InputDecoration(labelText: l10n.homeMemoryFieldSerialNumber),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: categoryController,
        decoration: InputDecoration(labelText: l10n.fieldCategory),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: storeController,
        decoration: InputDecoration(labelText: l10n.homeMemoryFieldStore),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: purchaseDateController,
        decoration:
            InputDecoration(labelText: l10n.homeMemoryFieldPurchaseDate),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: priceController,
        decoration: InputDecoration(labelText: l10n.homeMemoryFieldPrice),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: currencyController,
        decoration: InputDecoration(labelText: l10n.homeMemoryFieldCurrency),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: warrantyMonthsController,
        decoration:
            InputDecoration(labelText: l10n.homeMemoryFieldWarrantyMonths),
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<DataPermission>(
        initialValue: privacy,
        decoration: InputDecoration(labelText: l10n.fieldPrivacy),
        items: DataPermission.values
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(value.localizedLabel(l10n)),
              ),
            )
            .toList(growable: false),
        onChanged: (value) =>
            setState(() => privacy = value ?? DataPermission.localOnly),
      ),
      const SizedBox(height: 12),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: createReminder,
        title: Text(l10n.homeMemoryCreateWarrantyReminder),
        onChanged: (value) => setState(() => createReminder = value),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: notesController,
        decoration: InputDecoration(labelText: l10n.fieldNotes),
        minLines: 2,
        maxLines: 4,
      ),
    ],
    onSave: () async {
      final message = await controller.saveManualPurchaseProof(
        productName: productNameController.text.trim(),
        brand: brandController.text.trim(),
        model: modelController.text.trim(),
        serialNumber: serialController.text.trim(),
        category: categoryController.text.trim(),
        store: storeController.text.trim(),
        purchaseDate: purchaseDateController.text.trim(),
        price:
            double.tryParse(priceController.text.trim().replaceAll(',', '.')),
        currency: currencyController.text.trim(),
        warrantyMonths: int.tryParse(warrantyMonthsController.text.trim()),
        notes: notesController.text.trim(),
        privacyLevel: privacy.storageKey,
        createWarrantyReminder: createReminder,
      );
      return message ?? l10n.homeMemoryActionAddProof;
    },
  );
}

Future<void> _showReminderEditor(
  BuildContext context,
  GoLifeController controller, {
  String? initialItemId,
}) {
  final l10n = AppLocalizations.of(context)!;
  String selectedItemId = initialItemId ??
      (controller.ownedItems.isEmpty ? '' : controller.ownedItems.first.id);
  final titleController = TextEditingController(
    text: l10n.homeMemoryDefaultReminderTitle,
  );
  final dueDateController = TextEditingController(
    text:
        DateTime.now().toUtc().add(const Duration(days: 14)).toIso8601String(),
  );
  final recurrenceController = TextEditingController(text: 'none');

  return _showHomeMemoryDialog(
    context,
    title: l10n.homeMemoryActionCreateReminder,
    builder: (setState) => [
      DropdownButtonFormField<String>(
        initialValue: selectedItemId.isEmpty ? null : selectedItemId,
        decoration: InputDecoration(labelText: l10n.homeMemorySelectItem),
        items: controller.ownedItems
            .map(
              (item) => DropdownMenuItem(
                value: item.id,
                child: Text(item.displayName),
              ),
            )
            .toList(growable: false),
        onChanged: (value) => setState(() => selectedItemId = value ?? ''),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: titleController,
        decoration: InputDecoration(labelText: l10n.fieldTitle),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: dueDateController,
        decoration: InputDecoration(labelText: l10n.homeMemoryFieldDueDate),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: recurrenceController,
        decoration: InputDecoration(labelText: l10n.homeMemoryFieldRecurrence),
      ),
    ],
    onSave: () async {
      final message = await controller.saveMaintenanceReminder(
        ownedItemId: selectedItemId,
        title: titleController.text.trim(),
        dueDate: dueDateController.text.trim(),
        recurrence: recurrenceController.text.trim(),
      );
      return message ?? l10n.homeMemoryActionCreateReminder;
    },
  );
}

Future<void> _showClaimDraftEditor(
  BuildContext context,
  GoLifeController controller, {
  String? initialItemId,
}) {
  final l10n = AppLocalizations.of(context)!;
  String selectedItemId = initialItemId ??
      (controller.ownedItems.isEmpty ? '' : controller.ownedItems.first.id);
  final issueController = TextEditingController();
  final recipientController = TextEditingController();

  return _showHomeMemoryDialog(
    context,
    title: l10n.homeMemoryActionDraftClaim,
    builder: (setState) => [
      DropdownButtonFormField<String>(
        initialValue: selectedItemId.isEmpty ? null : selectedItemId,
        decoration: InputDecoration(labelText: l10n.homeMemorySelectItem),
        items: controller.ownedItems
            .map(
              (item) => DropdownMenuItem(
                value: item.id,
                child: Text(item.displayName),
              ),
            )
            .toList(growable: false),
        onChanged: (value) => setState(() => selectedItemId = value ?? ''),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: issueController,
        decoration:
            InputDecoration(labelText: l10n.homeMemoryFieldIssueDescription),
        minLines: 3,
        maxLines: 5,
      ),
      const SizedBox(height: 12),
      TextField(
        controller: recipientController,
        decoration:
            InputDecoration(labelText: l10n.homeMemoryFieldRecipientHint),
      ),
      const SizedBox(height: 12),
      Text(
        l10n.homeMemoryClaimDisclaimer,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ],
    onSave: () async {
      final message = await controller.saveClaimDraft(
        ownedItemId: selectedItemId,
        issueDescription: issueController.text.trim(),
        recipientHint: recipientController.text.trim(),
      );
      return message ?? l10n.homeMemoryActionDraftClaim;
    },
  );
}

Future<void> _showHomeMemoryDialog(
  BuildContext context, {
  required String title,
  required List<Widget> Function(void Function(VoidCallback fn) setState)
      builder,
  required Future<String> Function() onSave,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      bool saving = false;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: builder(setState),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    saving ? null : () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        setState(() => saving = true);
                        final message = await onSave();
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      },
                child: Text(
                  saving ? l10n.actionSaving : l10n.actionSave,
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

String _compactWarrantyDate(String? rawDate, AppLocalizations l10n) {
  if (rawDate == null || rawDate.isEmpty) {
    return l10n.homeMemoryUnknownValue;
  }
  return rawDate;
}

String _warrantyStatusLabel(OwnedItem item, AppLocalizations l10n) {
  final rawDate = item.warrantyUntil;
  if (rawDate == null || rawDate.isEmpty) {
    return l10n.homeMemoryWarrantyStatusUnknown;
  }
  final warrantyDate = DateTime.tryParse(rawDate)?.toUtc();
  if (warrantyDate == null) {
    return l10n.homeMemoryWarrantyStatusUnknown;
  }
  if (warrantyDate.isBefore(DateTime.now().toUtc())) {
    return l10n.homeMemoryWarrantyStatusExpired;
  }
  return l10n.homeMemoryWarrantyStatusActive;
}

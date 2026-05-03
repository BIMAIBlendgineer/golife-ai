import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/domains/homememory/claim_draft.dart';
import 'package:golife_flutter/domains/homememory/evidence_attachment.dart';
import 'package:golife_flutter/domains/homememory/maintenance_reminder.dart';
import 'package:golife_flutter/domains/homememory/owned_item.dart';
import 'package:golife_flutter/domains/homememory/purchase_proof.dart';
import 'package:golife_flutter/domains/homememory/warranty_record.dart';

void main() {
  test('OwnedItem serializes and deserializes', () {
    const item = OwnedItem(
      id: 'item-1',
      userId: 'user-1',
      name: 'Dyson V8',
      brand: 'Dyson',
      model: 'V8',
      serialNumber: 'SN-123',
      category: 'appliance',
      purchaseDate: '2026-04-10',
      purchasePrice: 249.99,
      currency: 'USD',
      store: 'Amazon',
      warrantyUntil: '2028-04-10',
      warrantySource: WarrantySource.explicit,
      proofIds: <String>['proof-1'],
      maintenanceReminderIds: <String>['reminder-1'],
      claimDraftIds: <String>['claim-1'],
      notes: 'Keep receipt local.',
      privacyLevel: 'local_only',
      createdAt: '2026-04-10T10:00:00Z',
      updatedAt: '2026-04-10T10:00:00Z',
    );

    final decoded = OwnedItem.fromJson(item.toJson());

    expect(decoded.name, item.name);
    expect(decoded.brand, item.brand);
    expect(decoded.notes, item.notes);
    expect(decoded.proofIds, item.proofIds);
  });

  test('PurchaseProof serializes and deserializes', () {
    const proof = PurchaseProof(
      id: 'proof-1',
      userId: 'user-1',
      ownedItemId: 'item-1',
      sourceType: PurchaseProofSourceType.manualEntry,
      merchantName: 'Amazon',
      purchaseDate: '2026-04-10',
      totalAmount: 249.99,
      currency: 'USD',
      rawText: 'Bought Dyson V8 from Amazon on 2026-04-10 for 249.99 USD.',
      fileRef: 'proofs/receipt-1.txt',
      extractedFields: <String, Object?>{'product_name': 'Dyson V8'},
      privacyLevel: 'local_only',
      createdAt: '2026-04-10T10:00:00Z',
    );

    final decoded = PurchaseProof.fromJson(proof.toJson());

    expect(decoded.ownedItemId, proof.ownedItemId);
    expect(decoded.rawText, proof.rawText);
    expect(decoded.totalAmount, proof.totalAmount);
  });

  test('WarrantyRecord serializes and deserializes', () {
    const record = WarrantyRecord(
      id: 'warranty-1',
      userId: 'user-1',
      ownedItemId: 'item-1',
      warrantyUntil: '2028-04-10',
      warrantySource: WarrantySource.explicit,
      warrantyMonths: 24,
      disclaimer: 'Verify with seller.',
      createdAt: '2026-04-10T10:00:00Z',
    );

    final decoded = WarrantyRecord.fromJson(record.toJson());

    expect(decoded.warrantyUntil, record.warrantyUntil);
    expect(decoded.warrantyMonths, 24);
  });

  test('MaintenanceReminder serializes and deserializes', () {
    const reminder = MaintenanceReminder(
      id: 'reminder-1',
      userId: 'user-1',
      ownedItemId: 'item-1',
      title: 'Review warranty before expiration',
      dueDate: '2028-03-27',
      recurrence: 'none',
      status: MaintenanceReminderStatus.scheduled,
      createdAt: '2026-04-10T10:00:00Z',
    );

    final decoded = MaintenanceReminder.fromJson(reminder.toJson());

    expect(decoded.title, reminder.title);
    expect(decoded.status, MaintenanceReminderStatus.scheduled);
  });

  test('ClaimDraft serializes and deserializes', () {
    const draft = ClaimDraft(
      id: 'claim-1',
      userId: 'user-1',
      ownedItemId: 'item-1',
      title: 'Warranty claim for Dyson V8',
      issueDescription: 'Battery stopped charging.',
      generatedMessage: 'Hello, I need support with my Dyson V8.',
      recipientHint: 'Amazon',
      status: ClaimDraftStatus.draft,
      disclaimer: 'No legal advice.',
      privacyLevel: 'local_only',
      createdAt: '2026-04-10T10:00:00Z',
    );

    final decoded = ClaimDraft.fromJson(draft.toJson());

    expect(decoded.title, draft.title);
    expect(decoded.issueDescription, draft.issueDescription);
    expect(decoded.status, ClaimDraftStatus.draft);
  });

  test('EvidenceAttachment serializes and deserializes', () {
    const attachment = EvidenceAttachment(
      id: 'evidence-1',
      userId: 'user-1',
      ownedItemId: 'item-1',
      proofId: 'proof-1',
      type: EvidenceAttachmentType.receipt,
      fileRef: 'files/receipt-1.jpg',
      description: 'Front receipt photo',
      privacyLevel: 'local_only',
      createdAt: '2026-04-10T10:00:00Z',
    );

    final decoded = EvidenceAttachment.fromJson(attachment.toJson());

    expect(decoded.type, EvidenceAttachmentType.receipt);
    expect(decoded.fileRef, attachment.fileRef);
    expect(decoded.description, attachment.description);
  });
}

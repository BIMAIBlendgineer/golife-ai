import 'billing_runtime_models.dart';

abstract class BillingProviderAdapter {
  Stream<BillingPurchaseUpdate> get purchaseUpdates;

  Future<BillingActionResult> initialize();

  Future<List<BillingCatalogItem>> queryCatalog(
    Iterable<BillingCatalogConfig> catalog,
  );

  Future<BillingActionResult> buyProduct(String productId);

  Future<BillingActionResult> restorePurchases();

  Future<void> completePurchase(BillingPurchaseUpdate purchase);

  Future<void> dispose();
}

class DisabledBillingProviderAdapter implements BillingProviderAdapter {
  const DisabledBillingProviderAdapter();

  @override
  Stream<BillingPurchaseUpdate> get purchaseUpdates =>
      const Stream<BillingPurchaseUpdate>.empty();

  @override
  Future<BillingActionResult> initialize() async {
    return const BillingActionResult(
      statusCode: 'billing_disabled',
      message: 'Billing is disabled in this runtime.',
    );
  }

  @override
  Future<List<BillingCatalogItem>> queryCatalog(
    Iterable<BillingCatalogConfig> catalog,
  ) async {
    return const <BillingCatalogItem>[];
  }

  @override
  Future<BillingActionResult> buyProduct(String productId) async {
    return BillingActionResult(
      statusCode: 'billing_disabled',
      message: 'Billing is disabled in this runtime.',
      productId: productId,
    );
  }

  @override
  Future<BillingActionResult> restorePurchases() async {
    return const BillingActionResult(
      statusCode: 'billing_disabled',
      message: 'Billing is disabled in this runtime.',
    );
  }

  @override
  Future<void> completePurchase(BillingPurchaseUpdate purchase) async {}

  @override
  Future<void> dispose() async {}
}

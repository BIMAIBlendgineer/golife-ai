import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'billing_provider_adapter.dart';
import 'billing_runtime_models.dart';

class GooglePlayBillingAdapter implements BillingProviderAdapter {
  GooglePlayBillingAdapter({
    InAppPurchase? inAppPurchase,
  }) : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _inAppPurchase;
  final StreamController<BillingPurchaseUpdate> _purchaseController =
      StreamController<BillingPurchaseUpdate>.broadcast();
  final Map<String, ProductDetails> _productDetailsById =
      <String, ProductDetails>{};
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  bool _initialized = false;

  @override
  Stream<BillingPurchaseUpdate> get purchaseUpdates =>
      _purchaseController.stream;

  @override
  Future<BillingActionResult> initialize() async {
    if (!Platform.isAndroid) {
      return const BillingActionResult(
        statusCode: 'platform_unavailable',
        message: 'Google Play Billing sandbox is only available on Android.',
      );
    }
    if (_initialized) {
      return const BillingActionResult(
        statusCode: 'store_available',
        message: 'Google Play Billing adapter already initialized.',
      );
    }

    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      return const BillingActionResult(
        statusCode: 'store_unavailable',
        message: 'Google Play Billing is not available on this device.',
      );
    }

    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object error) {
        _purchaseController.add(
          BillingPurchaseUpdate(
            productId: '',
            purchaseToken: '',
            purchaseId: null,
            transactionDateIso: null,
            statusCode: 'purchase_error',
            restored: false,
            pendingCompletePurchase: false,
            trace: const <String, Object?>{
              'provider': 'google_play',
            },
            rawHandle: error,
            errorCode: 'purchase_stream_error',
            errorMessage: error.toString(),
          ),
        );
      },
    );
    _initialized = true;
    return const BillingActionResult(
      statusCode: 'store_available',
      message: 'Google Play Billing sandbox is reachable on this device.',
    );
  }

  @override
  Future<List<BillingCatalogItem>> queryCatalog(
    Iterable<BillingCatalogConfig> catalog,
  ) async {
    final productIds = catalog.map((item) => item.productId).toSet();
    if (productIds.isEmpty) {
      return const <BillingCatalogItem>[];
    }

    final response = await _inAppPurchase.queryProductDetails(productIds);
    _productDetailsById
      ..clear()
      ..addEntries(
        response.productDetails.map((item) => MapEntry(item.id, item)),
      );

    final planById = <String, BillingCatalogConfig>{
      for (final item in catalog) item.productId: item,
    };
    final items = <BillingCatalogItem>[];
    for (final product in response.productDetails) {
      final config = planById[product.id];
      if (config == null) {
        continue;
      }
      items.add(
        BillingCatalogItem(
          productId: product.id,
          plan: config.plan,
          title: product.title.isEmpty ? config.title : product.title,
          description: product.description.isEmpty
              ? config.description
              : product.description,
          priceLabel: product.price,
          trace: <String, Object?>{
            'provider': 'google_play',
            'platform_class': product.runtimeType.toString(),
            if (product is GooglePlayProductDetails)
              'product_type': product.productDetails.productType.name,
          },
        ),
      );
    }
    return items;
  }

  @override
  Future<BillingActionResult> buyProduct(String productId) async {
    final productDetails = _productDetailsById[productId];
    if (productDetails == null) {
      return BillingActionResult(
        statusCode: 'product_unavailable',
        message: 'No Google Play sandbox product was loaded for $productId.',
        productId: productId,
      );
    }
    final purchaseParam = PurchaseParam(productDetails: productDetails);
    final started = await _inAppPurchase.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
    return BillingActionResult(
      statusCode: started ? 'purchase_started' : 'purchase_declined',
      message: started
          ? 'Google Play sandbox purchase flow started.'
          : 'Google Play sandbox declined to start the purchase flow.',
      productId: productId,
    );
  }

  @override
  Future<BillingActionResult> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
    return const BillingActionResult(
      statusCode: 'restore_started',
      message: 'Google Play sandbox restore started.',
    );
  }

  @override
  Future<void> completePurchase(BillingPurchaseUpdate purchase) async {
    final rawHandle = purchase.rawHandle;
    if (rawHandle is PurchaseDetails && rawHandle.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(rawHandle);
    }
  }

  @override
  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    _productDetailsById.clear();
    if (!_purchaseController.isClosed) {
      await _purchaseController.close();
    }
    _initialized = false;
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      _purchaseController.add(_toPurchaseUpdate(purchaseDetails));
    }
  }

  BillingPurchaseUpdate _toPurchaseUpdate(PurchaseDetails purchaseDetails) {
    final trace = <String, Object?>{
      'provider': 'google_play',
      'purchase_source': purchaseDetails.verificationData.source,
      'status': purchaseDetails.status.name,
    };
    String purchaseToken =
        purchaseDetails.verificationData.serverVerificationData;
    if (purchaseDetails is GooglePlayPurchaseDetails && purchaseToken.isEmpty) {
      purchaseToken = purchaseDetails.billingClientPurchase.purchaseToken;
    }
    if (purchaseDetails is GooglePlayPurchaseDetails) {
      trace['order_id'] = purchaseDetails.billingClientPurchase.orderId;
      trace['purchase_state'] =
          purchaseDetails.billingClientPurchase.purchaseState.name;
    }

    return BillingPurchaseUpdate(
      productId: purchaseDetails.productID,
      purchaseToken: purchaseToken,
      purchaseId: purchaseDetails.purchaseID,
      transactionDateIso:
          _parseTransactionDate(purchaseDetails.transactionDate),
      statusCode: _statusCodeForPurchase(purchaseDetails),
      restored: purchaseDetails.status == PurchaseStatus.restored,
      pendingCompletePurchase: purchaseDetails.pendingCompletePurchase,
      trace: trace,
      rawHandle: purchaseDetails,
      errorCode: purchaseDetails.error?.code,
      errorMessage: purchaseDetails.error?.message,
    );
  }

  String _statusCodeForPurchase(PurchaseDetails purchaseDetails) {
    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        return 'purchase_pending';
      case PurchaseStatus.purchased:
        return 'purchase_purchased';
      case PurchaseStatus.restored:
        return 'purchase_restored';
      case PurchaseStatus.error:
        return 'purchase_error';
      case PurchaseStatus.canceled:
        return 'purchase_canceled';
    }
  }

  String? _parseTransactionDate(String? transactionDate) {
    if (transactionDate == null || transactionDate.isEmpty) {
      return null;
    }
    final epochMillis = int.tryParse(transactionDate);
    if (epochMillis == null) {
      return transactionDate;
    }
    return DateTime.fromMillisecondsSinceEpoch(epochMillis, isUtc: true)
        .toIso8601String();
  }
}

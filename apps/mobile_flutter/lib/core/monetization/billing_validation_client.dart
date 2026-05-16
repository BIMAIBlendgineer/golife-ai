import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../domains/monetization/entitlement.dart';
import 'billing_runtime_models.dart';

abstract class BillingValidationClient {
  Future<BillingValidationDecision?> validateGooglePlayPurchase({
    required MobileBillingConfig config,
    required BillingPurchaseUpdate purchase,
  });
}

class GooglePlayBillingValidationClient implements BillingValidationClient {
  GooglePlayBillingValidationClient({
    required Uri baseUri,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 6),
  })  : _baseUri = baseUri,
        _httpClient = httpClient ?? http.Client();

  Uri _baseUri;
  final http.Client _httpClient;
  final Duration timeout;

  void updateBaseUri(Uri baseUri) {
    _baseUri = baseUri;
  }

  @override
  Future<BillingValidationDecision?> validateGooglePlayPurchase({
    required MobileBillingConfig config,
    required BillingPurchaseUpdate purchase,
  }) async {
    final packageName = config.packageName;
    if (packageName == null || packageName.trim().isEmpty) {
      return null;
    }
    try {
      final response = await _httpClient
          .post(
            _endpoint(config.validationPath),
            headers: const <String, String>{
              'content-type': 'application/json',
            },
            body: jsonEncode(
              <String, Object?>{
                'provider': entitlementBillingProviderGooglePlay,
                'mode': config.mode.storageKey,
                'package_name': packageName,
                'product_id': purchase.productId,
                'purchase_token': purchase.purchaseToken,
                'purchase_id': purchase.purchaseId,
                'transaction_date_iso': purchase.transactionDateIso,
                'restored': purchase.restored,
                'purchase_status': purchase.statusCode,
                'trace': purchase.trace,
              },
            ),
          )
          .timeout(timeout);
      if (response.statusCode != 200) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return BillingValidationDecision.fromJson(decoded);
    } on TimeoutException {
      return null;
    } on SocketException {
      return null;
    } on http.ClientException {
      return null;
    } on FormatException {
      return null;
    }
  }

  Uri _endpoint(String path) {
    final normalizedBase = _baseUri.toString().endsWith('/')
        ? _baseUri.toString().substring(0, _baseUri.toString().length - 1)
        : _baseUri.toString();
    return Uri.parse('$normalizedBase$path');
  }
}

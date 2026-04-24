import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'app_runtime_config.dart';

class RuntimeConfigClient {
  RuntimeConfigClient({
    required Uri baseUri,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 4),
  })  : _baseUri = baseUri,
        _httpClient = httpClient ?? http.Client();

  Uri _baseUri;
  final http.Client _httpClient;
  final Duration timeout;

  Future<AppRuntimeConfig?> fetchRuntimeConfig() async {
    try {
      final response = await _httpClient
          .get(_endpoint('/public/mobile/runtime-config'))
          .timeout(timeout);

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return AppRuntimeConfig.fromJson(decoded);
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

  void updateBaseUri(Uri baseUri) {
    _baseUri = baseUri;
  }

  Uri _endpoint(String path) {
    final normalizedBase = _baseUri.toString().endsWith('/')
        ? _baseUri.toString().substring(0, _baseUri.toString().length - 1)
        : _baseUri.toString();
    return Uri.parse('$normalizedBase$path');
  }
}

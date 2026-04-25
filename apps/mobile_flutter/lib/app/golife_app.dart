import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/ai_client/ai_gateway_client.dart';
import '../core/i18n/app_locale.dart';
import '../core/lifegraph/lifegraph_repository.dart';
import '../core/runtime/runtime_config_client.dart';
import '../core/storage/local_store.dart';
import '../core/storage/memory_local_store.dart';
import '../core/storage/resilient_local_store.dart';
import '../core/storage/sqlite_local_store.dart';
import '../features/app_state/golife_controller.dart';
import '../l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/golife_theme.dart';

class GoLifeApp extends StatefulWidget {
  const GoLifeApp({
    super.key,
    this.localStore,
    this.aiGatewayClient,
    this.lifeGraphRepository,
  });

  final LocalStore? localStore;
  final AiGatewayClient? aiGatewayClient;
  final LifeGraphRepository? lifeGraphRepository;

  @override
  State<GoLifeApp> createState() => _GoLifeAppState();
}

class _GoLifeAppState extends State<GoLifeApp> with WidgetsBindingObserver {
  late final GoLifeController _controller;
  late final GoRouter _router;
  Timer? _runtimeConfigTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final resolvedLocalStore = widget.localStore ??
        ResilientLocalStore(
          primary: SqliteLocalStore(),
          fallback: MemoryLocalStore(),
        );
    final baseUrl = const String.fromEnvironment(
      'GOLIFE_AI_GATEWAY_BASE_URL',
      defaultValue: 'http://127.0.0.1:8000',
    );
    final runtimeConfigBaseUrl = const String.fromEnvironment(
      'GOLIFE_RUNTIME_CONFIG_BASE_URL',
      defaultValue: 'http://127.0.0.1:8010',
    );

    _controller = GoLifeController(
      localStore: resolvedLocalStore,
      aiGatewayClient: widget.aiGatewayClient ??
          HttpAiGatewayClient(
            baseUri: Uri.parse(baseUrl),
          ),
      lifeGraphRepository: widget.lifeGraphRepository ??
          LifeGraphRepository.seeded(localStore: resolvedLocalStore),
      runtimeConfigClient: RuntimeConfigClient(
        baseUri: Uri.parse(runtimeConfigBaseUrl),
      ),
    );
    _router = buildAppRouter(_controller);
    _controller.updateDeviceLocaleTag(
      WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag(),
    );
    unawaited(_controller.bootstrap());
    _runtimeConfigTimer = Timer.periodic(
      const Duration(hours: 6),
      (_) => unawaited(
        _controller.refreshRuntimeConfig(
          refreshMissionPlan: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _runtimeConfigTimer?.cancel();
    _router.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    final locale = locales == null || locales.isEmpty
        ? WidgetsBinding.instance.platformDispatcher.locale
        : locales.first;
    _controller.updateDeviceLocaleTag(locale.toLanguageTag());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          theme: buildGoLifeTheme(),
          locale: _controller.preferredLocale,
          supportedLocales: supportedAppLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
        );
      },
    );
  }
}

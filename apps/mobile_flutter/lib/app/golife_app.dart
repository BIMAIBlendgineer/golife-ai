import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/ai_client/ai_gateway_client.dart';
import '../core/lifegraph/lifegraph_repository.dart';
import '../core/storage/local_store.dart';
import '../core/storage/sqlite_local_store.dart';
import '../features/app_state/golife_controller.dart';
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

class _GoLifeAppState extends State<GoLifeApp> {
  late final GoLifeController _controller;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final resolvedLocalStore = widget.localStore ?? SqliteLocalStore();
    final baseUrl = const String.fromEnvironment(
      'GOLIFE_AI_GATEWAY_BASE_URL',
      defaultValue: 'http://127.0.0.1:8000',
    );

    _controller = GoLifeController(
      localStore: resolvedLocalStore,
      aiGatewayClient: widget.aiGatewayClient ??
          HttpAiGatewayClient(
            baseUri: Uri.parse(baseUrl),
          ),
      lifeGraphRepository: widget.lifeGraphRepository ??
          LifeGraphRepository.seeded(localStore: resolvedLocalStore),
    );
    _router = buildAppRouter(_controller);
    unawaited(_controller.bootstrap());
  }

  @override
  void dispose() {
    _router.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'GoLife AI',
          theme: buildGoLifeTheme(),
          routerConfig: _router,
        );
      },
    );
  }
}

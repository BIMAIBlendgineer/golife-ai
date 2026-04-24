import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/app_state/golife_controller.dart';
import '../../features/capture/capture_screen.dart';
import '../../features/copilot/copilot_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/settings/privacy_screen.dart';
import '../../features/shared/section_placeholder_screen.dart';
import '../shell/app_shell_scaffold.dart';

GoRouter buildAppRouter(GoLifeController controller) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShellScaffold(
            controller: controller,
            currentLocation: state.uri.toString(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => DashboardScreen(controller: controller),
          ),
          GoRoute(
            path: '/capture',
            builder: (context, state) => CaptureScreen(controller: controller),
          ),
          GoRoute(
            path: '/week',
            builder: (context, state) => SectionPlaceholderScreen(
              title: 'Week',
              eyebrow: 'Planner',
              description:
                  'A future weekly planner with recurring work, day focus and local-first structure.',
              accent: const Color(0xFF5D7A68),
              highlights: [
                controller.weekSummary.theme,
                controller.weekSummary.energyNote,
                'Recurring structure stays separate from GPL source code',
              ],
              actionLabel: 'Emit planning event',
              onAction: controller.emitWeekEvent,
            ),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => SectionPlaceholderScreen(
              title: 'Tasks',
              eyebrow: 'Execution',
              description:
                  'Own task models sit here first; migration from Taskly comes later as selective adaptation.',
              accent: const Color(0xFF1F4C5B),
              highlights: [
                controller.criticalTask.title,
                controller.criticalTask.timeboxLabel,
                'Voice rewrite path reserved for AI-safe flow',
              ],
              actionLabel: 'Emit task event',
              onAction: controller.emitTaskEvent,
            ),
          ),
          GoRoute(
            path: '/money',
            builder: (context, state) => SectionPlaceholderScreen(
              title: 'Money',
              eyebrow: 'Reflection',
              description:
                  'Finance stays intentionally conservative until the Flow source is available locally.',
              accent: const Color(0xFF8A6C2F),
              highlights: [
                controller.financeSummary.reflectionLabel,
                'Reflection mode only until finance migration is grounded in a local source repo.',
                'Reflection only, never regulated advice',
              ],
              actionLabel: 'Emit finance event',
              onAction: controller.emitFinanceEvent,
            ),
          ),
          GoRoute(
            path: '/pantry',
            builder: (context, state) => SectionPlaceholderScreen(
              title: 'Pantry',
              eyebrow: 'Rescue',
              description:
                  'Pantry and grocery flows are prepared for shared lists, food rescue and anti-waste nudges.',
              accent: const Color(0xFF4C6A4F),
              highlights: [
                controller.pantrySummary.name,
                controller.pantrySummary.rescueHint,
                'Shared-list ideas will be reimplemented in Flutter',
              ],
              actionLabel: 'Emit pantry event',
              onAction: controller.emitPantryEvent,
            ),
          ),
          GoRoute(
            path: '/closet',
            builder: (context, state) => SectionPlaceholderScreen(
              title: 'Closet',
              eyebrow: 'Anti-consumption',
              description:
                  'Closet is wired for item tracking, outfit memory and purchase-intention checkpoints.',
              accent: const Color(0xFF7A5167),
              highlights: [
                controller.closetSummary.label,
                controller.closetSummary.reason,
                'Purchase decisions require explanation and confirmation',
              ],
              actionLabel: 'Emit closet event',
              onAction: controller.emitWardrobeEvent,
            ),
          ),
          GoRoute(
            path: '/copilot',
            builder: (context, state) => CopilotScreen(controller: controller),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => PrivacyScreen(controller: controller),
          ),
        ],
      ),
    ],
  );
}

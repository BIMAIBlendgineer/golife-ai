import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../features/app_state/golife_controller.dart';

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.controller,
    required this.currentLocation,
    required this.child,
  });

  final GoLifeController controller;
  final String currentLocation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 980;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF17110F),
                    Color(0xFF231914),
                    Color(0xFF2D201A),
                  ]
                : const [
                    Color(0xFFF5EDE1),
                    Color(0xFFEFE2CF),
                    Color(0xFFE6D4BF),
                  ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -20,
              child: _BlurBlob(
                color:
                    (isDark ? const Color(0xFFE48B6E) : const Color(0xFFD06447))
                        .withValues(alpha: 0.14),
                size: 220,
              ),
            ),
            Positioned(
              left: -50,
              bottom: -40,
              child: _BlurBlob(
                color:
                    (isDark ? const Color(0xFF89A58F) : const Color(0xFF5D7A68))
                        .withValues(alpha: 0.14),
                size: 260,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: isWide
                    ? Row(
                        children: [
                          _SideRail(
                            currentLocation: currentLocation,
                            l10n: l10n,
                          ),
                          const SizedBox(width: 20),
                          Expanded(child: _ContentFrame(child: child)),
                        ],
                      )
                    : Column(
                        children: [
                          _Header(controller: controller),
                          const SizedBox(height: 14),
                          _TopTabs(
                            currentLocation: currentLocation,
                            l10n: l10n,
                          ),
                          const SizedBox(height: 14),
                          Expanded(child: _ContentFrame(child: child)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFD06447),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x332A160E),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.appTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(
                controller.isReady
                    ? l10n.appShellTaglineReady
                    : l10n.appShellTaglineBooting,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({required this.currentLocation, required this.l10n});

  final String currentLocation;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF261D18).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0x33E6CDB9) : const Color(0x33FFFFFF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.navigate, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          for (final destination in appDestinations)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DestinationButton(
                destination: destination,
                l10n: l10n,
                selected: currentLocation.startsWith(destination.path),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs({required this.currentLocation, required this.l10n});

  final String currentLocation;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final destination in appDestinations)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _DestinationChip(
                destination: destination,
                l10n: l10n,
                selected: currentLocation.startsWith(destination.path),
              ),
            ),
        ],
      ),
    );
  }
}

class _DestinationButton extends StatelessWidget {
  const _DestinationButton({
    required this.destination,
    required this.l10n,
    required this.selected,
  });

  final AppDestination destination;
  final AppLocalizations l10n;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: selected
          ? (isDark ? const Color(0xFFE48B6E) : const Color(0xFF1F1A17))
          : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go(destination.path),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(destination.icon,
                  color: selected
                      ? (isDark ? const Color(0xFF1A120F) : Colors.white)
                      : (isDark
                          ? const Color(0xFFE8D5C8)
                          : const Color(0xFF4F443D))),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  destination.localizedLabel(l10n),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: selected
                        ? (isDark ? const Color(0xFF1A120F) : Colors.white)
                        : (isDark
                            ? const Color(0xFFE8D5C8)
                            : const Color(0xFF4F443D)),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationChip extends StatelessWidget {
  const _DestinationChip({
    required this.destination,
    required this.l10n,
    required this.selected,
  });

  final AppDestination destination;
  final AppLocalizations l10n;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      avatar: Icon(destination.icon, size: 18),
      label: Text(destination.localizedLabel(l10n)),
      labelStyle: TextStyle(
        color: selected
            ? (isDark ? const Color(0xFF1A120F) : Colors.white)
            : (isDark ? const Color(0xFFE8D5C8) : const Color(0xFF4F443D)),
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: isDark
          ? const Color(0xFF261D18).withValues(alpha: 0.92)
          : Colors.white.withValues(alpha: 0.62),
      selectedColor: isDark ? const Color(0xFFE48B6E) : const Color(0xFF1F1A17),
      side: BorderSide.none,
      onSelected: (_) => context.go(destination.path),
    );
  }
}

class _ContentFrame extends StatelessWidget {
  const _ContentFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1512).withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? const Color(0x33E6CDB9) : const Color(0x33FFFFFF),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: child,
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class AppDestination {
  const AppDestination({
    required this.kind,
    required this.path,
    required this.icon,
  });

  final AppDestinationKind kind;
  final String path;
  final IconData icon;

  String localizedLabel(AppLocalizations l10n) {
    switch (kind) {
      case AppDestinationKind.dashboard:
        return l10n.navDashboard;
      case AppDestinationKind.capture:
        return l10n.navCapture;
      case AppDestinationKind.lifegraph:
        return l10n.navLifeGraph;
      case AppDestinationKind.week:
        return l10n.navWeek;
      case AppDestinationKind.tasks:
        return l10n.navTasks;
      case AppDestinationKind.habits:
        return l10n.navHabits;
      case AppDestinationKind.money:
        return l10n.navMoney;
      case AppDestinationKind.pantry:
        return l10n.navPantry;
      case AppDestinationKind.shopping:
        return 'Shopping';
      case AppDestinationKind.closet:
        return l10n.navCloset;
      case AppDestinationKind.decisions:
        return 'Decisions';
      case AppDestinationKind.everyday:
        return l10n.navEveryday;
      case AppDestinationKind.copilot:
        return l10n.navCopilot;
      case AppDestinationKind.settings:
        return l10n.navSettings;
    }
  }
}

enum AppDestinationKind {
  dashboard,
  capture,
  lifegraph,
  week,
  tasks,
  habits,
  money,
  pantry,
  shopping,
  closet,
  decisions,
  everyday,
  copilot,
  settings,
}

const appDestinations = [
  AppDestination(
      kind: AppDestinationKind.dashboard,
      path: '/dashboard',
      icon: Icons.space_dashboard_rounded),
  AppDestination(
      kind: AppDestinationKind.capture,
      path: '/capture',
      icon: Icons.add_circle_outline_rounded),
  AppDestination(
      kind: AppDestinationKind.lifegraph,
      path: '/lifegraph',
      icon: Icons.timeline_rounded),
  AppDestination(
      kind: AppDestinationKind.week,
      path: '/week',
      icon: Icons.view_week_rounded),
  AppDestination(
      kind: AppDestinationKind.tasks,
      path: '/tasks',
      icon: Icons.checklist_rounded),
  AppDestination(
      kind: AppDestinationKind.habits,
      path: '/habits',
      icon: Icons.self_improvement_rounded),
  AppDestination(
      kind: AppDestinationKind.money,
      path: '/money',
      icon: Icons.stacked_line_chart_rounded),
  AppDestination(
      kind: AppDestinationKind.pantry,
      path: '/pantry',
      icon: Icons.kitchen_rounded),
  AppDestination(
      kind: AppDestinationKind.shopping,
      path: '/shopping',
      icon: Icons.shopping_bag_outlined),
  AppDestination(
      kind: AppDestinationKind.closet,
      path: '/closet',
      icon: Icons.checkroom_rounded),
  AppDestination(
      kind: AppDestinationKind.decisions,
      path: '/decisions',
      icon: Icons.rule_folder_outlined),
  AppDestination(
      kind: AppDestinationKind.everyday,
      path: '/everyday',
      icon: Icons.auto_awesome_motion_rounded),
  AppDestination(
      kind: AppDestinationKind.copilot,
      path: '/copilot',
      icon: Icons.psychology_alt_rounded),
  AppDestination(
      kind: AppDestinationKind.settings,
      path: '/settings',
      icon: Icons.tune_rounded),
];

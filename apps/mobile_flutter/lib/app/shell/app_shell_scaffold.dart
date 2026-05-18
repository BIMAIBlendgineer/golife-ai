import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/app_localized_values.dart';
import '../../features/app_state/golife_controller.dart';
import '../../features/shared/premium_ui.dart';
import '../../l10n/app_localizations.dart';
import '../theme/golife_theme.dart';

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
    final selectedSection = _sectionForLocation(currentLocation);
    final premiumTheme = buildGoLifeTheme(Brightness.dark);

    return Theme(
      data: premiumTheme,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                GoLifePalette.ink900,
                GoLifePalette.surface900,
                GoLifePalette.ink800,
              ],
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                top: -120,
                left: -80,
                child: _Orb(size: 260, color: Color(0x557A5CFF)),
              ),
              const Positioned(
                top: 120,
                right: -70,
                child: _Orb(size: 220, color: Color(0x443EB4FF)),
              ),
              const Positioned(
                bottom: -140,
                left: 40,
                child: _Orb(size: 320, color: Color(0x2225C79B)),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? 24 : 16,
                    16,
                    isWide ? 24 : 16,
                    16,
                  ),
                  child: isWide
                      ? Row(
                          children: [
                            _DesktopRail(
                              controller: controller,
                              selectedSection: selectedSection,
                              l10n: l10n,
                            ),
                            const SizedBox(width: 20),
                            Expanded(child: _ContentFrame(child: child)),
                          ],
                        )
                      : Column(
                          children: [
                            _MobileTopBar(controller: controller, l10n: l10n),
                            const SizedBox(height: 16),
                            Expanded(child: _ContentFrame(child: child)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: isWide
            ? null
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: GoLifePalette.lineStrong.withValues(
                            alpha: 0.88,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: NavigationBar(
                        selectedIndex: selectedSection.index,
                        destinations: [
                          for (final destination in _primaryDestinations)
                            NavigationDestination(
                              icon: Icon(destination.icon),
                              selectedIcon: Icon(destination.selectedIcon),
                              label: destination.localizedLabel(l10n),
                            ),
                        ],
                        onDestinationSelected: (index) {
                          context.go(_primaryDestinations[index].path);
                        },
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _MobileTopBar extends StatelessWidget {
  const _MobileTopBar({required this.controller, required this.l10n});

  final GoLifeController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GoLifeCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [GoLifePalette.violetBright, GoLifePalette.blue],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  _shellSubtitle(l10n),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          GoLifeStatusPill(
            label: controller.localizedGatewayStatusLabel(l10n),
            icon: _gatewayIcon(controller.localizedGatewayStatusLabel(l10n)),
            accent: _gatewayAccent(controller.gatewayStatusLabel),
          ),
        ],
      ),
    );
  }
}

class _DesktopRail extends StatelessWidget {
  const _DesktopRail({
    required this.controller,
    required this.selectedSection,
    required this.l10n,
  });

  final GoLifeController controller;
  final _PrimarySection selectedSection;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 264,
      child: Column(
        children: [
          GoLifeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _shellSubtitle(l10n),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                GoLifeStatusPill(
                  label: controller.localizedGatewayStatusLabel(l10n),
                  icon: _gatewayIcon(
                    controller.localizedGatewayStatusLabel(l10n),
                  ),
                  accent: _gatewayAccent(controller.gatewayStatusLabel),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GoLifeCard(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: NavigationRail(
                selectedIndex: selectedSection.index,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final destination in _primaryDestinations)
                    NavigationRailDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon),
                      label: Text(destination.localizedLabel(l10n)),
                    ),
                ],
                onDestinationSelected: (index) {
                  context.go(_primaryDestinations[index].path);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentFrame extends StatelessWidget {
  const _ContentFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GoLifePalette.surface800.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: GoLifePalette.lineStrong.withValues(alpha: 0.9),
        ),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(34), child: child),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

enum _PrimarySection { today, capture, memory, coach, settings }

class _PrimaryDestination {
  const _PrimaryDestination({
    required this.section,
    required this.path,
    required this.icon,
    required this.selectedIcon,
  });

  final _PrimarySection section;
  final String path;
  final IconData icon;
  final IconData selectedIcon;

  String localizedLabel(AppLocalizations l10n) {
    switch (section) {
      case _PrimarySection.today:
        return l10n.labelToday;
      case _PrimarySection.capture:
        return l10n.navCapture;
      case _PrimarySection.memory:
        return _memoryLabel(l10n);
      case _PrimarySection.coach:
        return _coachLabel(l10n);
      case _PrimarySection.settings:
        return l10n.navSettings;
    }
  }
}

const List<_PrimaryDestination> _primaryDestinations = [
  _PrimaryDestination(
    section: _PrimarySection.today,
    path: '/dashboard',
    icon: Icons.today_outlined,
    selectedIcon: Icons.today_rounded,
  ),
  _PrimaryDestination(
    section: _PrimarySection.capture,
    path: '/capture',
    icon: Icons.add_circle_outline_rounded,
    selectedIcon: Icons.add_circle_rounded,
  ),
  _PrimaryDestination(
    section: _PrimarySection.memory,
    path: '/lifegraph',
    icon: Icons.hub_outlined,
    selectedIcon: Icons.hub_rounded,
  ),
  _PrimaryDestination(
    section: _PrimarySection.coach,
    path: '/copilot',
    icon: Icons.auto_awesome_outlined,
    selectedIcon: Icons.auto_awesome_rounded,
  ),
  _PrimaryDestination(
    section: _PrimarySection.settings,
    path: '/settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
  ),
];

_PrimarySection _sectionForLocation(String currentLocation) {
  final path = Uri.tryParse(currentLocation)?.path ?? currentLocation;
  if (path.startsWith('/capture')) {
    return _PrimarySection.capture;
  }
  if (path.startsWith('/copilot') || path.startsWith('/decisions')) {
    return _PrimarySection.coach;
  }
  if (path.startsWith('/settings')) {
    return _PrimarySection.settings;
  }
  if (const <String>[
    '/lifegraph',
    '/memory',
    '/tasks',
    '/habits',
    '/money',
    '/pantry',
    '/week',
    '/closet',
    '/shopping',
    '/journal',
    '/calendar',
    '/recipes',
    '/everyday',
    '/homememory',
  ].any(path.startsWith)) {
    return _PrimarySection.memory;
  }
  return _PrimarySection.today;
}

String _memoryLabel(AppLocalizations l10n) {
  return pickLocalizedValue(
    l10n.localeName,
    en: 'Memory',
    es: 'Memory',
    ptBr: 'Memory',
    ptPt: 'Memory',
    fr: 'Memory',
    it: 'Memory',
    de: 'Memory',
    ja: 'Memory',
    zhHans: 'Memory',
    zhHant: 'Memory',
  );
}

String _coachLabel(AppLocalizations l10n) {
  return pickLocalizedValue(
    l10n.localeName,
    en: 'Coach',
    es: 'Coach',
    ptBr: 'Coach',
    ptPt: 'Coach',
    fr: 'Coach',
    it: 'Coach',
    de: 'Coach',
    ja: 'Coach',
    zhHans: 'Coach',
    zhHant: 'Coach',
  );
}

String _shellSubtitle(AppLocalizations l10n) {
  return pickLocalizedValue(
    l10n.localeName,
    en: 'Your daily decision OS.',
    es: 'Tu sistema operativo de decisiones diarias.',
    ptBr: 'Seu sistema operacional de decisoes diarias.',
    ptPt: 'O teu sistema operativo de decisoes diarias.',
    fr: 'Ton systeme d exploitation des decisions quotidiennes.',
    it: 'Il tuo sistema operativo per le decisioni quotidiane.',
    de: 'Dein Betriebssystem fuer taegliche Entscheidungen.',
    ja: 'Your daily decision OS.',
    zhHans: 'Your daily decision OS.',
    zhHant: 'Your daily decision OS.',
  );
}

GoLifeAccent _gatewayAccent(String statusLabel) {
  final normalized = statusLabel.toLowerCase();
  if (normalized.contains('no connection')) {
    return GoLifeAccent.danger;
  }
  if (normalized.contains('fallback') ||
      normalized.contains('unavailable') ||
      normalized.contains('degraded')) {
    return GoLifeAccent.amber;
  }
  return GoLifeAccent.emerald;
}

IconData _gatewayIcon(String statusLabel) {
  final normalized = statusLabel.toLowerCase();
  if (normalized.contains('no connection')) {
    return Icons.wifi_off_rounded;
  }
  if (normalized.contains('fallback') ||
      normalized.contains('unavailable') ||
      normalized.contains('degraded')) {
    return Icons.shield_moon_outlined;
  }
  return Icons.verified_rounded;
}

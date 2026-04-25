import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
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
                color: const Color(0xFFD06447).withValues(alpha: 0.14),
                size: 220,
              ),
            ),
            Positioned(
              left: -50,
              bottom: -40,
              child: _BlurBlob(
                color: const Color(0xFF5D7A68).withValues(alpha: 0.14),
                size: 260,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: isWide
                    ? Row(
                        children: [
                          _SideRail(currentLocation: currentLocation),
                          const SizedBox(width: 20),
                          Expanded(child: _ContentFrame(child: child)),
                        ],
                      )
                    : Column(
                        children: [
                          _Header(controller: controller),
                          const SizedBox(height: 14),
                          _TopTabs(currentLocation: currentLocation),
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
              Text('GoLife AI', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(
                controller.isReady
                    ? 'Life operating system shell with explicit privacy boundaries.'
                    : 'Bootstrapping privacy, mission mock and local graph...',
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
  const _SideRail({required this.currentLocation});

  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Navigate', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          for (final destination in appDestinations)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DestinationButton(
                destination: destination,
                selected: currentLocation.startsWith(destination.path),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs({required this.currentLocation});

  final String currentLocation;

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
    required this.selected,
  });

  final AppDestination destination;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? const Color(0xFF1F1A17) : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go(destination.path),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(destination.icon,
                  color: selected ? Colors.white : const Color(0xFF4F443D)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  destination.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: selected ? Colors.white : const Color(0xFF4F443D),
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
    required this.selected,
  });

  final AppDestination destination;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      avatar: Icon(destination.icon, size: 18),
      label: Text(destination.label),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF4F443D),
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: Colors.white.withValues(alpha: 0.62),
      selectedColor: const Color(0xFF1F1A17),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0x33FFFFFF)),
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
    required this.label,
    required this.path,
    required this.icon,
  });

  final String label;
  final String path;
  final IconData icon;
}

const appDestinations = [
  AppDestination(
      label: 'Dashboard',
      path: '/dashboard',
      icon: Icons.space_dashboard_rounded),
  AppDestination(
      label: 'Capture',
      path: '/capture',
      icon: Icons.add_circle_outline_rounded),
  AppDestination(label: 'Week', path: '/week', icon: Icons.view_week_rounded),
  AppDestination(label: 'Tasks', path: '/tasks', icon: Icons.checklist_rounded),
  AppDestination(
      label: 'Habits', path: '/habits', icon: Icons.self_improvement_rounded),
  AppDestination(
      label: 'Money', path: '/money', icon: Icons.stacked_line_chart_rounded),
  AppDestination(label: 'Pantry', path: '/pantry', icon: Icons.kitchen_rounded),
  AppDestination(
      label: 'Closet', path: '/closet', icon: Icons.checkroom_rounded),
  AppDestination(
      label: 'Journal', path: '/journal', icon: Icons.menu_book_rounded),
  AppDestination(
      label: 'Calendar', path: '/calendar', icon: Icons.edit_calendar_rounded),
  AppDestination(
      label: 'Recipes', path: '/recipes', icon: Icons.restaurant_menu_rounded),
  AppDestination(
      label: 'Copilot', path: '/copilot', icon: Icons.psychology_alt_rounded),
  AppDestination(
      label: 'Settings', path: '/settings', icon: Icons.tune_rounded),
];

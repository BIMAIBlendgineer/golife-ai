import 'package:flutter/material.dart';

class GoLifePalette {
  static const Color ink900 = Color(0xFF060B1A);
  static const Color ink800 = Color(0xFF0B1224);
  static const Color ink700 = Color(0xFF111A31);
  static const Color ink600 = Color(0xFF15203B);
  static const Color surface900 = Color(0xFF0B1020);
  static const Color surface800 = Color(0xFF121A2F);
  static const Color surface700 = Color(0xFF17223C);
  static const Color surface600 = Color(0xFF1D2B4D);
  static const Color line = Color(0xFF263555);
  static const Color lineStrong = Color(0xFF32456F);
  static const Color textPrimary = Color(0xFFF5F7FF);
  static const Color textSecondary = Color(0xFFB4C1E1);
  static const Color textMuted = Color(0xFF8090B7);
  static const Color violet = Color(0xFF7A5CFF);
  static const Color violetBright = Color(0xFF9E7CFF);
  static const Color blue = Color(0xFF46B5FF);
  static const Color emerald = Color(0xFF32D4A4);
  static const Color amber = Color(0xFFF2B766);
  static const Color danger = Color(0xFFFF6B77);
}

enum GoLifeAccent { neutral, violet, blue, emerald, amber, danger }

extension GoLifeAccentX on GoLifeAccent {
  Color get color {
    switch (this) {
      case GoLifeAccent.neutral:
        return GoLifePalette.textSecondary;
      case GoLifeAccent.violet:
        return GoLifePalette.violetBright;
      case GoLifeAccent.blue:
        return GoLifePalette.blue;
      case GoLifeAccent.emerald:
        return GoLifePalette.emerald;
      case GoLifeAccent.amber:
        return GoLifePalette.amber;
      case GoLifeAccent.danger:
        return GoLifePalette.danger;
    }
  }
}

class GoLifeScreen extends StatelessWidget {
  const GoLifeScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.badge,
    this.trailing,
    this.padding,
  });

  final String title;
  final String subtitle;
  final Widget? badge;
  final Widget? trailing;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompactHeader = MediaQuery.sizeOf(context).width < 520 &&
        (badge != null || trailing != null);
    return SingleChildScrollView(
      padding: padding ?? goLifeContentPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCompactHeader)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: GoLifePalette.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (badge != null) badge!,
                    if (trailing != null) trailing!,
                  ],
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: GoLifePalette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null) ...[const SizedBox(width: 12), badge!],
                if (trailing != null) ...[const SizedBox(width: 12), trailing!],
              ],
            ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

EdgeInsets goLifeContentPadding(
  BuildContext context, {
  double horizontal = 20,
  double top = 20,
  double mobileBottom = 128,
  double wideBottom = 32,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
  final bottom = width < 980 ? mobileBottom : wideBottom;
  return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom + safeBottom);
}

class GoLifeCard extends StatelessWidget {
  const GoLifeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.accent = GoLifeAccent.neutral,
    this.filled = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final GoLifeAccent accent;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = accent.color;
    final decoration = BoxDecoration(
      color: filled
          ? accentColor.withValues(alpha: 0.18)
          : GoLifePalette.surface700.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(26),
      border: Border.all(
        color: filled
            ? accentColor.withValues(alpha: 0.32)
            : GoLifePalette.line.withValues(alpha: 0.9),
      ),
      boxShadow: [
        BoxShadow(
          color: accentColor.withValues(alpha: filled ? 0.12 : 0.04),
          blurRadius: filled ? 28 : 16,
          offset: const Offset(0, 10),
        ),
      ],
    );

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: decoration,
      padding: padding,
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: card,
      ),
    );
  }
}

class GoLifeStatusPill extends StatelessWidget {
  const GoLifeStatusPill({
    super.key,
    required this.label,
    this.icon,
    this.accent = GoLifeAccent.neutral,
  });

  final String label;
  final IconData? icon;
  final GoLifeAccent accent;

  @override
  Widget build(BuildContext context) {
    final accentColor = accent.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.26)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: GoLifePalette.textPrimary),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: GoLifePalette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoLifeMetricCard extends StatelessWidget {
  const GoLifeMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.accent = GoLifeAccent.neutral,
  });

  final String label;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final GoLifeAccent accent;

  @override
  Widget build(BuildContext context) {
    return GoLifeCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: accent.color, size: 20),
            const SizedBox(height: 12),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: GoLifePalette.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: GoLifePalette.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class GoLifeSectionTitle extends StatelessWidget {
  const GoLifeSectionTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GoLifePalette.textSecondary,
                ),
          ),
        ],
      ],
    );
  }
}

class GoLifeEmptyState extends StatelessWidget {
  const GoLifeEmptyState({
    super.key,
    required this.title,
    required this.body,
    this.action,
    this.icon = Icons.auto_awesome_rounded,
  });

  final String title;
  final String body;
  final Widget? action;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GoLifeCard(
      accent: GoLifeAccent.violet,
      filled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: GoLifePalette.textSecondary),
          ),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    );
  }
}

class GoLifeShortcutItem {
  const GoLifeShortcutItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.badge,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;
}

class GoLifeShortcutGrid extends StatelessWidget {
  const GoLifeShortcutGrid({super.key, required this.items});

  final List<GoLifeShortcutItem> items;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900
        ? 4
        : width >= 560
            ? 3
            : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return GoLifeCard(
          onTap: item.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: GoLifePalette.violet.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: GoLifePalette.violetBright),
              ),
              const Spacer(),
              Text(
                item.label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (item.badge != null) ...[
                const SizedBox(height: 6),
                Text(
                  item.badge!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: GoLifePalette.textMuted,
                      ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class GoLifeTimelineCard extends StatelessWidget {
  const GoLifeTimelineCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.actions,
    this.accent = GoLifeAccent.blue,
  });

  final String title;
  final String subtitle;
  final List<Widget> meta;
  final List<Widget> actions;
  final GoLifeAccent accent;

  @override
  Widget build(BuildContext context) {
    return GoLifeCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GoLifePalette.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: meta),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(spacing: 10, runSpacing: 10, children: actions),
          ],
        ],
      ),
    );
  }
}

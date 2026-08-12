import 'package:flutter/material.dart';

import '../../core/i18n/app_localized_values.dart';
import '../shared/premium_ui.dart';

class BootstrapScreen extends StatelessWidget {
  const BootstrapScreen({
    super.key,
    required this.localeTag,
  });

  final String localeTag;

  @override
  Widget build(BuildContext context) {
    final preparingText = pickLocalizedValue(
      localeTag,
      en: 'Preparing your day...',
      es: 'Preparando tu día...',
      ptBr: 'Preparando o seu dia...',
      ptPt: 'A preparar o teu dia...',
      fr: 'Préparation de votre journée...',
      it: 'Preparazione della tua giornata...',
      de: 'Dein Tag wird vorbereitet...',
      ja: '今日の準備をしています...',
      zhHans: '正在准备你的一天...',
      zhHant: '正在準備你的一天...',
    );

    return Scaffold(
      key: const Key('golife-bootstrap-screen'),
      backgroundColor: GoLifePalette.ink900,
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
          fit: StackFit.expand,
          children: [
            const Positioned(
              top: -120,
              right: -90,
              child: _BootstrapGlow(
                size: 260,
                color: Color(0x127045F5),
              ),
            ),
            const Positioned(
              bottom: -160,
              left: -80,
              child: _BootstrapGlow(
                size: 280,
                color: Color(0x0C349CFF),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: GoLifeSpacing.xl),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Semantics(
                      container: true,
                      label: 'GoLife AI',
                      value: preparingText,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  GoLifePalette.violet,
                                  GoLifePalette.blue,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                GoLifeRadii.xlarge,
                              ),
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: GoLifeSpacing.lg),
                          Text(
                            'GoLife AI',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: GoLifeSpacing.xs),
                          Text(
                            preparingText,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: GoLifePalette.textSecondary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: GoLifeSpacing.xl),
                          SizedBox(
                            width: 176,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                GoLifeRadii.pill,
                              ),
                              child: const LinearProgressIndicator(
                                value: null,
                                minHeight: 4,
                                backgroundColor: GoLifePalette.surface600,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  GoLifePalette.violetBright,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BootstrapGlow extends StatelessWidget {
  const _BootstrapGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

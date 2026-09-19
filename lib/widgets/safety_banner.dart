import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_strings.dart';

/// Banner de advertencia de uso educativo.
///
/// Aparece en la pantalla de inicio y, en formato compacto, en cada modulo de
/// calculo: la advertencia debe ser visible en el mismo lugar donde el
/// estudiante lee un resultado.
class SafetyBanner extends StatelessWidget {
  const SafetyBanner({super.key, this.compacto = false});

  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final Color base = AppColors.seguridad;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compacto ? 10 : 14),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: base.withValues(alpha: 0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.warning_amber_rounded,
            color: base,
            size: compacto ? 20 : 26,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Advertencia de seguridad',
                  style: tema.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: base,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  compacto
                      ? AppStrings.indicadorResultados
                      : AppStrings.advertenciaSeguridad,
                  style: tema.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

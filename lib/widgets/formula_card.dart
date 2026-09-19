import 'package:flutter/material.dart';

import '../models/formula_explanation.dart';
import 'app_card.dart';

/// Tarjeta que muestra una explicacion completa de calculo.
///
/// Regla de producto: en Fragmenta Lab ningun resultado se muestra solo. Cada
/// numero aparece acompanado de formula, variables, unidades, interpretacion y
/// limitaciones del modelo.
class FormulaCard extends StatelessWidget {
  const FormulaCard(this.explicacion, {super.key});

  final FormulaExplanation explicacion;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme esquema = tema.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            explicacion.titulo,
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: esquema.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              explicacion.formula,
              style: tema.textTheme.titleMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                color: esquema.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Variables y unidades',
            style: tema.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          ...explicacion.variables.map(
            (FormulaVariable v) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 46,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      v.simbolo,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(v.nombre, style: tema.textTheme.bodyMedium),
                        Text(
                          v.valor == null
                              ? 'Unidad: ${v.unidad}'
                              : '${v.valor} ${v.unidad}',
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: esquema.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Row(
            children: <Widget>[
              Text('Resultado', style: tema.textTheme.labelLarge),
              const Spacer(),
              Text(
                '${explicacion.resultado} ${explicacion.unidadResultado}',
                style: tema.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: esquema.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Interpretacion',
            style: tema.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(explicacion.interpretacion, style: tema.textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text(
            'Limitaciones del modelo',
            style: tema.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: esquema.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            explicacion.limitaciones,
            style: tema.textTheme.bodySmall?.copyWith(
              color: esquema.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

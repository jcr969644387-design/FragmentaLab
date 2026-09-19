import 'package:flutter/material.dart';

import '../models/risk_level.dart';
import '../theme/app_theme.dart';

/// Etiqueta compacta de nivel de riesgo.
class RiskChip extends StatelessWidget {
  const RiskChip(this.nivel, {super.key, this.etiqueta});

  final RiskLevel nivel;
  final String? etiqueta;

  @override
  Widget build(BuildContext context) {
    final Color color = AppColors.deRiesgo(nivel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(_icono, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            etiqueta ?? nivel.etiqueta,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData get _icono {
    switch (nivel) {
      case RiskLevel.bajo:
        return Icons.check_circle_outline;
      case RiskLevel.medio:
        return Icons.error_outline;
      case RiskLevel.alto:
        return Icons.report_gmailerrorred_outlined;
    }
  }
}

/// Barra de progreso con etiqueta, usada para indices conceptuales.
class MetricBar extends StatelessWidget {
  const MetricBar({
    super.key,
    required this.titulo,
    required this.valor,
    required this.texto,
    this.color,
  });

  final String titulo;

  /// Valor normalizado entre 0 y 1.
  final double valor;

  final String texto;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final Color c = color ?? tema.colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(titulo, style: tema.textTheme.bodyMedium),
            ),
            Text(
              texto,
              style: tema.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: c,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: valor.clamp(0.0, 1.0).toDouble(),
            minHeight: 9,
            backgroundColor: c.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(c),
          ),
        ),
      ],
    );
  }
}

/// Fila de resultado: etiqueta a la izquierda, valor a la derecha.
class ResultRow extends StatelessWidget {
  const ResultRow({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.nota,
    this.destacado = false,
  });

  final String etiqueta;
  final String valor;
  final String? nota;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Text(etiqueta, style: tema.textTheme.bodyMedium),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Text(
                  valor,
                  textAlign: TextAlign.right,
                  style: tema.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: destacado ? tema.colorScheme.primary : null,
                    fontSize: destacado ? 15 : null,
                  ),
                ),
              ),
            ],
          ),
          if (nota != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                nota!,
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

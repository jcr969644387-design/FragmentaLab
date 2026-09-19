import 'package:flutter/material.dart';

import '../calculators/delay_sequencer.dart';
import '../models/blast_design.dart';
import '../models/delay_sequence.dart';
import '../services/design_store.dart';
import '../widgets/app_card.dart';
import '../widgets/mesh_painter.dart';
import '../widgets/risk_indicator.dart';
import '../widgets/safety_banner.dart';
import 'screen_scaffold.dart';

/// Modulo 6: secuencia de retardos.
///
/// Representa exclusivamente el **orden relativo** de salida y su efecto
/// cualitativo sobre desplazamiento, fragmentacion y vibracion. No entrega
/// tiempos, no describe accesorios y no constituye un plan de iniciacion.
class DelaySequenceScreen extends StatelessWidget {
  const DelaySequenceScreen({super.key, this.embebida = false});

  final bool embebida;

  @override
  Widget build(BuildContext context) {
    final DesignStore store = DesignScope.of(context);
    final BlastDesign d = store.design;
    const DelaySequencer secuenciador = DelaySequencer();
    final DelayPlan plan = secuenciador.generar(
      patron: d.secuencia,
      filas: d.filas,
      taladrosPorFila: d.taladrosPorFila,
    );

    final Widget cuerpo = ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      children: <Widget>[
        const SafetyBanner(compacto: true),
        const SectionTitle(
          'Patron de secuencia',
          icono: Icons.timeline_outlined,
          subtitulo: 'Solo orden conceptual: no se definen tiempos reales.',
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ...DelayPattern.values.map(
                (DelayPattern p) => _OpcionSecuencia(
                  patron: p,
                  seleccionado: p == d.secuencia,
                  onTap: () => store.cambiarSecuencia(p),
                ),
              ),
            ],
          ),
        ),
        const SectionTitle(
          'Orden conceptual de iniciacion',
          icono: Icons.grid_view_outlined,
          subtitulo: 'La cara libre se representa en la parte inferior.',
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MeshPreview(design: d, plan: plan, altura: 250),
              const SizedBox(height: 12),
              _MatrizOrdenes(plan: plan, design: d),
            ],
          ),
        ),
        const SectionTitle(
          'Lectura conceptual',
          icono: Icons.analytics_outlined,
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ResultRow(
                etiqueta: 'Ordenes distintos utilizados',
                valor: '${plan.ordenesDistintos}',
                destacado: true,
                nota: 'Intervalos relativos de 0 a '
                    '${plan.ordenesDistintos - 1} unidades adimensionales.',
              ),
              ResultRow(
                etiqueta: 'Taladros por orden (promedio)',
                valor: plan.taladrosPorOrden.toStringAsFixed(1),
              ),
              ResultRow(
                etiqueta: 'Total de taladros',
                valor: '${plan.totalTaladros}',
              ),
              const Divider(),
              _Bloque(
                titulo: 'Direccion de desplazamiento esperada',
                texto: plan.direccionDesplazamiento,
              ),
              _Bloque(
                titulo: 'Influencia sobre la fragmentacion',
                texto: plan.efectoFragmentacion,
              ),
              _Bloque(
                titulo: 'Influencia sobre la vibracion',
                texto: plan.efectoVibracion,
              ),
              _Bloque(
                titulo: 'Limite del modulo',
                texto: 'Fragmenta Lab no calcula tiempos de retardo, no define '
                    'elementos de iniciacion y no describe conexiones. El '
                    'objetivo es unicamente comparar el efecto conceptual del '
                    'orden de salida entre cuatro patrones tipicos.',
              ),
            ],
          ),
        ),
      ],
    );

    return envolverModulo(
      context: context,
      titulo: 'Secuencia de retardos',
      cuerpo: cuerpo,
      embebida: embebida,
    );
  }
}

class _Bloque extends StatelessWidget {
  const _Bloque({required this.titulo, required this.texto});

  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            titulo,
            style: tema.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: tema.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(texto, style: tema.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Matriz de ordenes por fila y columna.
class _MatrizOrdenes extends StatelessWidget {
  const _MatrizOrdenes({required this.plan, required this.design});

  final DelayPlan plan;
  final BlastDesign design;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme esquema = tema.colorScheme;
    final int filas = design.filas <= 0 ? 1 : design.filas;
    final int columnas =
        design.taladrosPorFila <= 0 ? 1 : design.taladrosPorFila;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Matriz de ordenes (fila 1 = mas cercana a la cara libre)',
          style: tema.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.generate(filas, (int indice) {
              final int fila = filas - 1 - indice;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 58,
                      child: Text(
                        'Fila ${fila + 1}',
                        style: tema.textTheme.bodySmall,
                      ),
                    ),
                    ...List<Widget>.generate(columnas, (int columna) {
                      final DelayStep? paso = _buscar(fila, columna);
                      return Container(
                        width: 34,
                        height: 30,
                        margin: const EdgeInsets.only(right: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: esquema.primary.withValues(
                            alpha: 0.06 + 0.10 * ((paso?.orden ?? 1) % 5),
                          ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: esquema.outlineVariant),
                        ),
                        child: Text(
                          '${paso?.orden ?? 0}',
                          style: tema.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  DelayStep? _buscar(int fila, int columna) {
    for (final DelayStep paso in plan.pasos) {
      if (paso.fila == fila && paso.columna == columna) {
        return paso;
      }
    }
    return null;
  }
}

/// Opcion seleccionable de patron de secuencia.
///
/// Se implementa con `InkWell` en lugar de `RadioListTile` para no depender de
/// una API que ha cambiado de forma entre versiones de Flutter.
class _OpcionSecuencia extends StatelessWidget {
  const _OpcionSecuencia({
    required this.patron,
    required this.seleccionado,
    required this.onTap,
  });

  final DelayPattern patron;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme esquema = tema.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: seleccionado
                ? esquema.primary.withValues(alpha: 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: seleccionado ? esquema.primary : esquema.outlineVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                seleccionado
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: seleccionado ? esquema.primary : esquema.outline,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      patron.etiqueta,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      patron.descripcion,
                      style: tema.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

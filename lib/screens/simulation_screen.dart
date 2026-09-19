import 'package:flutter/material.dart';

import '../calculators/delay_sequencer.dart';
import '../calculators/fragmentation_evaluator.dart';
import '../calculators/geometry_calculator.dart';
import '../calculators/mesh_type_classifier.dart';
import '../calculators/risk_classifier.dart';
import '../models/blast_design.dart';
import '../models/delay_sequence.dart';
import '../models/education_config.dart';
import '../models/explosive_concept.dart';
import '../models/fragmentation_outlook.dart';
import '../models/geometry_result.dart';
import '../models/mesh_type.dart';
import '../models/risk_assessment.dart';
import '../services/config_service.dart';
import '../services/design_store.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';
import '../utils/formatters.dart';
import '../utils/ui_feedback.dart';
import '../widgets/app_card.dart';
import '../widgets/mesh_painter.dart';
import '../widgets/numeric_field.dart';
import '../widgets/risk_indicator.dart';
import '../widgets/safety_banner.dart';
import 'screen_scaffold.dart';

/// Modulo 6: simulacion conceptual.
///
/// Vista en planta de la malla con controles rapidos y lectura de indicadores
/// cualitativos. Es una simulacion **visual y basada en reglas**: no resuelve
/// fisica de detonacion ni predice resultados operacionales.
class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key, this.embebida = false});

  final bool embebida;

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  bool _mostrarOrden = true;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final DesignStore store = DesignScope.of(context);
    final BlastDesign d = store.design;
    final EducationConfig config = ConfigService.instance.config;

    const GeometryCalculator geometria = GeometryCalculator();
    const DelaySequencer secuenciador = DelaySequencer();

    final GeometryResult g = geometria.calcular(d);
    final DelayPlan plan = secuenciador.generar(
      patron: d.secuencia,
      filas: d.filas,
      taladrosPorFila: d.taladrosPorFila,
    );
    final FragmentationOutlook outlook =
        FragmentationEvaluator(config).evaluar(d, g);
    final RiskAssessment riesgo = RiskClassifier(config).clasificar(d, g);
    final MeshTypeAssessment tipoMalla =
        const MeshTypeClassifier().clasificar(d);

    final Widget cuerpo = ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      children: <Widget>[
        const SafetyBanner(compacto: true),
        const SectionTitle(
          'Tipo de malla simulada',
          icono: Icons.layers_outlined,
          subtitulo: 'Contexto minero al que corresponde el ejercicio activo.',
        ),
        _TarjetaTipoMalla(tipoMalla),
        const SectionTitle(
          'Vista en planta de la malla',
          icono: Icons.scatter_plot_outlined,
          subtitulo:
              'Cada circulo es un taladro; el numero indica el orden de salida.',
        ),
        MeshPreview(design: d, plan: plan, mostrarOrden: _mostrarOrden),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Mostrar orden conceptual de salida',
                style: tema.textTheme.bodySmall,
              ),
            ),
            Switch(
              value: _mostrarOrden,
              onChanged: (bool v) {
                UiFeedback.seleccion();
                setState(() => _mostrarOrden = v);
              },
            ),
          ],
        ),
        const SectionTitle('Controles rapidos', icono: Icons.tune),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Deslizador(
                titulo: 'Burden',
                valor: d.burdenM,
                min: 0.5,
                max: 12,
                unidad: 'm',
                onChanged: (double v) =>
                    store.actualizar(d.copyWith(burdenM: v)),
              ),
              _Deslizador(
                titulo: 'Espaciamiento',
                valor: d.espaciamientoM,
                min: 0.5,
                max: 14,
                unidad: 'm',
                onChanged: (double v) =>
                    store.actualizar(d.copyWith(espaciamientoM: v)),
              ),
              _Deslizador(
                titulo: 'Diametro',
                valor: d.diametroMm,
                min: config.rangoDiametroMm.min,
                max: config.rangoDiametroMm.max,
                unidad: 'mm',
                decimales: 0,
                onChanged: (double v) =>
                    store.actualizar(d.copyWith(diametroMm: v)),
              ),
              _Deslizador(
                titulo: 'Numero de filas',
                valor: d.filas.toDouble(),
                min: 1,
                max: 12,
                divisiones: 11,
                unidad: 'filas',
                decimales: 0,
                onChanged: (double v) =>
                    store.actualizar(d.copyWith(filas: v.round())),
              ),
              _Deslizador(
                titulo: 'Taladros por fila',
                valor: d.taladrosPorFila.toDouble(),
                min: 1,
                max: 20,
                divisiones: 19,
                unidad: 'taladros',
                decimales: 0,
                onChanged: (double v) =>
                    store.actualizar(d.copyWith(taladrosPorFila: v.round())),
              ),
              EnumDropdown<MeshGeometry>(
                // Se dice "geometria" y no "tipo de malla" para no confundir
                // la forma de la celda con el contexto minero (subterranea o
                // superficial) que se declara al inicio de la pantalla.
                etiqueta: 'Geometria de la malla',
                valor: d.geometria,
                opciones: MeshGeometry.values,
                textoDe: (MeshGeometry m) => m.etiqueta,
                onChanged: (MeshGeometry m) =>
                    store.actualizar(d.copyWith(geometria: m)),
              ),
              EnumDropdown<EnergyCategory>(
                etiqueta: 'Categoria energetica conceptual',
                valor: d.energia,
                opciones: EnergyCategory.values,
                textoDe: (EnergyCategory e) => e.etiqueta,
                onChanged: (EnergyCategory e) =>
                    store.actualizar(d.copyWith(energia: e)),
              ),
              EnumDropdown<DelayPattern>(
                etiqueta: 'Secuencia de retardos',
                valor: d.secuencia,
                opciones: DelayPattern.values,
                textoDe: (DelayPattern p) => p.etiqueta,
                onChanged: store.cambiarSecuencia,
              ),
            ],
          ),
        ),
        const SectionTitle(
          'Indicadores educativos',
          icono: Icons.speed_outlined,
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  RiskChip(outlook.nivelRiesgo),
                  const SizedBox(width: 8),
                  RiskChip(
                    riesgo.nivel,
                    etiqueta: 'Geometria: ${riesgo.puntaje}/100',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              MetricBar(
                titulo: 'Eficiencia conceptual estimada',
                valor: outlook.eficienciaNormalizada,
                texto: '${outlook.indiceEficiencia} / 100',
                color: AppColors.deRiesgo(outlook.nivelRiesgo),
              ),
              const SizedBox(height: 14),
              MetricBar(
                titulo: 'Relacion S/B respecto al rango de referencia',
                valor: _normalizarEnRango(
                  g.relacionSobreBurden,
                  config.rangoSobreBurden.min,
                  config.rangoSobreBurden.max,
                ),
                texto: Fmt.num2(g.relacionSobreBurden),
              ),
              const SizedBox(height: 14),
              MetricBar(
                titulo: 'Burden en diametros respecto al rango educativo',
                valor: _normalizarEnRango(
                  g.burdenEnDiametros,
                  config.rangoBurdenDiametro.min,
                  config.rangoBurdenDiametro.max,
                ),
                texto: '${Fmt.num2(g.burdenEnDiametros, 1)} D',
              ),
              const Divider(height: 26),
              ResultRow(
                etiqueta: 'Uniformidad de la malla',
                valor: '-',
                nota: outlook.uniformidad,
              ),
              ResultRow(
                etiqueta: 'Fragmentacion conceptual',
                valor: '-',
                nota: outlook.fragmentacion,
              ),
              ResultRow(
                etiqueta: 'Desplazamiento conceptual',
                valor: '-',
                nota: outlook.desplazamiento,
              ),
              ResultRow(
                etiqueta: 'Sobreexcavacion',
                valor: '-',
                nota: outlook.sobreexcavacion,
              ),
              ResultRow(
                etiqueta: 'Subexcavacion',
                valor: '-',
                nota: outlook.subexcavacion,
              ),
              ResultRow(
                etiqueta: 'Volumen geometrico conceptual',
                valor: Fmt.conUnidad(g.volumenConceptualM3, 'm³'),
              ),
              ResultRow(
                etiqueta: 'Taladros en la malla',
                valor: '${g.totalTaladros}',
              ),
            ],
          ),
        ),
        const SectionTitle(
          'Observaciones de la simulacion',
          icono: Icons.comment_outlined,
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: outlook.observaciones
                .map(
                  (String o) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.arrow_right,
                          size: 18,
                          color: tema.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(o, style: tema.textTheme.bodySmall),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Naturaleza de esta simulacion',
                style: tema.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'La representacion es geometrica y las lecturas provienen de '
                'un sistema de reglas cualitativas declarado en '
                'docs/formulas.md. No se resuelve ninguna ecuacion de '
                'detonacion, propagacion de ondas o fragmentacion real. '
                'Los indicadores solo permiten comparar variantes del mismo '
                'ejercicio entre si.',
                style: tema.textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.indicadorResultados,
                style: tema.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return envolverModulo(
      context: context,
      titulo: 'Simulacion conceptual',
      cuerpo: cuerpo,
      embebida: widget.embebida,
    );
  }

  /// Normaliza un valor dentro de un rango para mostrarlo en una barra.
  double _normalizarEnRango(double valor, double min, double max) {
    if (max <= min) {
      return 0;
    }
    return ((valor - min) / (max - min)).clamp(0.0, 1.0).toDouble();
  }
}

/// Tarjeta que declara el tipo de malla del ejercicio activo.
///
/// Muestra el resultado junto con los cuatro rasgos que lo sustentan, en la
/// misma linea del resto de la aplicacion: ningun valor se presenta solo.
class _TarjetaTipoMalla extends StatelessWidget {
  const _TarjetaTipoMalla(this.evaluacion);

  final MeshTypeAssessment evaluacion;

  IconData get _icono {
    switch (evaluacion.tipo) {
      case MeshEnvironment.subterranea:
        return Icons.terrain_outlined;
      case MeshEnvironment.superficial:
        return Icons.landscape_outlined;
      case MeshEnvironment.ambas:
        return Icons.compare_arrows_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme esquema = tema.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: esquema.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icono, color: esquema.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      evaluacion.tipo.etiqueta,
                      style: tema.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: esquema.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      evaluacion.resumen,
                      style: tema.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            evaluacion.tipo.descripcion,
            style: tema.textTheme.bodyMedium,
          ),
          const Divider(height: 24),
          Text(
            'Rasgos que definen la clasificacion',
            style: tema.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          ...evaluacion.criterios.map(
            (MeshTypeCriterion c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          c.nombre,
                          style: tema.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        c.valor,
                        style: tema.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _MarcaMetodo(
                        texto: 'Sub',
                        activa: c.compatibleSubterranea,
                      ),
                      const SizedBox(width: 4),
                      _MarcaMetodo(
                        texto: 'Sup',
                        activa: c.compatibleSuperficial,
                      ),
                    ],
                  ),
                  Text(
                    c.referencia,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: esquema.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            'Los rangos son academicos y sirven para reconocer el contexto de '
            'la malla; no identifican un metodo de explotacion real ni '
            'reemplazan el criterio de un ingeniero.',
            style: tema.textTheme.bodySmall?.copyWith(
              color: esquema.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Marca compacta que indica si un rasgo es compatible con un metodo.
class _MarcaMetodo extends StatelessWidget {
  const _MarcaMetodo({required this.texto, required this.activa});

  final String texto;
  final bool activa;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final Color color =
        activa ? AppColors.riesgoBajo : tema.colorScheme.outlineVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        texto,
        style: tema.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: activa ? AppColors.riesgoBajo : tema.colorScheme.outline,
        ),
      ),
    );
  }
}

class _Deslizador extends StatelessWidget {
  const _Deslizador({
    required this.titulo,
    required this.valor,
    required this.min,
    required this.max,
    required this.unidad,
    required this.onChanged,
    this.decimales = 2,
    this.divisiones = 40,
  });

  final String titulo;
  final double valor;
  final double min;
  final double max;
  final String unidad;
  final ValueChanged<double> onChanged;
  final int decimales;
  final int divisiones;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final double seguro = valor.clamp(min, max).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(titulo, style: tema.textTheme.bodyMedium),
            ),
            Text(
              '${seguro.toStringAsFixed(decimales)} $unidad',
              style: tema.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: tema.colorScheme.primary,
              ),
            ),
          ],
        ),
        Slider(
          value: seguro,
          min: min,
          max: max,
          divisions: divisiones,
          label: seguro.toStringAsFixed(decimales),
          onChanged: onChanged,
          // La vibracion se emite al soltar el control: hacerlo en cada paso
          // del deslizador resultaria invasivo.
          onChangeEnd: (_) => UiFeedback.ajuste(),
        ),
      ],
    );
  }
}

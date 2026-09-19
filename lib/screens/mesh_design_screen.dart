import 'package:flutter/material.dart';

import '../calculators/burden_calculator.dart';
import '../calculators/geometry_calculator.dart';
import '../calculators/risk_classifier.dart';
import '../models/blast_design.dart';
import '../models/education_config.dart';
import '../models/geometry_result.dart';
import '../models/risk_assessment.dart';
import '../models/risk_level.dart';
import '../models/validation.dart';
import '../services/config_service.dart';
import '../services/design_store.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/app_card.dart';
import '../widgets/numeric_field.dart';
import '../widgets/risk_indicator.dart';
import '../widgets/safety_banner.dart';
import 'screen_scaffold.dart';

/// Modulo 2: diseno de malla.
///
/// Entrada de los diez parametros geometricos del ejercicio y calculo
/// inmediato de las relaciones derivadas, con validacion y clasificacion de
/// riesgo conceptual.
class MeshDesignScreen extends StatefulWidget {
  const MeshDesignScreen({super.key, this.embebida = false});

  final bool embebida;

  @override
  State<MeshDesignScreen> createState() => _MeshDesignScreenState();
}

class _MeshDesignScreenState extends State<MeshDesignScreen> {
  final GeometryCalculator _geometria = const GeometryCalculator();

  late final TextEditingController _diametro;
  late final TextEditingController _burden;
  late final TextEditingController _espaciamiento;
  late final TextEditingController _altura;
  late final TextEditingController _longitud;
  late final TextEditingController _subperforacion;
  late final TextEditingController _taco;
  late final TextEditingController _inclinacion;
  late final TextEditingController _filas;
  late final TextEditingController _taladros;

  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) {
      return;
    }
    _inicializado = true;
    final BlastDesign d = DesignScope.of(context).design;
    _diametro = TextEditingController(text: Fmt.num2(d.diametroMm, 0));
    _burden = TextEditingController(text: Fmt.num2(d.burdenM));
    _espaciamiento = TextEditingController(text: Fmt.num2(d.espaciamientoM));
    _altura = TextEditingController(text: Fmt.num2(d.alturaBancoM));
    _longitud = TextEditingController(text: Fmt.num2(d.longitudPerforacionM));
    _subperforacion = TextEditingController(text: Fmt.num2(d.subperforacionM));
    _taco = TextEditingController(text: Fmt.num2(d.tacoM));
    _inclinacion = TextEditingController(text: Fmt.num2(d.inclinacionGrados, 0));
    _filas = TextEditingController(text: '${d.filas}');
    _taladros = TextEditingController(text: '${d.taladrosPorFila}');
  }

  @override
  void dispose() {
    _diametro.dispose();
    _burden.dispose();
    _espaciamiento.dispose();
    _altura.dispose();
    _longitud.dispose();
    _subperforacion.dispose();
    _taco.dispose();
    _inclinacion.dispose();
    _filas.dispose();
    _taladros.dispose();
    super.dispose();
  }

  void _publicar() {
    final DesignStore store = DesignScope.of(context);
    final BlastDesign actual = store.design;
    store.actualizar(
      actual.copyWith(
        diametroMm: Fmt.parseDouble(_diametro.text) ?? actual.diametroMm,
        burdenM: Fmt.parseDouble(_burden.text) ?? actual.burdenM,
        espaciamientoM:
            Fmt.parseDouble(_espaciamiento.text) ?? actual.espaciamientoM,
        alturaBancoM: Fmt.parseDouble(_altura.text) ?? actual.alturaBancoM,
        longitudPerforacionM:
            Fmt.parseDouble(_longitud.text) ?? actual.longitudPerforacionM,
        subperforacionM:
            Fmt.parseDouble(_subperforacion.text) ?? actual.subperforacionM,
        tacoM: Fmt.parseDouble(_taco.text) ?? actual.tacoM,
        inclinacionGrados:
            Fmt.parseDouble(_inclinacion.text) ?? actual.inclinacionGrados,
        filas: Fmt.parseIntEstricto(_filas.text) ?? actual.filas,
        taladrosPorFila:
            Fmt.parseIntEstricto(_taladros.text) ?? actual.taladrosPorFila,
      ),
    );
  }

  void _sugerirGeometria() {
    final EducationConfig config = ConfigService.instance.config;
    final BurdenCalculator calc = BurdenCalculator(config);
    final double diametro =
        Fmt.parseDouble(_diametro.text) ?? DesignScope.of(context).design.diametroMm;
    final double burden = calc.burdenDesdeDiametro(diametro);
    final double espaciamiento = calc.espaciamientoDesdeBurden(burden);
    _burden.text = Fmt.num2(burden);
    _espaciamiento.text = Fmt.num2(espaciamiento);
    _publicar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sugerencia educativa aplicada con k_B = '
          '${config.factorBurdenDiametro.toStringAsFixed(2)} y k_S = '
          '${config.factorEspaciamientoBurden.toStringAsFixed(2)}. '
          'No es un valor de diseno operativo.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DesignStore store = DesignScope.of(context);
    final BlastDesign d = store.design;
    final EducationConfig config = ConfigService.instance.config;
    final GeometryResult g = _geometria.calcular(d);
    final RiskAssessment riesgo = RiskClassifier(config).clasificar(d, g);
    final ValidationResult validacion =
        Validators(config).validarDiseno(d, g);
    final Validators validadores = Validators(config);

    final Widget cuerpo = ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      children: <Widget>[
        const SafetyBanner(compacto: true),
        const SectionTitle(
          'Parametros geometricos',
          icono: Icons.edit_outlined,
          subtitulo: 'Los resultados se recalculan al escribir.',
        ),
        AppCard(
          child: Column(
            children: <Widget>[
              NumericField(
                controller: _diametro,
                etiqueta: 'Diametro del taladro',
                unidad: 'mm',
                icono: Icons.circle_outlined,
                ayuda: 'Rango educativo ${config.rangoDiametroMm} mm.',
                validator: (String? v) =>
                    validadores.enRango(v, 'El diametro', config.rangoDiametroMm, 'mm'),
                onChanged: (_) => _publicar(),
              ),
              NumericField(
                controller: _burden,
                etiqueta: 'Burden (B)',
                unidad: 'm',
                icono: Icons.swap_vert,
                ayuda: 'Distancia perpendicular a la cara libre.',
                validator: (String? v) => Validators.positivo(v, 'el burden'),
                onChanged: (_) => _publicar(),
              ),
              NumericField(
                controller: _espaciamiento,
                etiqueta: 'Espaciamiento (S)',
                unidad: 'm',
                icono: Icons.swap_horiz,
                ayuda: 'Distancia entre taladros de la misma fila.',
                validator: (String? v) =>
                    Validators.positivo(v, 'el espaciamiento'),
                onChanged: (_) => _publicar(),
              ),
              NumericField(
                controller: _altura,
                etiqueta: 'Altura de banco (H)',
                unidad: 'm',
                icono: Icons.height,
                ayuda: 'Rango educativo ${config.rangoAlturaBancoM} m.',
                validator: (String? v) => validadores.enRango(
                  v,
                  'La altura de banco',
                  config.rangoAlturaBancoM,
                  'm',
                ),
                onChanged: (_) => _publicar(),
              ),
              NumericField(
                controller: _longitud,
                etiqueta: 'Longitud de perforacion (L)',
                unidad: 'm',
                icono: Icons.straighten,
                ayuda: 'Debe ser coherente con la altura y la subperforacion.',
                validator: (String? v) =>
                    Validators.positivo(v, 'la longitud de perforacion'),
                onChanged: (_) => _publicar(),
              ),
              NumericField(
                controller: _subperforacion,
                etiqueta: 'Subperforacion (J)',
                unidad: 'm',
                icono: Icons.vertical_align_bottom,
                ayuda: 'Longitud perforada bajo el nivel de piso.',
                validator: (String? v) =>
                    Validators.noNegativo(v, 'la subperforacion'),
                onChanged: (_) => _publicar(),
              ),
              NumericField(
                controller: _taco,
                etiqueta: 'Taco (T)',
                unidad: 'm',
                icono: Icons.vertical_align_top,
                ayuda: 'Porcion superior inerte del taladro.',
                validator: (String? v) => Validators.noNegativo(v, 'el taco'),
                onChanged: (_) => _publicar(),
              ),
              NumericField(
                controller: _inclinacion,
                etiqueta: 'Inclinacion respecto a la vertical',
                unidad: 'grados',
                icono: Icons.rotate_right,
                ayuda: 'Rango educativo ${config.rangoInclinacionGrados} grados.',
                validator: (String? v) =>
                    Validators.noNegativo(v, 'la inclinacion'),
                onChanged: (_) => _publicar(),
              ),
              NumericField(
                controller: _filas,
                etiqueta: 'Numero de filas',
                unidad: 'filas',
                soloEnteros: true,
                icono: Icons.table_rows_outlined,
                validator: (String? v) =>
                    Validators.conteoEntero(v, 'el numero de filas'),
                onChanged: (_) => _publicar(),
              ),
              NumericField(
                controller: _taladros,
                etiqueta: 'Taladros por fila',
                unidad: 'taladros',
                soloEnteros: true,
                icono: Icons.view_column_outlined,
                validator: (String? v) =>
                    Validators.conteoEntero(v, 'los taladros por fila'),
                onChanged: (_) => _publicar(),
              ),
              EnumDropdown<MeshGeometry>(
                etiqueta: 'Geometria de la malla',
                valor: d.geometria,
                opciones: MeshGeometry.values,
                textoDe: (MeshGeometry m) => m.etiqueta,
                ayuda: d.geometria.descripcion,
                onChanged: (MeshGeometry m) =>
                    store.actualizar(d.copyWith(geometria: m)),
              ),
              OutlinedButton.icon(
                onPressed: _sugerirGeometria,
                icon: const Icon(Icons.auto_fix_high_outlined),
                label: const Text('Sugerir B y S desde el diametro'),
              ),
            ],
          ),
        ),
        const SectionTitle(
          'Resultados geometricos',
          icono: Icons.calculate_outlined,
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ResultRow(
                etiqueta: 'Relacion espaciamiento / burden (S/B)',
                valor: Fmt.num2(g.relacionSobreBurden),
                destacado: true,
                nota: 'S/B = S ÷ B. Adimensional.',
              ),
              ResultRow(
                etiqueta: 'Area teorica influenciada por taladro',
                valor: Fmt.conUnidad(g.areaPorTaladroM2, 'm²'),
                nota: 'A = B x S.',
              ),
              ResultRow(
                etiqueta: 'Numero total de taladros',
                valor: '${g.totalTaladros}',
                nota: 'N = filas x taladros por fila.',
              ),
              ResultRow(
                etiqueta: 'Volumen conceptual por taladro',
                valor: Fmt.conUnidad(g.volumenPorTaladroM3, 'm³'),
                nota: 'V = B x S x H.',
              ),
              ResultRow(
                etiqueta: 'Volumen geometrico conceptual total',
                valor: Fmt.conUnidad(g.volumenConceptualM3, 'm³'),
                destacado: true,
                nota: 'Banco ideal, sin perdidas ni discontinuidades.',
              ),
              ResultRow(
                etiqueta: 'Longitud cargada conceptual',
                valor: Fmt.conUnidad(g.longitudCargadaConceptualM, 'm'),
                nota: 'Solo geometria: L - T. No representa cantidad alguna.',
              ),
              ResultRow(
                etiqueta: 'Longitud de taco',
                valor: Fmt.conUnidad(g.tacoM, 'm'),
                nota: '${Fmt.num2(g.porcentajeTaco, 1)} % de la longitud '
                    'del taladro.',
              ),
              const Divider(),
              ResultRow(
                etiqueta: 'Burden en diametros',
                valor: '${Fmt.num2(g.burdenEnDiametros, 1)} D',
              ),
              ResultRow(
                etiqueta: 'Espaciamiento en diametros',
                valor: '${Fmt.num2(g.espaciamientoEnDiametros, 1)} D',
              ),
              ResultRow(
                etiqueta: 'Subperforacion en diametros',
                valor: '${Fmt.num2(g.subperforacionEnDiametros, 1)} D',
              ),
              ResultRow(
                etiqueta: 'Esbeltez (L/B)',
                valor: Fmt.num2(g.esbeltez, 1),
              ),
              ResultRow(
                etiqueta: 'Longitud geometrica teorica',
                valor: Fmt.conUnidad(g.longitudTeoricaM, 'm'),
                nota: 'L = H ÷ cos(inclinacion) + J.',
              ),
              ResultRow(
                etiqueta: 'Extension de la malla',
                valor: '${Fmt.num2(g.anchoMallaM)} x '
                    '${Fmt.num2(g.profundidadMallaM)} m',
              ),
            ],
          ),
        ),
        const SectionTitle(
          'Clasificacion conceptual de riesgo',
          icono: Icons.shield_outlined,
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  RiskChip(riesgo.nivel),
                  const Spacer(),
                  Text(
                    'Criterios conformes: ${riesgo.puntaje} / 100',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                riesgo.nivel.descripcion,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              ...riesgo.hallazgos.map(
                (RiskFinding h) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.deRiesgo(h.nivel),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${h.criterio}: ${h.valor}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 2),
                        child: Text(
                          '${h.mensaje}\nReferencia: ${h.rangoReferencia}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SectionTitle(
          'Mensajes de validacion',
          icono: Icons.rule_outlined,
        ),
        _TarjetaValidacion(validacion: validacion),
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Limitaciones del modelo',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.limitacionModelo,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.indicadorResultados,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
      titulo: 'Diseno de malla',
      cuerpo: cuerpo,
      embebida: widget.embebida,
    );
  }
}

class _TarjetaValidacion extends StatelessWidget {
  const _TarjetaValidacion({required this.validacion});

  final ValidationResult validacion;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    if (validacion.issues.isEmpty) {
      return AppCard(
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.riesgoBajo,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sin observaciones: los datos ingresados son coherentes entre '
                'si y estan dentro de los rangos educativos configurados.',
                style: tema.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: validacion.issues
            .map(
              (ValidationIssue e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(_icono(e.severidad), size: 20, color: _color(e.severidad)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            e.campo,
                            style: tema.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _color(e.severidad),
                            ),
                          ),
                          Text(e.mensaje, style: tema.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  IconData _icono(IssueSeverity s) {
    switch (s) {
      case IssueSeverity.informacion:
        return Icons.info_outline;
      case IssueSeverity.advertencia:
        return Icons.warning_amber_outlined;
      case IssueSeverity.error:
        return Icons.error_outline;
    }
  }

  Color _color(IssueSeverity s) {
    switch (s) {
      case IssueSeverity.informacion:
        return AppColors.rocaClara;
      case IssueSeverity.advertencia:
        return AppColors.riesgoMedio;
      case IssueSeverity.error:
        return AppColors.riesgoAlto;
    }
  }
}

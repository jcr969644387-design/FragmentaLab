import 'package:flutter/material.dart';

import '../calculators/burden_calculator.dart';
import '../models/blast_design.dart';
import '../models/education_config.dart';
import '../models/formula_explanation.dart';
import '../services/config_service.dart';
import '../services/design_store.dart';
import '../utils/app_strings.dart';
import '../utils/formatters.dart';
import '../utils/ui_feedback.dart';
import '../utils/validators.dart';
import '../widgets/app_card.dart';
import '../widgets/formula_card.dart';
import '../widgets/numeric_field.dart';
import '../widgets/risk_indicator.dart';
import '../widgets/safety_banner.dart';
import 'screen_scaffold.dart';

/// Modulo 2: calculadora educativa de burden y espaciamiento.
///
/// El modelo es configurable a proposito: el estudiante puede mover los
/// coeficientes y comprobar que no existe una unica formula valida para todos
/// los casos.
class BurdenSpacingScreen extends StatefulWidget {
  const BurdenSpacingScreen({super.key, this.embebida = false});

  final bool embebida;

  @override
  State<BurdenSpacingScreen> createState() => _BurdenSpacingScreenState();
}

class _BurdenSpacingScreenState extends State<BurdenSpacingScreen> {
  final TextEditingController _diametro = TextEditingController();
  bool _inicializado = false;
  double? _kB;
  double? _kS;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) {
      return;
    }
    _inicializado = true;
    final BlastDesign d = DesignScope.of(context).design;
    _diametro.text = Fmt.num2(d.diametroMm, 0);
    final EducationConfig config = ConfigService.instance.config;
    _kB = config.factorBurdenDiametro;
    _kS = config.factorEspaciamientoBurden;
  }

  @override
  void dispose() {
    _diametro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final EducationConfig config = ConfigService.instance.config;
    final BurdenCalculator calc = BurdenCalculator(config);
    final DesignStore store = DesignScope.of(context);

    final double diametro = Fmt.parseDouble(_diametro.text) ?? 0;
    final double kB = _kB ?? config.factorBurdenDiametro;
    final double kS = _kS ?? config.factorEspaciamientoBurden;

    final double burden = calc.burdenDesdeDiametro(diametro, factor: kB);
    final double espaciamiento =
        calc.espaciamientoDesdeBurden(burden, factor: kS);

    final FormulaExplanation expBurden =
        calc.explicarBurden(diametro, factor: kB);
    final FormulaExplanation expEspaciamiento =
        calc.explicarEspaciamiento(burden, factor: kS);
    final FormulaExplanation expRelacion =
        calc.explicarRelacion(espaciamiento, burden);

    final Widget cuerpo = ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      children: <Widget>[
        const SafetyBanner(compacto: true),
        const SectionTitle(
          'Datos de entrada',
          icono: Icons.input,
          subtitulo: 'Un solo dato de partida: el diametro del taladro.',
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              NumericField(
                controller: _diametro,
                etiqueta: 'Diametro del taladro',
                unidad: 'mm',
                icono: Icons.circle_outlined,
                ayuda: 'Rango educativo ${config.rangoDiametroMm} mm.',
                validator: (String? v) => Validators(config)
                    .enRango(v, 'El diametro', config.rangoDiametroMm, 'mm'),
                onChanged: (_) => setState(() {}),
              ),
              Text(
                'Coeficientes educativos',
                style: tema.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Los valores iniciales provienen del archivo de configuracion '
                'local. Modificalos para comparar escenarios: es el objetivo '
                'del modulo.',
                style: tema.textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              Text(
                'k_B = ${kB.toStringAsFixed(2)} diametros de burden',
                style: tema.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Slider(
                value: kB
                    .clamp(
                      config.rangoBurdenDiametro.min,
                      config.rangoBurdenDiametro.max,
                    )
                    .toDouble(),
                min: config.rangoBurdenDiametro.min,
                max: config.rangoBurdenDiametro.max,
                divisions: 50,
                label: kB.toStringAsFixed(2),
                onChanged: (double v) => setState(() => _kB = v),
                onChangeEnd: (_) => UiFeedback.ajuste(),
              ),
              Text(
                'k_S = ${kS.toStringAsFixed(2)} (relacion S/B)',
                style: tema.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Slider(
                value: kS
                    .clamp(
                      config.rangoSobreBurden.min,
                      config.rangoSobreBurden.max,
                    )
                    .toDouble(),
                min: config.rangoSobreBurden.min,
                max: config.rangoSobreBurden.max,
                divisions: 50,
                label: kS.toStringAsFixed(2),
                onChanged: (double v) => setState(() => _kS = v),
                onChangeEnd: (_) => UiFeedback.ajuste(),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        UiFeedback.toque();
                        setState(() {
                          _kB = config.factorBurdenDiametro;
                          _kS = config.factorEspaciamientoBurden;
                        });
                      },
                      icon: const Icon(Icons.settings_backup_restore),
                      label: const Text('Valores del archivo'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SectionTitle('Resumen', icono: Icons.summarize_outlined),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ResultRow(
                etiqueta: 'Burden educativo (B)',
                valor: Fmt.conUnidad(burden, 'm'),
                destacado: true,
              ),
              ResultRow(
                etiqueta: 'Espaciamiento educativo (S)',
                valor: Fmt.conUnidad(espaciamiento, 'm'),
                destacado: true,
              ),
              ResultRow(
                etiqueta: 'Relacion S/B resultante',
                valor: Fmt.num2(
                  calc.relacionSobreBurden(espaciamiento, burden),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: burden <= 0
                    ? null
                    : () {
                        UiFeedback.confirmacion();
                        store.actualizar(
                          store.design.copyWith(
                            diametroMm: diametro,
                            burdenM: burden,
                            espaciamientoM: espaciamiento,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Valores enviados al ejercicio de malla. '
                              'Siguen siendo conceptuales.',
                            ),
                          ),
                        );
                      },
                icon: const Icon(Icons.send_outlined),
                label: const Text('Enviar al diseno de malla'),
              ),
            ],
          ),
        ),
        const SectionTitle('Formulas y explicacion', icono: Icons.functions),
        FormulaCard(expBurden),
        FormulaCard(expEspaciamiento),
        FormulaCard(expRelacion),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Por que el modulo usa coeficientes y no una formula unica',
                style: tema.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Existen multiples modelos geometricos para estimar burden y '
                'espaciamiento, y cada uno fue formulado bajo supuestos '
                'distintos de roca, banco y equipo. Fragmenta Lab no adopta '
                'ninguno como verdad: expone la relacion geometrica basica y '
                'deja los coeficientes a la vista y editables en '
                '${ConfigService.rutaAsset}, para que la discusion en clase '
                'sea sobre los supuestos y no sobre memorizar una constante.',
                style: tema.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.limitacionModelo,
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
      titulo: 'Burden y espaciamiento',
      cuerpo: cuerpo,
      embebida: widget.embebida,
    );
  }
}

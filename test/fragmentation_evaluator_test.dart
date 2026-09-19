import 'package:flutter_test/flutter_test.dart';
import 'package:fragmenta_lab/calculators/fragmentation_evaluator.dart';
import 'package:fragmenta_lab/calculators/geometry_calculator.dart';
import 'package:fragmenta_lab/models/blast_design.dart';
import 'package:fragmenta_lab/models/education_config.dart';
import 'package:fragmenta_lab/models/explosive_concept.dart';
import 'package:fragmenta_lab/models/fragmentation_outlook.dart';
import 'package:fragmenta_lab/models/risk_level.dart';
import 'package:fragmenta_lab/models/rock_context.dart';

void main() {
  final EducationConfig config = EducationConfig.porDefecto();
  final FragmentationEvaluator evaluador = FragmentationEvaluator(config);
  const GeometryCalculator geometria = GeometryCalculator();

  FragmentationOutlook evaluar(BlastDesign d) =>
      evaluador.evaluar(d, geometria.calcular(d));

  group('Evaluacion conceptual de fragmentacion', () {
    test('el ejemplo educativo obtiene un indice alto y riesgo bajo', () {
      final FragmentationOutlook o = evaluar(BlastDesign.ejemploEducativo());
      expect(o.indiceEficiencia, greaterThanOrEqualTo(70));
      expect(o.nivelRiesgo, RiskLevel.bajo);
      expect(o.eficienciaNormalizada, closeTo(o.indiceEficiencia / 100, 1e-9));
    });

    test('el indice se mantiene siempre entre 5 y 95', () {
      final FragmentationOutlook malo = evaluar(
        BlastDesign.ejemploEducativo().copyWith(
          burdenM: 9.0,
          espaciamientoM: 0.6,
          tacoM: 0.1,
          subperforacionM: 4.0,
          energia: EnergyCategory.baja,
          dureza: RockHardness.muyDura,
          agua: WaterPresence.saturado,
          resistenciaAgua: WaterResistance.baja,
        ),
      );
      expect(malo.indiceEficiencia, greaterThanOrEqualTo(5));
      expect(malo.indiceEficiencia, lessThanOrEqualTo(95));
      expect(malo.nivelRiesgo, RiskLevel.alto);
    });

    test('un burden excesivo produce tendencia a fragmentacion gruesa', () {
      final FragmentationOutlook o = evaluar(
        BlastDesign.ejemploEducativo().copyWith(burdenM: 5.0),
      );
      expect(o.fragmentacion, contains('gruesa'));
    });

    test('la energia baja frente a roca muy dura reduce el indice', () {
      final int base = evaluar(BlastDesign.ejemploEducativo()).indiceEficiencia;
      final int desbalanceado = evaluar(
        BlastDesign.ejemploEducativo().copyWith(
          energia: EnergyCategory.baja,
          dureza: RockHardness.muyDura,
        ),
      ).indiceEficiencia;
      expect(desbalanceado, lessThan(base));
    });

    test('agua declarada con baja resistencia al agua penaliza el resultado',
        () {
      final int seco = evaluar(BlastDesign.ejemploEducativo()).indiceEficiencia;
      final int conAgua = evaluar(
        BlastDesign.ejemploEducativo().copyWith(
          agua: WaterPresence.saturado,
          resistenciaAgua: WaterResistance.baja,
        ),
      ).indiceEficiencia;
      expect(conAgua, lessThan(seco));
    });

    test('el tresbolillo mejora la lectura de uniformidad', () {
      final FragmentationOutlook tresbolillo = evaluar(
        BlastDesign.ejemploEducativo(),
      );
      final FragmentationOutlook rectangular = evaluar(
        BlastDesign.ejemploEducativo().copyWith(
          geometria: MeshGeometry.rectangular,
        ),
      );
      expect(tresbolillo.uniformidad, contains('homogenea'));
      expect(rectangular.uniformidad, contains('aceptable'));
    });

    test('siempre entrega al menos una observacion', () {
      final FragmentationOutlook o = evaluar(BlastDesign.ejemploEducativo());
      expect(o.observaciones, isNotEmpty);
      expect(o.sobreexcavacion.isNotEmpty, isTrue);
      expect(o.subexcavacion.isNotEmpty, isTrue);
      expect(o.desplazamiento.isNotEmpty, isTrue);
    });
  });
}

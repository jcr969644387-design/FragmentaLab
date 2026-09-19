import 'package:flutter_test/flutter_test.dart';
import 'package:fragmenta_lab/calculators/geometry_calculator.dart';
import 'package:fragmenta_lab/calculators/risk_classifier.dart';
import 'package:fragmenta_lab/models/blast_design.dart';
import 'package:fragmenta_lab/models/education_config.dart';
import 'package:fragmenta_lab/models/risk_assessment.dart';
import 'package:fragmenta_lab/models/risk_level.dart';

void main() {
  final EducationConfig config = EducationConfig.porDefecto();
  final RiskClassifier clasificador = RiskClassifier(config);
  const GeometryCalculator geometria = GeometryCalculator();

  RiskAssessment clasificar(BlastDesign d) =>
      clasificador.clasificar(d, geometria.calcular(d));

  group('Clasificacion del riesgo', () {
    test('el ejemplo educativo se clasifica como riesgo bajo', () {
      final RiskAssessment r = clasificar(BlastDesign.ejemploEducativo());
      expect(r.nivel, RiskLevel.bajo);
      expect(r.puntaje, 100);
      expect(r.criticos, isEmpty);
    });

    test('evalua siempre los siete criterios', () {
      final RiskAssessment r = clasificar(BlastDesign.ejemploEducativo());
      expect(r.hallazgos.length, 7);
    });

    test('un burden excesivo respecto al diametro eleva el riesgo a alto', () {
      final RiskAssessment r = clasificar(
        BlastDesign.ejemploEducativo().copyWith(burdenM: 8.0),
      );
      expect(r.nivel, RiskLevel.alto);
      expect(r.criticos.isNotEmpty, isTrue);
    });

    test('una relacion S/B extrema se marca como critica', () {
      final RiskAssessment r = clasificar(
        BlastDesign.ejemploEducativo().copyWith(espaciamientoM: 7.0),
      );
      expect(
        r.criticos.any((RiskFinding h) => h.criterio == 'Relacion S/B'),
        isTrue,
      );
    });

    test('un taco muy corto se detecta como hallazgo de riesgo', () {
      final RiskAssessment r = clasificar(
        BlastDesign.ejemploEducativo().copyWith(tacoM: 0.2),
      );
      expect(r.nivel.orden, greaterThan(RiskLevel.bajo.orden));
      expect(
        r.hallazgos.any(
          (RiskFinding h) =>
              h.criterio == 'Relacion taco / burden' &&
              h.nivel != RiskLevel.bajo,
        ),
        isTrue,
      );
    });

    test('una longitud incoherente con la altura de banco es critica', () {
      final RiskAssessment r = clasificar(
        BlastDesign.ejemploEducativo().copyWith(longitudPerforacionM: 14.0),
      );
      expect(
        r.criticos.any(
          (RiskFinding h) =>
              h.criterio == 'Coherencia de longitud de perforacion',
        ),
        isTrue,
      );
    });

    test('detecta incoherencia entre geometria declarada y valores', () {
      final RiskAssessment r = clasificar(
        BlastDesign.ejemploEducativo().copyWith(
          geometria: MeshGeometry.cuadrada,
        ),
      );
      expect(
        r.hallazgos.any(
          (RiskFinding h) =>
              h.criterio == 'Coherencia de la geometria declarada' &&
              h.nivel == RiskLevel.medio,
        ),
        isTrue,
      );
    });

    test('el puntaje disminuye cuando aparecen hallazgos', () {
      final int base = clasificar(BlastDesign.ejemploEducativo()).puntaje;
      final int degradado = clasificar(
        BlastDesign.ejemploEducativo().copyWith(burdenM: 8.0, tacoM: 0.2),
      ).puntaje;
      expect(degradado, lessThan(base));
    });
  });

  group('Utilidades de nivel', () {
    test('nivelMasSevero devuelve el peor nivel de la lista', () {
      expect(
        nivelMasSevero(<RiskLevel>[
          RiskLevel.bajo,
          RiskLevel.alto,
          RiskLevel.medio,
        ]),
        RiskLevel.alto,
      );
      expect(nivelMasSevero(<RiskLevel>[]), RiskLevel.bajo);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fragmenta_lab/calculators/mesh_type_classifier.dart';
import 'package:fragmenta_lab/models/blast_design.dart';
import 'package:fragmenta_lab/models/mesh_type.dart';

void main() {
  const MeshTypeClassifier clasificador = MeshTypeClassifier();

  /// Ejercicio base al que cada prueba cambia solo lo que necesita.
  BlastDesign disenoCon({
    required double diametroMm,
    required double alturaBancoM,
    required double subperforacionM,
    required double longitudPerforacionM,
  }) {
    return BlastDesign.ejemploEducativo().copyWith(
      diametroMm: diametroMm,
      alturaBancoM: alturaBancoM,
      subperforacionM: subperforacionM,
      longitudPerforacionM: longitudPerforacionM,
    );
  }

  group('MeshTypeClassifier', () {
    test('el ejercicio de ejemplo es una malla superficial de banco', () {
      final MeshTypeAssessment r =
          clasificador.clasificar(BlastDesign.ejemploEducativo());

      expect(r.tipo, MeshEnvironment.superficial);
      expect(r.coincidenciasSuperficial, 4);
      expect(r.criterios.length, 4);
    });

    test('taladros cortos y de diametro pequeno dan malla subterranea', () {
      final MeshTypeAssessment r = clasificador.clasificar(
        disenoCon(
          diametroMm: 51,
          alturaBancoM: 3.5,
          subperforacionM: 0,
          longitudPerforacionM: 3.6,
        ),
      );

      expect(r.tipo, MeshEnvironment.subterranea);
      expect(r.coincidenciasSubterranea, 4);
      expect(r.coincidenciasSuperficial, 0);
    });

    test('la franja comun a los dos metodos se reporta como ambas', () {
      final MeshTypeAssessment r = clasificador.clasificar(
        disenoCon(
          diametroMm: 89,
          alturaBancoM: 4.5,
          subperforacionM: 0,
          longitudPerforacionM: 4.6,
        ),
      );

      expect(r.tipo, MeshEnvironment.ambas);
      expect(r.coincidenciasSubterranea, greaterThanOrEqualTo(3));
      expect(r.coincidenciasSuperficial, greaterThanOrEqualTo(3));
    });

    test('un banco grande no queda clasificado como subterraneo', () {
      final MeshTypeAssessment r = clasificador.clasificar(
        disenoCon(
          diametroMm: 165,
          alturaBancoM: 12,
          subperforacionM: 1.5,
          longitudPerforacionM: 13.5,
        ),
      );

      expect(r.tipo, MeshEnvironment.superficial);
      expect(r.coincidenciasSubterranea, 0);
    });

    test('cada criterio declara su valor y su rango de referencia', () {
      final MeshTypeAssessment r =
          clasificador.clasificar(BlastDesign.ejemploEducativo());

      for (final MeshTypeCriterion c in r.criterios) {
        expect(c.nombre, isNotEmpty);
        expect(c.valor, isNotEmpty);
        expect(c.referencia, isNotEmpty);
      }
      expect(r.resumen, contains('4'));
    });

    test('la subperforacion separa los dos metodos', () {
      final MeshTypeCriterion conSubperforacion = clasificador
          .clasificar(BlastDesign.ejemploEducativo())
          .criterios
          .firstWhere((MeshTypeCriterion c) => c.nombre == 'Subperforacion');

      expect(conSubperforacion.compatibleSuperficial, isTrue);
      expect(conSubperforacion.compatibleSubterranea, isFalse);

      final MeshTypeCriterion sinSubperforacion = clasificador
          .clasificar(
            BlastDesign.ejemploEducativo().copyWith(subperforacionM: 0),
          )
          .criterios
          .firstWhere((MeshTypeCriterion c) => c.nombre == 'Subperforacion');

      expect(sinSubperforacion.compatibleSubterranea, isTrue);
      expect(sinSubperforacion.compatibleSuperficial, isFalse);
    });
  });
}

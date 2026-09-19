import 'package:flutter_test/flutter_test.dart';
import 'package:fragmenta_lab/calculators/geometry_calculator.dart';
import 'package:fragmenta_lab/models/blast_design.dart';
import 'package:fragmenta_lab/models/education_config.dart';
import 'package:fragmenta_lab/models/geometry_result.dart';
import 'package:fragmenta_lab/models/validation.dart';
import 'package:fragmenta_lab/utils/validators.dart';

void main() {
  final EducationConfig config = EducationConfig.porDefecto();
  final Validators validadores = Validators(config);
  const GeometryCalculator geometria = GeometryCalculator();

  ValidationResult validar(BlastDesign d) {
    final GeometryResult g = geometria.calcular(d);
    return validadores.validarDiseno(d, g);
  }

  group('Validacion de campos', () {
    test('rechaza valores negativos', () {
      expect(Validators.positivo('-2', 'el burden'), isNotNull);
      expect(Validators.noNegativo('-0.5', 'el taco'), isNotNull);
    });

    test('rechaza el valor cero cuando se exige positivo', () {
      expect(Validators.positivo('0', 'el diametro'), isNotNull);
      expect(Validators.noNegativo('0', 'el taco'), isNull);
    });

    test('acepta coma como separador decimal', () {
      expect(Validators.positivo('2,6', 'el burden'), isNull);
    });

    test('rechaza texto no numerico', () {
      expect(Validators.positivo('abc', 'el burden'), isNotNull);
      expect(Validators.positivo('', 'el burden'), isNotNull);
    });

    test('exige numero entero en los conteos de taladros', () {
      expect(Validators.conteoEntero('3', 'las filas'), isNull);
      expect(Validators.conteoEntero('3.5', 'las filas'), isNotNull);
      expect(Validators.conteoEntero('0', 'las filas'), isNotNull);
      expect(Validators.conteoEntero('500', 'las filas'), isNotNull);
    });

    test('detecta valores fuera del rango educativo', () {
      expect(
        validadores.enRango('89', 'El diametro', config.rangoDiametroMm, 'mm'),
        isNull,
      );
      expect(
        validadores.enRango('900', 'El diametro', config.rangoDiametroMm, 'mm'),
        isNotNull,
      );
    });
  });

  group('Validacion global del ejercicio', () {
    test('el ejemplo educativo no produce errores bloqueantes', () {
      final ValidationResult r = validar(BlastDesign.ejemploEducativo());
      expect(r.esValido, isTrue);
      expect(r.errores, isEmpty);
    });

    test('detecta taco mayor que la longitud del taladro', () {
      final ValidationResult r = validar(
        BlastDesign.ejemploEducativo().copyWith(tacoM: 12.0),
      );
      expect(r.esValido, isFalse);
      expect(
        r.errores.any((ValidationIssue e) => e.campo == 'Taco'),
        isTrue,
      );
    });

    test('detecta altura de banco incompatible con la longitud', () {
      final ValidationResult r = validar(
        BlastDesign.ejemploEducativo().copyWith(
          alturaBancoM: 12.0,
          longitudPerforacionM: 8.0,
        ),
      );
      expect(r.esValido, isFalse);
      expect(
        r.errores.any(
          (ValidationIssue e) => e.campo == 'Longitud de perforacion',
        ),
        isTrue,
      );
    });

    test('detecta diametro igual a cero', () {
      final ValidationResult r = validar(
        BlastDesign.ejemploEducativo().copyWith(diametroMm: 0),
      );
      expect(r.esValido, isFalse);
      expect(
        r.errores.any((ValidationIssue e) => e.campo == 'Diametro'),
        isTrue,
      );
    });

    test('detecta burden y espaciamiento iguales a cero', () {
      final ValidationResult r = validar(
        BlastDesign.ejemploEducativo().copyWith(
          burdenM: 0,
          espaciamientoM: 0,
        ),
      );
      expect(r.errores.length, greaterThanOrEqualTo(2));
    });

    test('detecta subperforacion negativa', () {
      final ValidationResult r = validar(
        BlastDesign.ejemploEducativo().copyWith(subperforacionM: -0.5),
      );
      expect(
        r.errores.any((ValidationIssue e) => e.campo == 'Subperforacion'),
        isTrue,
      );
    });

    test('advierte relaciones geometricas fuera de rango', () {
      final ValidationResult r = validar(
        BlastDesign.ejemploEducativo().copyWith(
          burdenM: 1.0,
          espaciamientoM: 4.0,
        ),
      );
      expect(r.tieneAdvertencias, isTrue);
      expect(
        r.advertencias.any((ValidationIssue e) => e.campo == 'Relacion S/B'),
        isTrue,
      );
    });

    test('informa cuando la subperforacion es cero', () {
      final ValidationResult r = validar(
        BlastDesign.ejemploEducativo().copyWith(
          subperforacionM: 0,
          longitudPerforacionM: 8.0,
        ),
      );
      expect(r.informativos.isNotEmpty, isTrue);
    });
  });
}

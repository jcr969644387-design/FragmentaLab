import '../models/blast_design.dart';
import '../models/education_config.dart';
import '../models/geometry_result.dart';
import '../models/validation.dart';
import 'formatters.dart';

/// Validaciones de campos y de coherencia global del ejercicio.
class Validators {
  const Validators(this.config);

  final EducationConfig config;

  // --------------------------------------------------------------------
  // Validaciones de campo (para TextFormField)
  // --------------------------------------------------------------------

  /// Valida un campo numerico decimal obligatorio y estrictamente positivo.
  static String? positivo(String? valor, String etiqueta) {
    final double? numero = Fmt.parseDouble(valor);
    if (numero == null) {
      return 'Ingresa $etiqueta como numero.';
    }
    if (numero.isNaN || numero.isInfinite) {
      return 'El valor de $etiqueta no es un numero valido.';
    }
    if (numero < 0) {
      return '$etiqueta no puede ser negativo.';
    }
    if (numero == 0) {
      return '$etiqueta debe ser mayor que cero.';
    }
    return null;
  }

  /// Valida un campo numerico decimal obligatorio que admite el valor cero.
  static String? noNegativo(String? valor, String etiqueta) {
    final double? numero = Fmt.parseDouble(valor);
    if (numero == null) {
      return 'Ingresa $etiqueta como numero.';
    }
    if (numero.isNaN || numero.isInfinite) {
      return 'El valor de $etiqueta no es un numero valido.';
    }
    if (numero < 0) {
      return '$etiqueta no puede ser negativo.';
    }
    return null;
  }

  /// Valida un conteo: debe ser un entero positivo, no un decimal.
  static String? conteoEntero(String? valor, String etiqueta) {
    final String texto = (valor ?? '').trim();
    if (texto.isEmpty) {
      return 'Ingresa $etiqueta.';
    }
    final int? entero = Fmt.parseIntEstricto(texto);
    if (entero == null) {
      final double? decimal = Fmt.parseDouble(texto);
      if (decimal != null) {
        return '$etiqueta debe ser un numero entero de taladros.';
      }
      return 'Ingresa $etiqueta como numero entero.';
    }
    if (entero <= 0) {
      return '$etiqueta debe ser mayor que cero.';
    }
    if (entero > 200) {
      return 'Limite educativo: maximo 200 en $etiqueta.';
    }
    return null;
  }

  /// Valida un valor dentro de un rango educativo configurado.
  String? enRango(String? valor, String etiqueta, Rango rango, String unidad) {
    final String? base = noNegativo(valor, etiqueta);
    if (base != null) {
      return base;
    }
    final double numero = Fmt.parseDouble(valor)!;
    if (!rango.contiene(numero)) {
      return '$etiqueta fuera del rango educativo '
          '(${Fmt.num2(rango.min)} - ${Fmt.num2(rango.max)} $unidad).';
    }
    return null;
  }

  // --------------------------------------------------------------------
  // Validacion global del ejercicio
  // --------------------------------------------------------------------

  /// Valida la coherencia completa de un diseno junto a su geometria.
  ValidationResult validarDiseno(BlastDesign d, GeometryResult g) {
    final List<ValidationIssue> issues = <ValidationIssue>[];

    void error(String campo, String mensaje) => issues.add(
          ValidationIssue(
            campo: campo,
            mensaje: mensaje,
            severidad: IssueSeverity.error,
          ),
        );

    void advertir(String campo, String mensaje) => issues.add(
          ValidationIssue(
            campo: campo,
            mensaje: mensaje,
            severidad: IssueSeverity.advertencia,
          ),
        );

    void informar(String campo, String mensaje) => issues.add(
          ValidationIssue(
            campo: campo,
            mensaje: mensaje,
            severidad: IssueSeverity.informacion,
          ),
        );

    // Valores nulos, cero o negativos.
    if (d.diametroMm <= 0) {
      error('Diametro', 'El diametro del taladro debe ser mayor que cero.');
    }
    if (d.burdenM <= 0) {
      error('Burden', 'El burden debe ser mayor que cero.');
    }
    if (d.espaciamientoM <= 0) {
      error('Espaciamiento', 'El espaciamiento debe ser mayor que cero.');
    }
    if (d.alturaBancoM <= 0) {
      error('Altura de banco', 'La altura de banco debe ser mayor que cero.');
    }
    if (d.longitudPerforacionM <= 0) {
      error(
        'Longitud de perforacion',
        'La longitud de perforacion debe ser mayor que cero.',
      );
    }
    if (d.subperforacionM < 0) {
      error('Subperforacion', 'La subperforacion no puede ser negativa.');
    }
    if (d.tacoM < 0) {
      error('Taco', 'El taco no puede ser negativo.');
    }
    if (d.filas <= 0) {
      error('Filas', 'El numero de filas debe ser un entero mayor que cero.');
    }
    if (d.taladrosPorFila <= 0) {
      error(
        'Taladros por fila',
        'El numero de taladros por fila debe ser un entero mayor que cero.',
      );
    }

    // Coherencia geometrica.
    if (d.tacoM > 0 && d.tacoM >= d.longitudPerforacionM) {
      error(
        'Taco',
        'El taco (${Fmt.num2(d.tacoM)} m) no puede ser mayor o igual que la '
            'longitud del taladro (${Fmt.num2(d.longitudPerforacionM)} m).',
      );
    }
    if (d.longitudPerforacionM > 0 &&
        d.alturaBancoM > 0 &&
        d.longitudPerforacionM < d.alturaBancoM) {
      error(
        'Longitud de perforacion',
        'La longitud de perforacion (${Fmt.num2(d.longitudPerforacionM)} m) es '
            'menor que la altura de banco (${Fmt.num2(d.alturaBancoM)} m): el '
            'taladro no alcanzaria el nivel de piso.',
      );
    }
    if (d.subperforacionM >= d.longitudPerforacionM &&
        d.longitudPerforacionM > 0) {
      error(
        'Subperforacion',
        'La subperforacion no puede igualar ni superar la longitud total del '
            'taladro.',
      );
    }
    if (g.desviacionLongitudRelativa.abs() >
            config.toleranciaLongitudPerforacion &&
        d.longitudPerforacionM >= d.alturaBancoM) {
      advertir(
        'Longitud de perforacion',
        'La longitud ingresada se aparta '
            '${Fmt.porcentaje(g.desviacionLongitudRelativa.abs())} de la '
            'longitud geometrica teorica '
            '(${Fmt.num2(g.longitudTeoricaM)} m).',
      );
    }

    // Rangos educativos.
    if (!config.rangoDiametroMm.contiene(d.diametroMm) && d.diametroMm > 0) {
      advertir(
        'Diametro',
        'El diametro esta fuera del rango educativo '
            '(${config.rangoDiametroMm} mm).',
      );
    }
    if (!config.rangoAlturaBancoM.contiene(d.alturaBancoM) &&
        d.alturaBancoM > 0) {
      advertir(
        'Altura de banco',
        'La altura de banco esta fuera del rango educativo '
            '(${config.rangoAlturaBancoM} m).',
      );
    }
    if (!config.rangoInclinacionGrados.contiene(d.inclinacionGrados)) {
      advertir(
        'Inclinacion',
        'La inclinacion esta fuera del rango educativo '
            '(${config.rangoInclinacionGrados} grados).',
      );
    }
    if (d.burdenM > 0 && !config.rangoSobreBurden.contiene(g.relacionSobreBurden)) {
      advertir(
        'Relacion S/B',
        'La relacion S/B (${Fmt.num2(g.relacionSobreBurden)}) esta fuera del '
            'rango educativo configurado (${config.rangoSobreBurden}).',
      );
    }
    if (d.diametroMm > 0 &&
        !config.rangoBurdenDiametro.contiene(g.burdenEnDiametros)) {
      advertir(
        'Burden en diametros',
        'El burden equivale a ${Fmt.num2(g.burdenEnDiametros, 1)} diametros, '
            'fuera del rango educativo (${config.rangoBurdenDiametro}).',
      );
    }
    if (d.burdenM > 0 && !config.rangoTacoBurden.contiene(g.relacionTacoBurden)) {
      advertir(
        'Relacion taco/burden',
        'La relacion taco/burden (${Fmt.num2(g.relacionTacoBurden)}) esta '
            'fuera del rango educativo (${config.rangoTacoBurden}).',
      );
    }
    if (d.subperforacionM == 0) {
      informar(
        'Subperforacion',
        'Con subperforacion cero, el analisis conceptual del piso del banco '
            'pierde sentido: se usa solo para ejercicios comparativos.',
      );
    }

    return ValidationResult(issues);
  }
}

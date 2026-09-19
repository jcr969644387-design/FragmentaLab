/// Utilidades de formato numerico para la interfaz.
class Fmt {
  const Fmt._();

  /// Formatea un valor con la cantidad de decimales indicada.
  static String num2(double valor, [int decimales = 2]) {
    if (valor.isNaN || valor.isInfinite) {
      return '-';
    }
    return valor.toStringAsFixed(decimales);
  }

  /// Formatea un valor con su unidad.
  static String conUnidad(double valor, String unidad, [int decimales = 2]) {
    return '${num2(valor, decimales)} $unidad';
  }

  /// Formatea un porcentaje a partir de una fraccion (0.25 -> "25.0 %").
  static String porcentaje(double fraccion, [int decimales = 1]) {
    return '${num2(fraccion * 100, decimales)} %';
  }

  /// Convierte texto de entrada en double aceptando coma o punto decimal.
  static double? parseDouble(String? texto) {
    if (texto == null) {
      return null;
    }
    final String limpio = texto.trim().replaceAll(',', '.');
    if (limpio.isEmpty) {
      return null;
    }
    return double.tryParse(limpio);
  }

  /// Convierte texto de entrada en entero estricto (rechaza decimales).
  static int? parseIntEstricto(String? texto) {
    if (texto == null) {
      return null;
    }
    final String limpio = texto.trim().replaceAll(',', '.');
    if (limpio.isEmpty) {
      return null;
    }
    return int.tryParse(limpio);
  }
}

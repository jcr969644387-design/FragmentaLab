/// Patron conceptual de secuencia de iniciacion.
///
/// Fragmenta Lab representa unicamente el **orden relativo** de salida y su
/// efecto cualitativo. No describe conexiones, accesorios ni procedimientos
/// de iniciacion.
enum DelayPattern { uniforme, escalonada, porFilas, porTaladros }

extension DelayPatternX on DelayPattern {
  String get etiqueta {
    switch (this) {
      case DelayPattern.uniforme:
        return 'Secuencia uniforme';
      case DelayPattern.escalonada:
        return 'Secuencia escalonada';
      case DelayPattern.porFilas:
        return 'Secuencia por filas';
      case DelayPattern.porTaladros:
        return 'Secuencia por taladros';
    }
  }

  String get descripcion {
    switch (this) {
      case DelayPattern.uniforme:
        return 'Todos los taladros comparten el mismo numero de orden '
            'conceptual: la malla se representa saliendo como un solo grupo.';
      case DelayPattern.escalonada:
        return 'El orden avanza en diagonal combinando fila y columna, lo que '
            'se representa como una apertura progresiva en forma de cuna.';
      case DelayPattern.porFilas:
        return 'Cada fila recibe un numero de orden distinto y sale completa '
            'antes que la siguiente.';
      case DelayPattern.porTaladros:
        return 'Cada taladro recibe un numero de orden propio, generando la '
            'mayor cantidad de intervalos relativos.';
    }
  }
}

/// Un taladro dentro del plan conceptual de secuencia.
class DelayStep {
  const DelayStep({
    required this.fila,
    required this.columna,
    required this.orden,
    required this.intervaloRelativo,
  });

  /// Indice de fila (0 = fila mas cercana a la cara libre).
  final int fila;

  /// Indice de columna dentro de la fila.
  final int columna;

  /// Numero de orden conceptual de salida (1 = primero).
  final int orden;

  /// Intervalo relativo adimensional respecto al primer orden.
  ///
  /// Fragmenta Lab **no** entrega tiempos en milisegundos: el objetivo es
  /// comparar secuencias, no configurar una iniciacion real.
  final int intervaloRelativo;
}

/// Plan conceptual de secuencia de iniciacion.
class DelayPlan {
  const DelayPlan({
    required this.patron,
    required this.pasos,
    required this.ordenesDistintos,
    required this.direccionDesplazamiento,
    required this.efectoFragmentacion,
    required this.efectoVibracion,
  });

  final DelayPattern patron;
  final List<DelayStep> pasos;

  /// Cantidad de numeros de orden diferentes usados en la malla.
  final int ordenesDistintos;

  final String direccionDesplazamiento;
  final String efectoFragmentacion;
  final String efectoVibracion;

  int get totalTaladros => pasos.length;

  /// Taladros que comparten el mismo numero de orden (promedio).
  double get taladrosPorOrden =>
      ordenesDistintos == 0 ? 0 : pasos.length / ordenesDistintos;
}

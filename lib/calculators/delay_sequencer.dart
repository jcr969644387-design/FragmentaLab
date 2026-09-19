import '../models/delay_sequence.dart';

/// Generador conceptual de secuencias de iniciacion.
///
/// Produce unicamente numeros de **orden relativo** por taladro. No entrega
/// tiempos en milisegundos, no describe accesorios ni conexiones y no
/// constituye un plan de iniciacion. La fila 0 se interpreta como la mas
/// cercana a la cara libre.
class DelaySequencer {
  const DelaySequencer();

  DelayPlan generar({
    required DelayPattern patron,
    required int filas,
    required int taladrosPorFila,
  }) {
    final int f = filas <= 0 ? 1 : filas;
    final int c = taladrosPorFila <= 0 ? 1 : taladrosPorFila;
    final List<DelayStep> pasos = <DelayStep>[];

    for (int fila = 0; fila < f; fila++) {
      for (int columna = 0; columna < c; columna++) {
        final int orden = _orden(patron, fila, columna, c);
        pasos.add(
          DelayStep(
            fila: fila,
            columna: columna,
            orden: orden,
            intervaloRelativo: orden - 1,
          ),
        );
      }
    }

    final Set<int> ordenes = pasos.map((DelayStep p) => p.orden).toSet();

    return DelayPlan(
      patron: patron,
      pasos: pasos,
      ordenesDistintos: ordenes.length,
      direccionDesplazamiento: _direccion(patron),
      efectoFragmentacion: _fragmentacion(patron),
      efectoVibracion: _vibracion(patron),
    );
  }

  int _orden(DelayPattern patron, int fila, int columna, int columnas) {
    switch (patron) {
      case DelayPattern.uniforme:
        return 1;
      case DelayPattern.porFilas:
        return fila + 1;
      case DelayPattern.porTaladros:
        return fila * columnas + columna + 1;
      case DelayPattern.escalonada:
        // Avance en diagonal: los taladros situados en la misma diagonal
        // comparten orden, generando una apertura progresiva en cuna.
        return fila + columna + 1;
    }
  }

  String _direccion(DelayPattern patron) {
    switch (patron) {
      case DelayPattern.uniforme:
        return 'Empuje conceptual frontal simultaneo hacia la cara libre.';
      case DelayPattern.porFilas:
        return 'Avance conceptual perpendicular a la cara libre, fila por '
            'fila.';
      case DelayPattern.porTaladros:
        return 'Avance conceptual progresivo taladro por taladro, con frente '
            'de salida movil.';
      case DelayPattern.escalonada:
        return 'Avance conceptual en diagonal, con desplazamiento orientado '
            'hacia el vertice de apertura.';
    }
  }

  String _fragmentacion(DelayPattern patron) {
    switch (patron) {
      case DelayPattern.uniforme:
        return 'Sin intervalos relativos no existe cara libre progresiva: '
            'conceptualmente la fragmentacion tiende a ser menos uniforme.';
      case DelayPattern.porFilas:
        return 'Cada fila encuentra una cara libre generada por la anterior, '
            'lo que conceptualmente favorece la fragmentacion.';
      case DelayPattern.porTaladros:
        return 'La maxima cantidad de intervalos favorece conceptualmente la '
            'fragmentacion, a costa de un control mas exigente del diseno.';
      case DelayPattern.escalonada:
        return 'La apertura en diagonal crea caras libres adicionales en dos '
            'direcciones, lo que conceptualmente mejora la fragmentacion.';
    }
  }

  String _vibracion(DelayPattern patron) {
    switch (patron) {
      case DelayPattern.uniforme:
        return 'Al coincidir todos los ordenes, la vibracion conceptual '
            'esperada es la mas alta de las cuatro secuencias.';
      case DelayPattern.porFilas:
        return 'La separacion por filas reduce conceptualmente la vibracion '
            'respecto a una salida simultanea.';
      case DelayPattern.porTaladros:
        return 'Al separar cada taladro, la vibracion conceptual esperada es '
            'la mas baja de las cuatro secuencias.';
      case DelayPattern.escalonada:
        return 'La distribucion diagonal reparte la salida en el tiempo y '
            'reduce conceptualmente la vibracion.';
    }
  }
}

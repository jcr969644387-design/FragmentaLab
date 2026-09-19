import 'delay_sequence.dart';
import 'explosive_concept.dart';
import 'rock_context.dart';

/// Geometria conceptual de la malla de perforacion.
enum MeshGeometry { cuadrada, rectangular, tresbolillo }

extension MeshGeometryX on MeshGeometry {
  String get etiqueta {
    switch (this) {
      case MeshGeometry.cuadrada:
        return 'Cuadrada';
      case MeshGeometry.rectangular:
        return 'Rectangular';
      case MeshGeometry.tresbolillo:
        return 'Tresbolillo';
    }
  }

  String get descripcion {
    switch (this) {
      case MeshGeometry.cuadrada:
        return 'Burden y espaciamiento iguales: los taladros forman cuadrados '
            'alineados en filas y columnas.';
      case MeshGeometry.rectangular:
        return 'Espaciamiento distinto del burden: los taladros permanecen '
            'alineados pero la celda es rectangular.';
      case MeshGeometry.tresbolillo:
        return 'Las filas se desplazan medio espaciamiento, de modo que cada '
            'taladro queda enfrentado al espacio entre dos taladros de la '
            'fila anterior.';
    }
  }
}

/// Conjunto completo de parametros educativos de un ejercicio de malla.
///
/// El modelo es inmutable: cada pantalla produce una copia con `copyWith` y la
/// publica en el `DesignStore` para que el resto de modulos trabaje sobre el
/// mismo ejercicio.
class BlastDesign {
  const BlastDesign({
    required this.diametroMm,
    required this.burdenM,
    required this.espaciamientoM,
    required this.alturaBancoM,
    required this.longitudPerforacionM,
    required this.subperforacionM,
    required this.tacoM,
    required this.filas,
    required this.taladrosPorFila,
    required this.inclinacionGrados,
    required this.geometria,
    required this.energia,
    required this.resistenciaAgua,
    required this.dureza,
    required this.agua,
    required this.secuencia,
  });

  /// Ejercicio de partida usado al abrir la aplicacion.
  ///
  /// Es un caso **academico** de banco pequeno cuyo unico proposito es que el
  /// estudiante vea la pantalla con datos coherentes. No representa un diseno
  /// operativo ni una recomendacion de campo.
  factory BlastDesign.ejemploEducativo() {
    return const BlastDesign(
      diametroMm: 89,
      burdenM: 2.6,
      espaciamientoM: 3.0,
      alturaBancoM: 8.0,
      longitudPerforacionM: 8.9,
      subperforacionM: 0.9,
      tacoM: 2.4,
      filas: 3,
      taladrosPorFila: 6,
      inclinacionGrados: 0,
      geometria: MeshGeometry.tresbolillo,
      energia: EnergyCategory.media,
      resistenciaAgua: WaterResistance.buena,
      dureza: RockHardness.media,
      agua: WaterPresence.seco,
      secuencia: DelayPattern.porFilas,
    );
  }

  final double diametroMm;
  final double burdenM;
  final double espaciamientoM;
  final double alturaBancoM;
  final double longitudPerforacionM;
  final double subperforacionM;
  final double tacoM;
  final int filas;
  final int taladrosPorFila;
  final double inclinacionGrados;
  final MeshGeometry geometria;
  final EnergyCategory energia;
  final WaterResistance resistenciaAgua;
  final RockHardness dureza;
  final WaterPresence agua;
  final DelayPattern secuencia;

  double get diametroM => diametroMm / 1000.0;

  BlastDesign copyWith({
    double? diametroMm,
    double? burdenM,
    double? espaciamientoM,
    double? alturaBancoM,
    double? longitudPerforacionM,
    double? subperforacionM,
    double? tacoM,
    int? filas,
    int? taladrosPorFila,
    double? inclinacionGrados,
    MeshGeometry? geometria,
    EnergyCategory? energia,
    WaterResistance? resistenciaAgua,
    RockHardness? dureza,
    WaterPresence? agua,
    DelayPattern? secuencia,
  }) {
    return BlastDesign(
      diametroMm: diametroMm ?? this.diametroMm,
      burdenM: burdenM ?? this.burdenM,
      espaciamientoM: espaciamientoM ?? this.espaciamientoM,
      alturaBancoM: alturaBancoM ?? this.alturaBancoM,
      longitudPerforacionM: longitudPerforacionM ?? this.longitudPerforacionM,
      subperforacionM: subperforacionM ?? this.subperforacionM,
      tacoM: tacoM ?? this.tacoM,
      filas: filas ?? this.filas,
      taladrosPorFila: taladrosPorFila ?? this.taladrosPorFila,
      inclinacionGrados: inclinacionGrados ?? this.inclinacionGrados,
      geometria: geometria ?? this.geometria,
      energia: energia ?? this.energia,
      resistenciaAgua: resistenciaAgua ?? this.resistenciaAgua,
      dureza: dureza ?? this.dureza,
      agua: agua ?? this.agua,
      secuencia: secuencia ?? this.secuencia,
    );
  }
}

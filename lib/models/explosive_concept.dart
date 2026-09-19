/// Categoria educativa **abstracta** de energia relativa.
///
/// Fragmenta Lab no trabaja con productos, marcas, formulaciones ni cantidades:
/// unicamente con categorias conceptuales que permiten discutir en clase el
/// efecto relativo de la energia disponible sobre la fragmentacion esperada.
enum EnergyCategory { baja, media, alta }

/// Categoria educativa abstracta de resistencia al agua.
enum WaterResistance { baja, buena }

extension EnergyCategoryX on EnergyCategory {
  String get etiqueta {
    switch (this) {
      case EnergyCategory.baja:
        return 'Baja energia';
      case EnergyCategory.media:
        return 'Energia media';
      case EnergyCategory.alta:
        return 'Alta energia';
    }
  }

  /// Indice relativo adimensional usado solo para comparaciones cualitativas.
  double get indiceRelativo {
    switch (this) {
      case EnergyCategory.baja:
        return 0.7;
      case EnergyCategory.media:
        return 1.0;
      case EnergyCategory.alta:
        return 1.3;
    }
  }
}

extension WaterResistanceX on WaterResistance {
  String get etiqueta {
    switch (this) {
      case WaterResistance.baja:
        return 'Baja resistencia al agua';
      case WaterResistance.buena:
        return 'Buena resistencia al agua';
    }
  }
}

/// Perfil conceptual resultante de combinar una categoria energetica con una
/// categoria de resistencia al agua. Solo describe efectos cualitativos.
class ExplosiveConceptProfile {
  const ExplosiveConceptProfile({
    required this.energia,
    required this.resistenciaAgua,
    required this.energiaRelativa,
    required this.fragmentacionEsperada,
    required this.desplazamientoEsperado,
    required this.sensibilidadAlAgua,
    required this.adecuacionConceptual,
    required this.observacionEducativa,
  });

  final EnergyCategory energia;
  final WaterResistance resistenciaAgua;
  final String energiaRelativa;
  final String fragmentacionEsperada;
  final String desplazamientoEsperado;
  final String sensibilidadAlAgua;
  final String adecuacionConceptual;
  final String observacionEducativa;
}

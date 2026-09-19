/// Dureza conceptual del macizo rocoso para el analisis educativo.
enum RockHardness { blanda, media, dura, muyDura }

/// Presencia de agua en el taladro, en terminos conceptuales.
enum WaterPresence { seco, humedo, saturado }

extension RockHardnessX on RockHardness {
  String get etiqueta {
    switch (this) {
      case RockHardness.blanda:
        return 'Roca blanda';
      case RockHardness.media:
        return 'Roca de dureza media';
      case RockHardness.dura:
        return 'Roca dura';
      case RockHardness.muyDura:
        return 'Roca muy dura';
    }
  }

  /// Indice adimensional creciente con la dificultad conceptual de fragmentar.
  double get indice {
    switch (this) {
      case RockHardness.blanda:
        return 0.7;
      case RockHardness.media:
        return 1.0;
      case RockHardness.dura:
        return 1.25;
      case RockHardness.muyDura:
        return 1.5;
    }
  }
}

extension WaterPresenceX on WaterPresence {
  String get etiqueta {
    switch (this) {
      case WaterPresence.seco:
        return 'Taladro seco';
      case WaterPresence.humedo:
        return 'Taladro humedo';
      case WaterPresence.saturado:
        return 'Taladro con agua';
    }
  }
}

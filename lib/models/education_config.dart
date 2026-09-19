/// Rango numerico cerrado usado por los criterios educativos configurables.
class Rango {
  const Rango(this.min, this.max);

  factory Rango.fromJson(Map<String, dynamic> json) {
    return Rango(
      (json['min'] as num).toDouble(),
      (json['max'] as num).toDouble(),
    );
  }

  final double min;
  final double max;

  bool contiene(double valor) => valor >= min && valor <= max;

  double get centro => (min + max) / 2;

  Map<String, dynamic> toJson() => <String, dynamic>{'min': min, 'max': max};

  @override
  String toString() => '${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)}';
}

/// Configuracion educativa de Fragmenta Lab.
///
/// IMPORTANTE: estos coeficientes son **referencias academicas configurables**,
/// no constantes universales de diseno. Se cargan desde
/// `assets/config/education_config.json` y pueden ajustarse por el docente para
/// discutir en clase como cambia el analisis geometrico.
class EducationConfig {
  const EducationConfig({
    required this.version,
    required this.factorBurdenDiametro,
    required this.factorEspaciamientoBurden,
    required this.rangoBurdenDiametro,
    required this.rangoSobreBurden,
    required this.rangoOptimoSobreBurden,
    required this.rangoTacoBurden,
    required this.rangoSubperforacionDiametro,
    required this.rangoEsbeltez,
    required this.rangoDiametroMm,
    required this.rangoAlturaBancoM,
    required this.rangoInclinacionGrados,
    required this.toleranciaLongitudPerforacion,
  });

  /// Valores por defecto usados cuando el archivo de configuracion no existe
  /// o no puede leerse. Garantizan que la aplicacion funcione sin conexion y
  /// sin dependencias externas.
  factory EducationConfig.porDefecto() {
    return const EducationConfig(
      version: 1,
      factorBurdenDiametro: 30.0,
      factorEspaciamientoBurden: 1.15,
      rangoBurdenDiametro: Rango(20.0, 45.0),
      rangoSobreBurden: Rango(0.8, 1.8),
      rangoOptimoSobreBurden: Rango(1.0, 1.4),
      rangoTacoBurden: Rango(0.6, 1.4),
      rangoSubperforacionDiametro: Rango(6.0, 14.0),
      rangoEsbeltez: Rango(1.5, 8.0),
      rangoDiametroMm: Rango(25.0, 400.0),
      rangoAlturaBancoM: Rango(1.0, 30.0),
      rangoInclinacionGrados: Rango(0.0, 30.0),
      toleranciaLongitudPerforacion: 0.2,
    );
  }

  factory EducationConfig.fromJson(Map<String, dynamic> json) {
    final EducationConfig base = EducationConfig.porDefecto();

    Rango leerRango(String clave, Rango porDefecto) {
      final Object? valor = json[clave];
      if (valor is Map<String, dynamic>) {
        return Rango.fromJson(valor);
      }
      return porDefecto;
    }

    double leerDouble(String clave, double porDefecto) {
      final Object? valor = json[clave];
      return valor is num ? valor.toDouble() : porDefecto;
    }

    return EducationConfig(
      version: json['version'] is num ? (json['version'] as num).toInt() : 1,
      factorBurdenDiametro: leerDouble(
        'factorBurdenDiametro',
        base.factorBurdenDiametro,
      ),
      factorEspaciamientoBurden: leerDouble(
        'factorEspaciamientoBurden',
        base.factorEspaciamientoBurden,
      ),
      rangoBurdenDiametro: leerRango(
        'rangoBurdenDiametro',
        base.rangoBurdenDiametro,
      ),
      rangoSobreBurden: leerRango('rangoSobreBurden', base.rangoSobreBurden),
      rangoOptimoSobreBurden: leerRango(
        'rangoOptimoSobreBurden',
        base.rangoOptimoSobreBurden,
      ),
      rangoTacoBurden: leerRango('rangoTacoBurden', base.rangoTacoBurden),
      rangoSubperforacionDiametro: leerRango(
        'rangoSubperforacionDiametro',
        base.rangoSubperforacionDiametro,
      ),
      rangoEsbeltez: leerRango('rangoEsbeltez', base.rangoEsbeltez),
      rangoDiametroMm: leerRango('rangoDiametroMm', base.rangoDiametroMm),
      rangoAlturaBancoM: leerRango('rangoAlturaBancoM', base.rangoAlturaBancoM),
      rangoInclinacionGrados: leerRango(
        'rangoInclinacionGrados',
        base.rangoInclinacionGrados,
      ),
      toleranciaLongitudPerforacion: leerDouble(
        'toleranciaLongitudPerforacion',
        base.toleranciaLongitudPerforacion,
      ),
    );
  }

  final int version;

  /// Burden expresado como multiplo del diametro del taladro (B = k x D).
  final double factorBurdenDiametro;

  /// Espaciamiento expresado como relacion respecto al burden (S = k x B).
  final double factorEspaciamientoBurden;

  final Rango rangoBurdenDiametro;
  final Rango rangoSobreBurden;
  final Rango rangoOptimoSobreBurden;
  final Rango rangoTacoBurden;
  final Rango rangoSubperforacionDiametro;
  final Rango rangoEsbeltez;
  final Rango rangoDiametroMm;
  final Rango rangoAlturaBancoM;
  final Rango rangoInclinacionGrados;

  /// Tolerancia relativa aceptada entre la longitud de perforacion ingresada y
  /// la longitud geometrica teorica.
  final double toleranciaLongitudPerforacion;

  EducationConfig copyWith({
    double? factorBurdenDiametro,
    double? factorEspaciamientoBurden,
  }) {
    return EducationConfig(
      version: version,
      factorBurdenDiametro: factorBurdenDiametro ?? this.factorBurdenDiametro,
      factorEspaciamientoBurden:
          factorEspaciamientoBurden ?? this.factorEspaciamientoBurden,
      rangoBurdenDiametro: rangoBurdenDiametro,
      rangoSobreBurden: rangoSobreBurden,
      rangoOptimoSobreBurden: rangoOptimoSobreBurden,
      rangoTacoBurden: rangoTacoBurden,
      rangoSubperforacionDiametro: rangoSubperforacionDiametro,
      rangoEsbeltez: rangoEsbeltez,
      rangoDiametroMm: rangoDiametroMm,
      rangoAlturaBancoM: rangoAlturaBancoM,
      rangoInclinacionGrados: rangoInclinacionGrados,
      toleranciaLongitudPerforacion: toleranciaLongitudPerforacion,
    );
  }
}

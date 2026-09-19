import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/education_config.dart';

/// Servicio de configuracion educativa.
///
/// Carga los coeficientes desde `assets/config/education_config.json`. Si el
/// archivo no existe o esta mal formado, la aplicacion continua con los valores
/// por defecto: el MVP debe funcionar siempre sin conexion y sin fallar por un
/// archivo de configuracion.
class ConfigService extends ChangeNotifier {
  ConfigService._();

  static final ConfigService instance = ConfigService._();

  static const String rutaAsset = 'assets/config/education_config.json';

  EducationConfig _config = EducationConfig.porDefecto();
  bool _cargadoDesdeAsset = false;
  String? _ultimoError;

  EducationConfig get config => _config;

  /// Indica si los coeficientes activos provienen del archivo de
  /// configuracion o de los valores por defecto compilados.
  bool get cargadoDesdeAsset => _cargadoDesdeAsset;

  String? get ultimoError => _ultimoError;

  Future<void> init() async {
    try {
      final String contenido = await rootBundle.loadString(rutaAsset);
      final Object? decodificado = jsonDecode(contenido);
      if (decodificado is Map<String, dynamic>) {
        _config = EducationConfig.fromJson(decodificado);
        _cargadoDesdeAsset = true;
        _ultimoError = null;
      } else {
        _ultimoError = 'El archivo de configuracion no contiene un objeto JSON.';
      }
    } catch (error) {
      _cargadoDesdeAsset = false;
      _ultimoError =
          'No se pudo leer $rutaAsset ($error). Se usan los valores por defecto.';
    }
    notifyListeners();
  }

  /// Permite ajustar en ejecucion los dos coeficientes educativos principales
  /// (sesion actual, sin escribir en disco).
  void actualizarCoeficientes({
    double? factorBurdenDiametro,
    double? factorEspaciamientoBurden,
  }) {
    _config = _config.copyWith(
      factorBurdenDiametro: factorBurdenDiametro,
      factorEspaciamientoBurden: factorEspaciamientoBurden,
    );
    notifyListeners();
  }

  void restaurarPorDefecto() {
    _config = EducationConfig.porDefecto();
    notifyListeners();
  }
}

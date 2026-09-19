import 'package:flutter/material.dart';

import 'app.dart';
import 'services/config_service.dart';

/// Punto de entrada de Fragmenta Lab.
///
/// La configuracion educativa se carga antes de construir la interfaz para
/// que el primer calculo ya use los coeficientes definidos en
/// `assets/config/education_config.json`. Si el archivo falta, la aplicacion
/// continua con los valores por defecto.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigService.instance.init();
  runApp(const FragmentaLabApp());
}

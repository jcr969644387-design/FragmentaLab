import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_strings.dart';

/// Envuelve el cuerpo de un modulo.
///
/// Los modulos que viven en la barra inferior se muestran sin `Scaffold`
/// propio (`embebida = true`) para no duplicar la barra superior; los que se
/// abren como ruta desde la pantalla de inicio reciben su propio `Scaffold`.
Widget envolverModulo({
  required BuildContext context,
  required String titulo,
  required Widget cuerpo,
  required bool embebida,
}) {
  if (embebida) {
    return cuerpo;
  }
  return Scaffold(
    appBar: barraSuperior(context, titulo),
    body: SafeArea(child: cuerpo),
  );
}

/// Barra superior comun de la aplicacion.
///
/// Muestra el nombre corto de la aplicacion y, como subtitulo, el modulo
/// activo. Los colores se aplican aqui y no en `ThemeData.appBarTheme` para no
/// depender de un tipo de tema que cambio entre versiones de Flutter.
AppBar barraSuperior(BuildContext context, String subtitulo) {
  final bool esClaro = Theme.of(context).brightness == Brightness.light;
  return AppBar(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 2,
    backgroundColor: esClaro ? AppColors.mineral : AppColors.mineralOscuro,
    foregroundColor: Colors.white,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          AppStrings.nombreApp,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        Text(
          subtitulo,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        ),
      ],
    ),
  );
}

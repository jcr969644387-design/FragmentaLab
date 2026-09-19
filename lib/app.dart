import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'services/config_service.dart';
import 'services/design_store.dart';
import 'theme/app_theme.dart';
import 'utils/app_strings.dart';

/// Raiz de la aplicacion.
///
/// Crea el estado compartido del ejercicio (`DesignStore`), lo publica en el
/// arbol mediante `DesignScope` y escucha al `ConfigService` para que un cambio
/// de coeficientes educativos se refleje en todos los modulos.
class FragmentaLabApp extends StatefulWidget {
  const FragmentaLabApp({super.key});

  @override
  State<FragmentaLabApp> createState() => _FragmentaLabAppState();
}

class _FragmentaLabAppState extends State<FragmentaLabApp> {
  final DesignStore _store = DesignStore();

  @override
  void initState() {
    super.initState();
    ConfigService.instance.addListener(_alCambiarConfig);
  }

  void _alCambiarConfig() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    ConfigService.instance.removeListener(_alCambiarConfig);
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DesignScope(
      store: _store,
      child: MaterialApp(
        title: AppStrings.nombreApp,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.claro(),
        darkTheme: AppTheme.oscuro(),
        // Modo claro como configuracion inicial, segun requisito del proyecto.
        themeMode: ThemeMode.light,
        home: const MainShell(),
      ),
    );
  }
}

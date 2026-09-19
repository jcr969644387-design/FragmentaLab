import 'package:flutter/material.dart';

import '../models/risk_level.dart';

/// Paleta de Fragmenta Lab.
///
/// Los colores buscan un lenguaje visual minero: verdes mineral y grises de
/// roca como base, ocre de mineral para acentos y la triada clasica de
/// senalizacion de seguridad para los indicadores de riesgo.
class AppColors {
  const AppColors._();

  static const Color mineral = Color(0xFF14504F);
  static const Color mineralOscuro = Color(0xFF0B3433);
  static const Color roca = Color(0xFF2F3A3F);
  static const Color rocaClara = Color(0xFF6B7A80);
  static const Color seguridad = Color(0xFFE07B00);
  static const Color arena = Color(0xFFF7F2E7);
  static const Color riesgoBajo = Color(0xFF2E7D32);
  static const Color riesgoMedio = Color(0xFFED6C02);
  static const Color riesgoAlto = Color(0xFFC62828);

  static Color deRiesgo(RiskLevel nivel) {
    switch (nivel) {
      case RiskLevel.bajo:
        return riesgoBajo;
      case RiskLevel.medio:
        return riesgoMedio;
      case RiskLevel.alto:
        return riesgoAlto;
    }
  }
}

/// Construccion de los temas Material 3 de la aplicacion.
class AppTheme {
  const AppTheme._();

  static ThemeData claro() => _construir(Brightness.light);

  static ThemeData oscuro() => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brillo) {
    final ColorScheme esquema = ColorScheme.fromSeed(
      seedColor: AppColors.mineral,
      brightness: brillo,
      secondary: AppColors.seguridad,
    );

    final bool esClaro = brillo == Brightness.light;

    // Material 3 es el comportamiento por defecto del framework, por lo que
    // no se declara `useMaterial3`: ese parametro quedo obsoleto.
    return ThemeData(
      colorScheme: esquema,
      scaffoldBackgroundColor:
          esClaro ? AppColors.arena : const Color(0xFF14181A),
      visualDensity: VisualDensity.standard,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(space: 16, thickness: 0.6),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 2,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: esClaro ? Colors.white : const Color(0xFF1B2124),
      ),
      textTheme: Typography.material2021().black.apply(
            bodyColor: esClaro ? AppColors.roca : Colors.white70,
            displayColor: esClaro ? AppColors.roca : Colors.white,
          ),
    );
  }

  /// Decoracion comun de los campos de entrada.
  ///
  /// Se aplica campo por campo en lugar de declararla en
  /// `ThemeData.inputDecorationTheme`, para no depender de un tipo de tema que
  /// ha cambiado de forma entre versiones de Flutter.
  static InputDecoration entrada(
    BuildContext context, {
    String? etiqueta,
    String? ayuda,
    String? sufijo,
    String? pista,
    Widget? iconoInicial,
  }) {
    final bool esClaro = Theme.of(context).brightness == Brightness.light;
    return InputDecoration(
      labelText: etiqueta,
      helperText: ayuda,
      suffixText: sufijo,
      hintText: pista,
      prefixIcon: iconoInicial,
      isDense: true,
      filled: true,
      fillColor: esClaro ? Colors.white : const Color(0xFF1E2427),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      helperMaxLines: 3,
      errorMaxLines: 3,
    );
  }
}

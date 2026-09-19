import 'package:flutter/material.dart';

import '../services/config_service.dart';
import '../services/design_store.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';
import '../widgets/app_card.dart';
import '../widgets/module_tile.dart';
import '../widgets/safety_banner.dart';
import 'burden_spacing_screen.dart';
import 'delay_sequence_screen.dart';
import 'evaluation_screen.dart';
import 'explosives_screen.dart';
import 'mesh_design_screen.dart';
import 'parameters_screen.dart';
import 'simulation_screen.dart';
import 'tutor_screen.dart';

/// Modulo 1: pantalla de inicio.
///
/// Cumple tres funciones: identificar la aplicacion, dejar la advertencia de
/// uso educativo antes de cualquier calculo y ofrecer acceso directo a los
/// nueve modulos del MVP.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onIrATab});

  /// Permite saltar a las pestanas de la barra inferior (malla, simulacion,
  /// evaluacion y tutor) sin apilar rutas.
  final ValueChanged<int>? onIrATab;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme esquema = tema.colorScheme;
    final DesignStore store = DesignScope.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      children: <Widget>[
        const _Logotipo(),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Descripcion',
                style: tema.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.descripcionApp,
                style: tema.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Objetivo educativo',
                style: tema.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Comprender como el diametro de perforacion, el burden, el '
                'espaciamiento, la altura de banco, la longitud de '
                'perforacion, la subperforacion, el taco y la secuencia de '
                'iniciacion influyen de forma conceptual en la fragmentacion, '
                'el desplazamiento, la eficiencia y el riesgo de un diseno.',
                style: tema.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const SafetyBanner(),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: esquema.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: esquema.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.school_outlined, size: 20, color: esquema.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.indicadorResultados,
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: esquema.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SectionTitle(
          'Modulos del simulador',
          icono: Icons.widgets_outlined,
          subtitulo: 'Todos los modulos trabajan sobre el mismo ejercicio.',
        ),
        ModuleTile(
          numero: 2,
          titulo: 'Diseno de malla',
          descripcion:
              'Ingresa los parametros geometricos y obten S/B, area por '
              'taladro, volumen conceptual e indicadores de riesgo.',
          icono: Icons.grid_on_outlined,
          onTap: () => _abrirTab(context, 1, const MeshDesignScreen()),
        ),
        ModuleTile(
          numero: 3,
          titulo: 'Burden y espaciamiento',
          descripcion: 'Calculadora educativa con coeficientes configurables y '
              'explicacion completa de cada formula.',
          icono: Icons.straighten_outlined,
          onTap: () => _abrir(context, const BurdenSpacingScreen()),
        ),
        ModuleTile(
          numero: 4,
          titulo: 'Parametros tecnicos',
          descripcion:
              'Glosario de los trece parametros del curso, con unidades y '
              'rangos de entrada razonables.',
          icono: Icons.menu_book_outlined,
          onTap: () => _abrir(context, const ParametersScreen()),
        ),
        ModuleTile(
          numero: 5,
          titulo: 'Explosivos (conceptual)',
          descripcion:
              'Categorias abstractas de energia y resistencia al agua, con '
              'efectos solo cualitativos.',
          icono: Icons.bolt_outlined,
          onTap: () => _abrir(context, const ExplosivesScreen()),
        ),
        ModuleTile(
          numero: 6,
          titulo: 'Secuencia de retardos',
          descripcion:
              'Orden conceptual de salida, intervalos relativos y direccion '
              'de desplazamiento esperada.',
          icono: Icons.timeline_outlined,
          onTap: () => _abrir(context, const DelaySequenceScreen()),
        ),
        ModuleTile(
          numero: 7,
          titulo: 'Simulacion conceptual',
          descripcion:
              'Vista en planta de la malla con indicadores de uniformidad, '
              'fragmentacion y eficiencia estimada.',
          icono: Icons.scatter_plot_outlined,
          onTap: () => _abrirTab(context, 2, const SimulationScreen()),
        ),
        ModuleTile(
          numero: 8,
          titulo: 'Evaluacion',
          descripcion: 'Quince preguntas con puntaje, respuestas correctas y '
              'explicacion tecnica de cada error.',
          icono: Icons.fact_check_outlined,
          onTap: () => _abrirTab(context, 3, const EvaluationScreen()),
        ),
        ModuleTile(
          numero: 9,
          titulo: 'Tutor local',
          descripcion:
              'Explicaciones basadas en reglas y diagnostico del ejercicio '
              'activo, sin conexion ni servicios externos.',
          icono: Icons.support_agent_outlined,
          onTap: () => _abrirTab(context, 4, const TutorScreen()),
        ),
        const SizedBox(height: 6),
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.tune_outlined,
                    size: 18,
                    color: esquema.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Configuracion educativa activa',
                    style: tema.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                ConfigService.instance.cargadoDesdeAsset
                    ? 'Coeficientes cargados desde '
                        'assets/config/education_config.json '
                        '(k_B = ${ConfigService.instance.config.factorBurdenDiametro.toStringAsFixed(2)}, '
                        'k_S = ${ConfigService.instance.config.factorEspaciamientoBurden.toStringAsFixed(2)}).'
                    : 'Se estan usando los coeficientes por defecto '
                        'compilados en la aplicacion.',
                style: tema.textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: store.reiniciar,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reiniciar ejercicio de ejemplo'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (BuildContext _) => pantalla),
    );
  }

  void _abrirTab(BuildContext context, int indice, Widget alternativa) {
    if (onIrATab != null) {
      onIrATab!(indice);
      return;
    }
    _abrir(context, alternativa);
  }
}

class _Logotipo extends StatelessWidget {
  const _Logotipo();

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: <Color>[AppColors.mineral, AppColors.mineralOscuro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.seguridad,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'FL',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.nombreApp,
                  style: tema.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.nombreCompleto,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

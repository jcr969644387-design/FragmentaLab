import 'package:flutter/material.dart';

import '../utils/ui_feedback.dart';
import 'evaluation_screen.dart';
import 'home_screen.dart';
import 'mesh_design_screen.dart';
import 'screen_scaffold.dart';
import 'simulation_screen.dart';
import 'tutor_screen.dart';

/// Contenedor principal con navegacion inferior.
///
/// Los cuatro modulos de uso frecuente (malla, simulacion, evaluacion y tutor)
/// viven en la barra inferior; el resto se abre desde la pantalla de inicio.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _indice = 0;

  static const List<String> _titulos = <String>[
    'Inicio',
    'Diseno de malla',
    'Simulacion conceptual',
    'Evaluacion',
    'Tutor local',
  ];

  /// Indice de la pestana de simulacion dentro de la barra inferior.
  static const int _pestanaSimulacion = 2;

  void _irA(int indice) {
    if (indice != _indice) {
      // Entrar a la simulacion se siente distinto de cambiar de pestana: es
      // el momento en que el ejercicio se pone en marcha.
      if (indice == _pestanaSimulacion) {
        UiFeedback.simulacion();
      } else {
        UiFeedback.seleccion();
      }
    }
    setState(() => _indice = indice);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pantallas = <Widget>[
      HomeScreen(onIrATab: _irA),
      const MeshDesignScreen(embebida: true),
      const SimulationScreen(embebida: true),
      const EvaluationScreen(embebida: true),
      const TutorScreen(embebida: true),
    ];

    return Scaffold(
      appBar: barraSuperior(context, _titulos[_indice]),
      body: SafeArea(
        child: IndexedStack(index: _indice, children: pantallas),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: _irA,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_on_outlined),
            selectedIcon: Icon(Icons.grid_on),
            label: 'Malla',
          ),
          NavigationDestination(
            icon: Icon(Icons.scatter_plot_outlined),
            selectedIcon: Icon(Icons.scatter_plot),
            label: 'Simulacion',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Evaluacion',
          ),
          NavigationDestination(
            icon: Icon(Icons.support_agent_outlined),
            selectedIcon: Icon(Icons.support_agent),
            label: 'Tutor',
          ),
        ],
      ),
    );
  }
}

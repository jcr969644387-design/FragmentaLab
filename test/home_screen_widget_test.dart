import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragmenta_lab/app.dart';
import 'package:fragmenta_lab/screens/home_screen.dart';
import 'package:fragmenta_lab/utils/app_strings.dart';
import 'package:fragmenta_lab/utils/ui_feedback.dart';
import 'package:fragmenta_lab/widgets/module_tile.dart';
import 'package:fragmenta_lab/widgets/safety_banner.dart';

void main() {
  // La retroalimentacion tactil y sonora se apaga en las pruebas: depende de
  // canales de plataforma que no existen en el entorno de test.
  setUp(() => UiFeedback.habilitada = false);
  tearDown(() => UiFeedback.habilitada = true);

  /// Desplaza la lista de inicio hasta que el texto indicado sea visible.
  Future<void> desplazarHasta(WidgetTester tester, String texto) async {
    await tester.scrollUntilVisible(
      find.text(texto),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  group('Pantalla principal', () {
    testWidgets('carga correctamente y muestra la identidad de la app',
        (WidgetTester tester) async {
      await tester.pumpWidget(const FragmentaLabApp());
      await tester.pumpAndSettle();

      // La pantalla de inicio esta montada.
      expect(find.byType(HomeScreen), findsOneWidget);

      // Nombre corto: aparece en la barra superior y en el logotipo textual.
      expect(find.text(AppStrings.nombreApp), findsAtLeastNWidgets(1));

      // Logotipo textual.
      expect(find.text('FL'), findsOneWidget);

      // Subtitulo con el nombre completo de la aplicacion.
      expect(find.text(AppStrings.nombreCompleto), findsOneWidget);
    });

    testWidgets('muestra la advertencia de uso educativo',
        (WidgetTester tester) async {
      await tester.pumpWidget(const FragmentaLabApp());
      await tester.pumpAndSettle();

      // La lista de inicio construye sus hijos a medida que se desplaza, asi
      // que primero se trae la advertencia a la vista.
      await desplazarHasta(tester, AppStrings.advertenciaSeguridad);

      expect(find.byType(SafetyBanner), findsWidgets);
      expect(find.text(AppStrings.advertenciaSeguridad), findsOneWidget);

      await desplazarHasta(tester, AppStrings.indicadorResultados);
      expect(
        find.text(AppStrings.indicadorResultados),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('muestra la descripcion de la aplicacion',
        (WidgetTester tester) async {
      await tester.pumpWidget(const FragmentaLabApp());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.descripcionApp), findsOneWidget);
      expect(find.text('Objetivo educativo'), findsOneWidget);
    });

    testWidgets('muestra los botones de los modulos principales',
        (WidgetTester tester) async {
      await tester.pumpWidget(const FragmentaLabApp());
      await tester.pumpAndSettle();

      // El primer acceso a modulo queda fuera de la ventana inicial de la
      // lista: se desplaza antes de comprobar que existen las tarjetas.
      await desplazarHasta(tester, '1. Diseno de malla');
      expect(find.byType(ModuleTile), findsWidgets);

      // Recorre la lista comprobando los ocho accesos a modulos.
      for (final String titulo in <String>[
        '1. Diseno de malla',
        '2. Burden y espaciamiento',
        '3. Parametros tecnicos',
        '4. Explosivos (conceptual)',
        '5. Secuencia de retardos',
        '6. Simulacion conceptual',
        '7. Evaluacion',
        '8. Tutor local',
      ]) {
        await desplazarHasta(tester, titulo);
        expect(find.text(titulo), findsOneWidget);
      }
    });

    testWidgets('la barra inferior permite cambiar de modulo',
        (WidgetTester tester) async {
      await tester.pumpWidget(const FragmentaLabApp());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Inicio'), findsAtLeastNWidgets(1));

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byIcon(Icons.grid_on_outlined),
        ),
      );
      await tester.pumpAndSettle();

      // El subtitulo de la barra superior refleja el modulo activo.
      expect(find.text('Diseno de malla'), findsAtLeastNWidgets(1));
    });
  });
}

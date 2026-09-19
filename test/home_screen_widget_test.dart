import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragmenta_lab/app.dart';
import 'package:fragmenta_lab/screens/home_screen.dart';
import 'package:fragmenta_lab/utils/app_strings.dart';
import 'package:fragmenta_lab/widgets/module_tile.dart';
import 'package:fragmenta_lab/widgets/safety_banner.dart';

void main() {
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

      expect(find.byType(SafetyBanner), findsWidgets);
      expect(find.text(AppStrings.advertenciaSeguridad), findsOneWidget);
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

      expect(find.byType(ModuleTile), findsWidgets);

      // Recorre la lista comprobando los ocho accesos a modulos.
      for (final String titulo in <String>[
        '2. Diseno de malla',
        '3. Burden y espaciamiento',
        '4. Parametros tecnicos',
        '5. Explosivos (conceptual)',
        '6. Secuencia de retardos',
        '7. Simulacion conceptual',
        '8. Evaluacion',
        '9. Tutor local',
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

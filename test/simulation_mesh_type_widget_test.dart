import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragmenta_lab/app.dart';
import 'package:fragmenta_lab/models/mesh_type.dart';
import 'package:fragmenta_lab/utils/ui_feedback.dart';

void main() {
  setUp(() => UiFeedback.habilitada = false);
  tearDown(() => UiFeedback.habilitada = true);

  /// Abre la pestana de simulacion desde la barra inferior.
  Future<void> irASimulacion(WidgetTester tester) async {
    await tester.pumpWidget(const FragmentaLabApp());
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.scatter_plot_outlined),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Simulacion conceptual', () {
    testWidgets('declara el tipo de malla del ejercicio activo',
        (WidgetTester tester) async {
      await irASimulacion(tester);

      expect(find.text('Tipo de malla simulada'), findsOneWidget);

      // El ejercicio de ejemplo es un banco: malla superficial.
      expect(
        find.text(MeshEnvironment.superficial.etiqueta),
        findsOneWidget,
      );
    });

    testWidgets('muestra los rasgos que sustentan la clasificacion',
        (WidgetTester tester) async {
      await irASimulacion(tester);

      for (final String rasgo in <String>[
        'Diametro de perforacion',
        'Altura de banco o avance',
        'Subperforacion',
        'Longitud de perforacion',
      ]) {
        expect(find.text(rasgo), findsOneWidget);
      }
    });

    testWidgets('la geometria de la malla conserva su propia etiqueta',
        (WidgetTester tester) async {
      await irASimulacion(tester);

      // Los controles rapidos quedan fuera de la ventana inicial de la lista.
      await tester.scrollUntilVisible(
        find.text('Geometria de la malla'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // "Tipo de malla" queda reservado al contexto minero; la forma de la
      // celda se llama geometria para no confundir los dos conceptos.
      expect(find.text('Geometria de la malla'), findsWidgets);
    });
  });
}

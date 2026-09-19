import 'package:flutter/widgets.dart';

import '../models/blast_design.dart';
import '../models/delay_sequence.dart';

/// Estado compartido del ejercicio activo.
///
/// Todos los modulos leen y escriben el mismo `BlastDesign`, de modo que un
/// cambio hecho en el modulo de malla se refleja inmediatamente en simulacion,
/// retardos y tutor. Es la pieza que convierte a Fragmenta Lab en un ejercicio
/// unico en vez de ocho calculadoras aisladas.
class DesignStore extends ChangeNotifier {
  BlastDesign _design = BlastDesign.ejemploEducativo();

  BlastDesign get design => _design;

  void actualizar(BlastDesign nuevo) {
    _design = nuevo;
    notifyListeners();
  }

  void cambiarSecuencia(DelayPattern patron) {
    _design = _design.copyWith(secuencia: patron);
    notifyListeners();
  }

  void reiniciar() {
    _design = BlastDesign.ejemploEducativo();
    notifyListeners();
  }
}

/// Alcance de widget que expone el `DesignStore` al arbol.
class DesignScope extends InheritedNotifier<DesignStore> {
  const DesignScope({
    super.key,
    required DesignStore store,
    required super.child,
  }) : super(notifier: store);

  static DesignStore of(BuildContext context) {
    final DesignScope? scope =
        context.dependOnInheritedWidgetOfExactType<DesignScope>();
    assert(scope != null, 'No se encontro un DesignScope en el arbol.');
    return scope!.notifier!;
  }
}

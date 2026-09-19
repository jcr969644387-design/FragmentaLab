import 'package:flutter/services.dart';

/// Retroalimentacion tactil y sonora de la interfaz.
///
/// Se resuelve solo con `HapticFeedback` y `SystemSound`, que forman parte de
/// Flutter: el proyecto no usa paquetes externos, no se incluyen archivos de
/// audio y no se solicita ningun permiso adicional. En un dispositivo sin
/// motor de vibracion, con el volumen en silencio o en las pruebas de widget,
/// el sistema simplemente ignora la llamada.
///
/// La intensidad acompana a la importancia de la accion: seleccionar una
/// opcion vibra menos que confirmar una respuesta, y un error se distingue del
/// acierto por el patron tactil y no solo por el color.
class UiFeedback {
  const UiFeedback._();

  /// Permite silenciar toda la retroalimentacion.
  ///
  /// Las pruebas de widget la desactivan para no depender de los canales de
  /// plataforma, y deja preparado un futuro ajuste de accesibilidad.
  static bool habilitada = true;

  /// Navegacion y acciones secundarias: abrir un modulo, cambiar de pestana,
  /// reiniciar el ejercicio o avanzar de pregunta.
  static void toque() {
    if (!habilitada) {
      return;
    }
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
  }

  /// Eleccion de una opcion: alternativa de la evaluacion, desplegable,
  /// patron de secuencia o interruptor.
  static void seleccion() {
    if (!habilitada) {
      return;
    }
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);
  }

  /// Ajuste continuo, como soltar un deslizador.
  ///
  /// Solo vibra: un sonido por cada movimiento del control resultaria
  /// invasivo.
  static void ajuste() {
    if (!habilitada) {
      return;
    }
    HapticFeedback.selectionClick();
  }

  /// Confirmacion de una accion de calculo o de una respuesta correcta.
  static void confirmacion() {
    if (!habilitada) {
      return;
    }
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }

  /// Respuesta incorrecta o validacion que no deja continuar.
  static void error() {
    if (!habilitada) {
      return;
    }
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }

  /// Inicio o regeneracion de la simulacion conceptual.
  static void simulacion() {
    if (!habilitada) {
      return;
    }
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }
}

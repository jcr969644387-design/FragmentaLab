/// Textos compartidos de la aplicacion.
///
/// Centralizarlos permite que las pruebas de widget verifiquen exactamente el
/// mismo texto que ve el estudiante.
class AppStrings {
  const AppStrings._();

  static const String nombreApp = 'Fragmenta Lab';

  static const String nombreCompleto =
      'Fragmenta Lab: Simulador Educativo de Perforacion y Voladura';

  static const String descripcionApp =
      'Aplicacion de calculo y simulacion para el diseno geometrico de '
      'perforacion y voladura, considerando parametros como diametro, burden, '
      'espaciamiento, altura de banco, longitud de perforacion, '
      'subperforacion, taco y secuencia de iniciacion.';

  static const String advertenciaSeguridad =
      'La aplicacion es exclusivamente educativa y conceptual. No reemplaza un '
      'diseno de voladura elaborado por un ingeniero autorizado ni una '
      'evaluacion de campo.';

  static const String indicadorResultados =
      'Todos los resultados son educativos y conceptuales: no constituyen un '
      'diseno operativo ni una recomendacion definitiva.';

  static const String limitacionModelo =
      'Los valores reales dependen de la roca, la energia disponible, el '
      'equipo de perforacion, la altura y confinamiento del banco, la '
      'presencia de agua, las estructuras geologicas y la experiencia de '
      'campo. Ninguna formula unica es valida para todos los casos.';

  static const String sinExplosivosOperativos =
      'Este modulo trabaja solo con categorias conceptuales. No incluye '
      'marcas, composiciones, cantidades, procedimientos de carga, conexion '
      'ni iniciacion.';
}

import '../models/blast_design.dart';
import '../models/delay_sequence.dart';
import '../models/education_config.dart';
import '../models/geometry_result.dart';
import '../models/rock_context.dart';
import '../models/tutor_topic.dart';

/// Contrato del tutor educativo.
///
/// Existe para que una version futura pueda incorporar un motor de IA sin
/// tocar la interfaz de usuario. El MVP usa exclusivamente
/// [LocalRuleTutorEngine]: no realiza llamadas de red, no requiere claves y
/// funciona sin conexion.
abstract class TutorEngine {
  String get nombre;

  bool get requiereConexion;

  Future<TutorAnswer> responder(String consulta);

  List<TutorTopic> temas();
}

/// Tutor local basado en reglas.
class LocalRuleTutorEngine implements TutorEngine {
  const LocalRuleTutorEngine();

  @override
  String get nombre => 'Tutor local basado en reglas';

  @override
  bool get requiereConexion => false;

  static const List<TutorTopic> _temas = <TutorTopic>[
    TutorTopic(
      id: 'burden_grande',
      pregunta: 'Que ocurre cuando el burden es demasiado grande?',
      respuesta:
          'Con un burden excesivo cada taladro debe influir sobre mas roca de '
          'la que le corresponde. Conceptualmente el confinamiento aumenta y '
          'aparecen tres consecuencias tipicas: fragmentacion gruesa con '
          'bloques, material sin romper en el pie del banco y una cara '
          'resultante irregular. En el analisis de aula esto se detecta '
          'cuando el burden expresado en diametros supera el rango educativo '
          'configurado.',
      palabrasClave: <String>[
        'burden',
        'grande',
        'excesivo',
        'alto',
        'bloques',
        'pie',
      ],
    ),
    TutorTopic(
      id: 'burden_pequeno',
      pregunta: 'Que ocurre cuando el burden es demasiado pequeno?',
      respuesta:
          'Con un burden reducido la distancia a la cara libre es corta y el '
          'confinamiento disminuye. Conceptualmente la fragmentacion tiende a '
          'ser fina, pero se asocia a mayor proyeccion de material, mayor '
          'onda aerea y sobreexcavacion hacia la cara. Tambien implica mas '
          'taladros para el mismo volumen, es decir mas perforacion. Un '
          'diseno "mas cerrado" no es automaticamente un diseno mejor.',
      palabrasClave: <String>[
        'burden',
        'pequeno',
        'corto',
        'bajo',
        'proyeccion',
      ],
    ),
    TutorTopic(
      id: 'espaciamiento',
      pregunta: 'Como influye el espaciamiento?',
      respuesta:
          'El espaciamiento gobierna la interaccion entre taladros de la misma '
          'fila. Si es muy corto, los taladros se influyen entre si de forma '
          'redundante y se desperdicia perforacion. Si es muy amplio, queda '
          'material grueso en la zona intermedia entre taladros. El '
          'espaciamiento nunca se analiza solo: siempre se lee junto al '
          'burden mediante la relacion S/B.',
      palabrasClave: <String>['espaciamiento', 'spacing', 'fila', 'entre'],
    ),
    TutorTopic(
      id: 'relacion_sb',
      pregunta: 'Que representa la relacion S/B?',
      respuesta:
          'La relacion S/B es el cociente entre espaciamiento y burden. Es '
          'adimensional y describe la forma de la celda que rodea cada '
          'taladro, no su tamano. Valores cercanos a 1 corresponden a celdas '
          'cuadradas; valores mayores, a celdas mas anchas que profundas. '
          'Como es una relacion de forma, dos mallas con la misma S/B pueden '
          'comportarse muy distinto si cambia el diametro o el tamano '
          'absoluto.',
      palabrasClave: <String>['relacion', 's/b', 'sb', 'cociente', 'forma'],
    ),
    TutorTopic(
      id: 'diametro',
      pregunta: 'Como afecta el diametro de perforacion?',
      respuesta:
          'El diametro es la variable de referencia de todo el diseno '
          'geometrico: burden, espaciamiento, taco y subperforacion suelen '
          'expresarse como multiplos suyos. Al aumentar el diametro '
          'manteniendo los mismos coeficientes, la malla se abre y disminuye '
          'el numero de taladros para el mismo volumen. La contrapartida '
          'conceptual es que la energia se concentra en menos puntos, lo que '
          'exige mas cuidado con la uniformidad de la distribucion.',
      palabrasClave: <String>['diametro', 'taladro', 'broca', 'calibre'],
    ),
    TutorTopic(
      id: 'taco',
      pregunta: 'Por que el taco influye en el confinamiento?',
      respuesta:
          'El taco es la porcion superior del taladro ocupada por material '
          'inerte. Su papel conceptual es evitar que la energia escape por la '
          'boca del taladro, que es el camino de menor resistencia. Un taco '
          'corto reduce el confinamiento y se asocia a proyeccion y onda '
          'aerea; un taco largo deja la cresta del banco poco influida y '
          'genera bloques en la parte superior. Por eso se controla como '
          'relacion respecto al burden.',
      palabrasClave: <String>['taco', 'stemming', 'confinamiento', 'boca'],
    ),
    TutorTopic(
      id: 'subperforacion',
      pregunta: 'Para que sirve la subperforacion?',
      respuesta:
          'La subperforacion es la longitud perforada bajo el nivel de piso '
          'proyectado. Conceptualmente ayuda a que el corte alcance la cota '
          'prevista y a evitar resaltes. Si es insuficiente queda piso '
          'irregular; si es excesiva se asocia a dano bajo el nivel de piso, '
          'sobreexcavacion y perforacion desperdiciada. Se controla como '
          'multiplo del diametro.',
      palabrasClave: <String>['subperforacion', 'piso', 'resalte', 'cota'],
    ),
    TutorTopic(
      id: 'desviacion',
      pregunta: 'Como afecta la desviacion del taladro?',
      respuesta:
          'La desviacion es la diferencia entre la trayectoria real del '
          'taladro y la proyectada. Su efecto crece con la longitud: en '
          'taladros largos un pequeno error angular desplaza varios '
          'decimetros el fondo, de modo que el burden real en el fondo puede '
          'ser mucho mayor o menor que el de diseno. Conceptualmente explica '
          'por que un mismo diseno geometrico entrega resultados distintos: '
          'no se ejecuto la geometria que se calculo.',
      palabrasClave: <String>[
        'desviacion',
        'desvio',
        'paralelismo',
        'error',
        'fondo',
      ],
    ),
    TutorTopic(
      id: 'agua',
      pregunta: 'Por que el agua modifica la seleccion conceptual de energia?',
      respuesta:
          'La presencia de agua en el taladro cambia el orden de los criterios '
          'de seleccion. En el modelo educativo de Fragmenta Lab, con agua '
          'declarada se evalua primero la resistencia al agua de la categoria '
          'y solo despues su energia relativa: una categoria de baja '
          'resistencia al agua pierde energia efectiva y vuelve irregular el '
          'resultado, por muy alta que sea su categoria energetica nominal.',
      palabrasClave: <String>['agua', 'humedo', 'saturado', 'resistencia'],
    ),
    TutorTopic(
      id: 'secuencia',
      pregunta: 'Como influye la secuencia en el desplazamiento?',
      respuesta:
          'La secuencia define el orden relativo de salida y, con ello, hacia '
          'donde existe cara libre en cada momento. Una salida conceptualmente '
          'simultanea concentra el empuje al frente y produce la mayor '
          'vibracion esperada. Una secuencia por filas crea caras libres '
          'progresivas. Una secuencia escalonada abre en diagonal y orienta '
          'el desplazamiento hacia el vertice de apertura. Fragmenta Lab '
          'representa solo el orden relativo: no define tiempos ni elementos '
          'de iniciacion.',
      palabrasClave: <String>[
        'secuencia',
        'retardo',
        'retardos',
        'orden',
        'salida',
      ],
    ),
    TutorTopic(
      id: 'geometria',
      pregunta: 'Que diferencia hay entre malla cuadrada y tresbolillo?',
      respuesta:
          'En una malla cuadrada o rectangular los taladros quedan alineados '
          'en filas y columnas. En tresbolillo cada fila se desplaza medio '
          'espaciamiento, de modo que un taladro queda enfrentado al espacio '
          'entre dos taladros de la fila anterior. El area por taladro no '
          'cambia, pero la distribucion conceptual es mas homogenea: es una '
          'mejora de reparto, no de cantidad.',
      palabrasClave: <String>[
        'tresbolillo',
        'cuadrada',
        'rectangular',
        'malla',
        'geometria',
      ],
    ),
    TutorTopic(
      id: 'limites',
      pregunta: 'Que limites tiene este simulador?',
      respuesta:
          'Fragmenta Lab resuelve geometria y aplica reglas cualitativas. No '
          'modela la fisica de la fragmentacion, no calcula cantidades, no '
          'considera estructuras geologicas reales, no evalua el entorno ni '
          'la normativa aplicable y no sustituye el criterio del ingeniero '
          'responsable. Sirve para entender relaciones entre parametros: '
          'cualquier decision de campo pertenece a un diseno profesional '
          'supervisado.',
      palabrasClave: <String>[
        'limite',
        'limites',
        'sirve',
        'real',
        'campo',
        'seguridad',
      ],
    ),
  ];

  @override
  List<TutorTopic> temas() => List<TutorTopic>.unmodifiable(_temas);

  @override
  Future<TutorAnswer> responder(String consulta) async {
    final String texto = consulta.toLowerCase().trim();
    if (texto.isEmpty) {
      return const TutorAnswer(
        titulo: 'Escribe una consulta',
        contenido:
            'Pregunta por burden, espaciamiento, relacion S/B, diametro, taco, '
            'subperforacion, desviacion, agua, secuencia o geometria de malla.',
        origen: 'reglas locales',
      );
    }

    TutorTopic? mejor;
    int mejorPuntaje = 0;
    for (final TutorTopic tema in _temas) {
      int puntaje = 0;
      for (final String clave in tema.palabrasClave) {
        if (texto.contains(clave)) {
          puntaje += clave.length;
        }
      }
      if (puntaje > mejorPuntaje) {
        mejorPuntaje = puntaje;
        mejor = tema;
      }
    }

    if (mejor == null) {
      return const TutorAnswer(
        titulo: 'Sin coincidencia en la base de reglas',
        contenido:
            'El tutor del MVP funciona con una base de reglas cerrada y sin '
            'conexion, por lo que solo responde los temas incluidos en el '
            'listado. Reformula la consulta usando los terminos del glosario '
            'de parametros tecnicos.',
        origen: 'reglas locales',
      );
    }

    return TutorAnswer(
      titulo: mejor.pregunta,
      contenido: mejor.respuesta,
      origen: 'reglas locales',
      temaRelacionado: mejor,
    );
  }

  /// Diagnostico contextual del ejercicio activo.
  ///
  /// Es la parte mas valiosa del tutor: no explica teoria generica, explica el
  /// diseno que el estudiante acaba de ingresar.
  List<String> diagnosticar(
    BlastDesign d,
    GeometryResult g,
    EducationConfig config,
  ) {
    final List<String> notas = <String>[];

    if (g.burdenEnDiametros > config.rangoBurdenDiametro.max) {
      notas.add(
        'Tu burden equivale a ${g.burdenEnDiametros.toStringAsFixed(1)} '
        'diametros, por encima del rango educativo '
        '(${config.rangoBurdenDiametro}). Revisa el tema "burden demasiado '
        'grande".',
      );
    } else if (g.burdenEnDiametros < config.rangoBurdenDiametro.min) {
      notas.add(
        'Tu burden equivale a ${g.burdenEnDiametros.toStringAsFixed(1)} '
        'diametros, por debajo del rango educativo '
        '(${config.rangoBurdenDiametro}). Revisa el tema "burden demasiado '
        'pequeno".',
      );
    }

    if (!config.rangoOptimoSobreBurden.contiene(g.relacionSobreBurden)) {
      notas.add(
        'Tu relacion S/B es ${g.relacionSobreBurden.toStringAsFixed(2)}, fuera '
        'del rango de referencia (${config.rangoOptimoSobreBurden}). La forma '
        'de la celda esta condicionando el resultado conceptual.',
      );
    }

    if (!config.rangoTacoBurden.contiene(g.relacionTacoBurden)) {
      notas.add(
        'La relacion taco/burden es ${g.relacionTacoBurden.toStringAsFixed(2)} '
        '(rango educativo ${config.rangoTacoBurden}): el confinamiento '
        'superior del taladro es el punto debil de este ejercicio.',
      );
    }

    if (g.esbeltez > config.rangoEsbeltez.max) {
      notas.add(
        'Con una esbeltez de ${g.esbeltez.toStringAsFixed(1)} el taladro es '
        'muy largo frente al burden: la desviacion de perforacion pasa a ser '
        'el factor dominante.',
      );
    }

    if (d.agua != WaterPresence.seco) {
      notas.add(
        'Declaraste ${d.agua.etiqueta.toLowerCase()}: en el analisis '
        'conceptual la resistencia al agua se evalua antes que la energia.',
      );
    }

    if (d.secuencia == DelayPattern.uniforme && d.filas > 1) {
      notas.add(
        'Tienes ${d.filas} filas con secuencia uniforme: sin ordenes distintos '
        'no se generan caras libres progresivas entre filas.',
      );
    }

    if (d.geometria == MeshGeometry.cuadrada &&
        (g.relacionSobreBurden - 1.0).abs() > 0.05) {
      notas.add(
        'Declaraste malla cuadrada pero los valores ingresados dan una celda '
        'rectangular (S/B = ${g.relacionSobreBurden.toStringAsFixed(2)}).',
      );
    }

    if (notas.isEmpty) {
      notas.add(
        'El ejercicio actual mantiene todas las relaciones geometricas dentro '
        'de los rangos educativos configurados. Prueba ahora a mover un solo '
        'parametro y observa que criterio se rompe primero.',
      );
    }

    return notas;
  }
}

/// Motor remoto reservado para una version futura.
///
/// Se incluye unicamente como punto de extension declarado. El MVP **no**
/// realiza llamadas externas, no incluye endpoints y no almacena claves: si
/// alguna vez se implementa, la clave debera inyectarse en tiempo de
/// compilacion o ejecucion y nunca versionarse en el repositorio.
class RemoteTutorEngine implements TutorEngine {
  const RemoteTutorEngine();

  @override
  String get nombre => 'Tutor con IA (no disponible en el MVP)';

  @override
  bool get requiereConexion => true;

  @override
  List<TutorTopic> temas() => const <TutorTopic>[];

  @override
  Future<TutorAnswer> responder(String consulta) async {
    throw UnsupportedError(
      'El MVP de Fragmenta Lab no realiza llamadas externas. Esta clase existe '
      'solo como punto de extension para una version futura.',
    );
  }
}

import '../models/quiz.dart';

/// Banco de preguntas del modulo de evaluacion.
///
/// Las preguntas cubren unicamente conceptos geometricos, de interpretacion y
/// de seguridad academica. Ninguna pregunta solicita cantidades, productos ni
/// procedimientos operativos.
class QuizService {
  const QuizService();

  static const List<QuizQuestion> _banco = <QuizQuestion>[
    QuizQuestion(
      id: 'q01',
      tema: QuizTopic.burden,
      enunciado: 'En una malla de perforacion, el burden corresponde a:',
      opciones: <String>[
        'La distancia entre taladros de una misma fila.',
        'La distancia entre el taladro y la cara libre, medida perpendicular '
            'a ella.',
        'La longitud del taladro por debajo del nivel de piso.',
        'La porcion superior del taladro sin influencia de energia.',
      ],
      indiceCorrecto: 1,
      explicacion:
          'El burden es la distancia perpendicular entre el taladro y la cara '
          'libre. La distancia entre taladros de la misma fila es el '
          'espaciamiento; la porcion bajo el piso es la subperforacion y la '
          'porcion superior sin influencia es el taco.',
    ),
    QuizQuestion(
      id: 'q02',
      tema: QuizTopic.espaciamiento,
      enunciado:
          'Si se mantiene el burden constante y se aumenta el espaciamiento, '
          'el area teorica influenciada por taladro:',
      opciones: <String>[
        'Disminuye.',
        'Se mantiene igual.',
        'Aumenta.',
        'No puede determinarse sin conocer la altura del banco.',
      ],
      indiceCorrecto: 2,
      explicacion:
          'El area por taladro es el producto burden x espaciamiento. Si el '
          'burden no cambia y el espaciamiento crece, el area crece de forma '
          'proporcional, por lo que cada taladro debe influir sobre mas roca.',
    ),
    QuizQuestion(
      id: 'q03',
      tema: QuizTopic.relacionSB,
      enunciado: 'Una malla con burden 3.0 m y espaciamiento 3.0 m tiene:',
      opciones: <String>[
        'Relacion S/B = 1.00 y geometria cuadrada.',
        'Relacion S/B = 1.00 y geometria rectangular.',
        'Relacion S/B = 0.50 y geometria cuadrada.',
        'Relacion S/B indefinida.',
      ],
      indiceCorrecto: 0,
      explicacion:
          'La relacion S/B es el cociente entre espaciamiento y burden. Con '
          'ambos valores iguales el cociente es 1.00 y la celda es cuadrada. '
          'Una malla rectangular exige S/B distinto de 1.00.',
    ),
    QuizQuestion(
      id: 'q04',
      tema: QuizTopic.relacionSB,
      enunciado: 'La relacion S/B describe principalmente:',
      opciones: <String>[
        'El tamano absoluto de la malla.',
        'La forma de la celda que rodea cada taladro.',
        'La energia total disponible en la voladura.',
        'La cantidad de filas necesarias.',
      ],
      indiceCorrecto: 1,
      explicacion:
          'S/B es adimensional: informa sobre la forma de la celda, no sobre '
          'su tamano. Dos mallas con la misma relacion pueden tener tamanos y '
          'diametros muy distintos y comportarse de manera diferente.',
    ),
    QuizQuestion(
      id: 'q05',
      tema: QuizTopic.diametro,
      enunciado:
          'En los modelos geometricos educativos, el burden suele expresarse '
          'como:',
      opciones: <String>[
        'Un valor fijo independiente del equipo.',
        'Un multiplo del diametro del taladro.',
        'Una fraccion del numero de filas.',
        'Un porcentaje del taco.',
      ],
      indiceCorrecto: 1,
      explicacion:
          'Expresar el burden en diametros permite comparar disenos hechos con '
          'equipos distintos. El coeficiente no es universal: depende de la '
          'roca, del banco y de la experiencia de campo.',
    ),
    QuizQuestion(
      id: 'q06',
      tema: QuizTopic.diametro,
      enunciado:
          'Si el diametro del taladro aumenta y se mantiene el mismo numero de '
          'diametros de burden, entonces:',
      opciones: <String>[
        'El burden en metros disminuye.',
        'El burden en metros no cambia.',
        'El burden en metros aumenta y la malla se abre.',
        'La relacion S/B cambia automaticamente.',
      ],
      indiceCorrecto: 2,
      explicacion:
          'Como B = k x D, al crecer D con k constante el burden en metros '
          'crece y la malla se abre. La relacion S/B no cambia si tambien se '
          'mantiene el coeficiente S/B.',
    ),
    QuizQuestion(
      id: 'q07',
      tema: QuizTopic.taco,
      enunciado: 'La funcion conceptual del taco en el taladro es:',
      opciones: <String>[
        'Aumentar la longitud perforada.',
        'Mantener el confinamiento en la parte superior del taladro.',
        'Sustituir la subperforacion.',
        'Reducir el numero de taladros necesarios.',
      ],
      indiceCorrecto: 1,
      explicacion:
          'El taco es el material inerte de la parte superior del taladro. Su '
          'funcion conceptual es mantener el confinamiento; si es demasiado '
          'corto aumenta el riesgo teorico de proyeccion y onda aerea.',
    ),
    QuizQuestion(
      id: 'q08',
      tema: QuizTopic.taco,
      enunciado: 'Un taco excesivamente largo se asocia conceptualmente a:',
      opciones: <String>[
        'Fragmentacion muy fina en toda la altura del banco.',
        'Bloques de gran tamano en la parte superior del banco.',
        'Desaparicion del pie de banco.',
        'Reduccion del burden necesario.',
      ],
      indiceCorrecto: 1,
      explicacion:
          'Si el taco ocupa una porcion demasiado grande del taladro, la '
          'cresta del banco queda poco influida y aparecen bloques gruesos en '
          'la parte superior.',
    ),
    QuizQuestion(
      id: 'q09',
      tema: QuizTopic.subperforacion,
      enunciado: 'La subperforacion es la porcion del taladro que:',
      opciones: <String>[
        'Se ubica por encima del nivel de piso proyectado.',
        'Se perfora por debajo del nivel de piso proyectado.',
        'Corresponde al taco.',
        'Se descuenta del burden.',
      ],
      indiceCorrecto: 1,
      explicacion:
          'La subperforacion se perfora bajo el nivel de piso para favorecer '
          'el corte a la cota prevista. Escasa se asocia a resaltes en el '
          'piso; excesiva, a dano bajo el nivel y sobreexcavacion.',
    ),
    QuizQuestion(
      id: 'q10',
      tema: QuizTopic.subperforacion,
      enunciado:
          'En un banco vertical de 10 m con 1 m de subperforacion, la longitud '
          'geometrica teorica del taladro es:',
      opciones: <String>['9 m.', '10 m.', '11 m.', '12 m.'],
      indiceCorrecto: 2,
      explicacion:
          'Con inclinacion cero, la longitud teorica es la altura de banco mas '
          'la subperforacion: 10 m + 1 m = 11 m. Con taladros inclinados la '
          'altura se divide por el coseno del angulo.',
    ),
    QuizQuestion(
      id: 'q11',
      tema: QuizTopic.desviacion,
      enunciado:
          'La desviacion de perforacion es especialmente critica cuando:',
      opciones: <String>[
        'Los taladros son cortos y el burden grande.',
        'Los taladros son largos respecto al burden.',
        'La malla es cuadrada.',
        'El taco es corto.',
      ],
      indiceCorrecto: 1,
      explicacion:
          'Cuanto mas largo es el taladro respecto al burden, mas se desplaza '
          'el fondo ante un pequeno error angular. El burden real en el fondo '
          'puede diferir mucho del burden de diseno.',
    ),
    QuizQuestion(
      id: 'q12',
      tema: QuizTopic.agua,
      enunciado:
          'Ante presencia de agua en los taladros, el criterio conceptual de '
          'seleccion de categoria debe priorizar:',
      opciones: <String>[
        'La mayor energia disponible.',
        'La resistencia al agua de la categoria seleccionada.',
        'El menor diametro posible.',
        'La secuencia uniforme.',
      ],
      indiceCorrecto: 1,
      explicacion:
          'Si la categoria seleccionada tiene baja resistencia al agua, la '
          'energia disponible se degrada y el resultado pierde uniformidad. '
          'La compatibilidad con el agua se evalua antes que la energia.',
    ),
    QuizQuestion(
      id: 'q13',
      tema: QuizTopic.secuencia,
      enunciado:
          'Respecto a una salida conceptualmente simultanea, una secuencia por '
          'filas:',
      opciones: <String>[
        'Aumenta la vibracion conceptual esperada.',
        'Reduce la vibracion conceptual y genera caras libres progresivas.',
        'No modifica el comportamiento conceptual.',
        'Elimina la necesidad de taco.',
      ],
      indiceCorrecto: 1,
      explicacion:
          'Al separar la salida en distintos ordenes, cada fila encuentra una '
          'cara libre creada por la anterior: conceptualmente mejora la '
          'fragmentacion y reduce la vibracion esperada.',
    ),
    QuizQuestion(
      id: 'q14',
      tema: QuizTopic.fragmentacion,
      enunciado:
          'Un burden grande respecto al diametro se asocia conceptualmente a:',
      opciones: <String>[
        'Fragmentacion fina y proyeccion excesiva.',
        'Fragmentacion gruesa y aparicion de pie de banco.',
        'Desaparicion de la subperforacion.',
        'Relacion S/B siempre menor que 1.',
      ],
      indiceCorrecto: 1,
      explicacion:
          'Un burden excesivo aumenta el confinamiento: la roca dispone de '
          'mas masa por taladro, la fragmentacion tiende a ser gruesa y suele '
          'quedar material sin romper en el pie del banco.',
    ),
    QuizQuestion(
      id: 'q15',
      tema: QuizTopic.seguridad,
      enunciado:
          'Los resultados que entrega Fragmenta Lab deben interpretarse como:',
      opciones: <String>[
        'Un diseno operativo listo para ejecutarse en campo.',
        'Un ejercicio geometrico y conceptual de aula.',
        'Una recomendacion tecnica definitiva.',
        'Un reemplazo del criterio del ingeniero responsable.',
      ],
      indiceCorrecto: 1,
      explicacion:
          'La aplicacion es exclusivamente educativa. Ningun resultado '
          'sustituye un diseno elaborado por un ingeniero autorizado, la '
          'evaluacion de campo ni la normativa aplicable.',
    ),
  ];

  List<QuizQuestion> preguntas() => List<QuizQuestion>.unmodifiable(_banco);

  int get total => _banco.length;

  QuizResult calificar(List<QuizAnswer> respuestas) {
    final int correctas =
        respuestas.where((QuizAnswer r) => r.esCorrecta).length;
    return QuizResult(
      respuestas: respuestas,
      correctas: correctas,
      total: respuestas.isEmpty ? _banco.length : respuestas.length,
    );
  }

  /// Agrupa los errores por tema para orientar el repaso.
  Map<QuizTopic, int> erroresPorTema(List<QuizAnswer> respuestas) {
    final Map<QuizTopic, int> mapa = <QuizTopic, int>{};
    for (final QuizAnswer r in respuestas) {
      if (!r.esCorrecta) {
        mapa[r.pregunta.tema] = (mapa[r.pregunta.tema] ?? 0) + 1;
      }
    }
    return mapa;
  }
}

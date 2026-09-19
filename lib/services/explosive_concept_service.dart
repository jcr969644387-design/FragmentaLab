import '../models/explosive_concept.dart';
import '../models/rock_context.dart';

/// Servicio conceptual de categorias energeticas.
///
/// LIMITE DELIBERADO DEL PRODUCTO: este servicio no contiene ni puede contener
/// marcas comerciales, composiciones, recetas, densidades de producto,
/// cantidades, procedimientos de carga, conexion ni iniciacion. Solo describe
/// efectos **relativos y cualitativos** de categorias abstractas, que es lo
/// unico necesario para el objetivo educativo del curso.
class ExplosiveConceptService {
  const ExplosiveConceptService();

  List<EnergyCategory> get categorias => EnergyCategory.values;

  ExplosiveConceptProfile perfil({
    required EnergyCategory energia,
    required WaterResistance resistenciaAgua,
    required RockHardness dureza,
    required WaterPresence agua,
  }) {
    return ExplosiveConceptProfile(
      energia: energia,
      resistenciaAgua: resistenciaAgua,
      energiaRelativa: _energiaRelativa(energia),
      fragmentacionEsperada: _fragmentacion(energia, dureza),
      desplazamientoEsperado: _desplazamiento(energia),
      sensibilidadAlAgua: _sensibilidad(resistenciaAgua, agua),
      adecuacionConceptual: _adecuacion(energia, dureza, resistenciaAgua, agua),
      observacionEducativa: _observacion(energia, dureza, resistenciaAgua, agua),
    );
  }

  String _energiaRelativa(EnergyCategory energia) {
    switch (energia) {
      case EnergyCategory.baja:
        return 'Indice relativo 0.7 (referencia: energia media = 1.0). Valor '
            'adimensional usado solo para comparar categorias entre si.';
      case EnergyCategory.media:
        return 'Indice relativo 1.0. Es la categoria de referencia del modelo '
            'educativo.';
      case EnergyCategory.alta:
        return 'Indice relativo 1.3 (referencia: energia media = 1.0). Valor '
            'adimensional usado solo para comparar categorias entre si.';
    }
  }

  String _fragmentacion(EnergyCategory energia, RockHardness dureza) {
    final double balance = energia.indiceRelativo / dureza.indice;
    if (balance < 0.8) {
      return 'Conceptualmente insuficiente para la dureza declarada: '
          'fragmentacion gruesa y presencia de bloques.';
    }
    if (balance < 0.95) {
      return 'Conceptualmente ajustada: fragmentacion algo mas gruesa de lo '
          'deseado para la dureza declarada.';
    }
    if (balance <= 1.35) {
      return 'Conceptualmente equilibrada frente a la dureza declarada: '
          'fragmentacion media y regular.';
    }
    return 'Conceptualmente excedida para la dureza declarada: fragmentacion '
        'fina con mayor tendencia a proyeccion.';
  }

  String _desplazamiento(EnergyCategory energia) {
    switch (energia) {
      case EnergyCategory.baja:
        return 'Desplazamiento conceptual bajo: el material tiende a quedar '
            'cerca de su posicion original.';
      case EnergyCategory.media:
        return 'Desplazamiento conceptual moderado, con perfil de pila '
            'regular.';
      case EnergyCategory.alta:
        return 'Desplazamiento conceptual alto: pila mas extendida y mayor '
            'atencion al area de influencia.';
    }
  }

  String _sensibilidad(WaterResistance resistencia, WaterPresence agua) {
    if (agua == WaterPresence.seco) {
      return 'Sin agua declarada, la resistencia al agua no condiciona la '
          'seleccion conceptual.';
    }
    if (resistencia == WaterResistance.baja) {
      return 'Combinacion critica en el analisis conceptual: presencia de agua '
          'con categoria de baja resistencia al agua. La energia disponible se '
          'degrada y el resultado pierde uniformidad.';
    }
    return 'La categoria declarada mantiene su comportamiento conceptual en '
        'presencia de agua.';
  }

  String _adecuacion(
    EnergyCategory energia,
    RockHardness dureza,
    WaterResistance resistencia,
    WaterPresence agua,
  ) {
    final bool problemaAgua =
        agua != WaterPresence.seco && resistencia == WaterResistance.baja;
    final double balance = energia.indiceRelativo / dureza.indice;
    final bool balanceOk = balance >= 0.95 && balance <= 1.35;

    if (problemaAgua && !balanceOk) {
      return 'Adecuacion conceptual baja: fallan simultaneamente el balance '
          'energia-dureza y la compatibilidad con el agua declarada.';
    }
    if (problemaAgua) {
      return 'Adecuacion conceptual limitada por la presencia de agua.';
    }
    if (!balanceOk) {
      return 'Adecuacion conceptual limitada por el balance entre categoria '
          'energetica y dureza de la roca.';
    }
    return 'Adecuacion conceptual coherente con la roca y el agua declaradas.';
  }

  String _observacion(
    EnergyCategory energia,
    RockHardness dureza,
    WaterResistance resistencia,
    WaterPresence agua,
  ) {
    if (agua != WaterPresence.seco) {
      return 'Discute en clase por que, ante presencia de agua, el primer '
          'criterio de seleccion suele ser la resistencia al agua y solo '
          'despues la energia disponible.';
    }
    if (dureza == RockHardness.muyDura && energia != EnergyCategory.alta) {
      return 'Compara este resultado con una categoria de mayor energia y '
          'explica el cambio en la fragmentacion esperada.';
    }
    if (dureza == RockHardness.blanda && energia == EnergyCategory.alta) {
      return 'En roca blanda, una categoria de alta energia suele traducirse '
          'en desplazamiento excesivo mas que en mejor fragmentacion.';
    }
    return 'Modifica una sola variable a la vez y observa como cambian las '
        'lecturas conceptuales: es la forma correcta de estudiar el efecto de '
        'cada parametro.';
  }
}

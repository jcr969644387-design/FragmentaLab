import '../models/blast_design.dart';
import '../models/mesh_type.dart';
import '../utils/formatters.dart';

/// Reconoce si la malla del ejercicio corresponde a perforacion subterranea,
/// a voladura superficial de banco, o a ambas.
///
/// La lectura es **conceptual**: se comparan cuatro rasgos geometricos del
/// ejercicio contra rangos academicos de referencia declarados aqui mismo y
/// documentados en `docs/formulas.md`. No identifica un metodo de explotacion
/// real ni sustituye el criterio de un ingeniero: solo le dice al estudiante
/// en que contexto tiene sentido la malla que esta viendo.
///
/// Cuando los rasgos caen en la franja comun a los dos metodos el resultado es
/// `MeshEnvironment.ambas`, que es el caso de un banco pequeno o de una labor
/// subterranea de seccion amplia.
class MeshTypeClassifier {
  const MeshTypeClassifier();

  /// Diametro maximo habitual en perforacion subterranea.
  static const double diametroMaxSubterraneaMm = 89;

  /// Diametro minimo habitual en perforacion de banco.
  static const double diametroMinSuperficialMm = 76;

  /// Altura de banco o avance maximo habitual en labores subterraneas.
  static const double alturaMaxSubterraneaM = 5;

  /// Altura de banco minima habitual a cielo abierto.
  static const double alturaMinSuperficialM = 4;

  /// Longitud de taladro maxima habitual en labores subterraneas.
  static const double longitudMaxSubterraneaM = 5;

  /// Longitud de taladro minima habitual en banco.
  static const double longitudMinSuperficialM = 4.5;

  /// Numero minimo de rasgos compatibles para considerar valido un metodo.
  static const int coincidenciasMinimas = 3;

  MeshTypeAssessment clasificar(BlastDesign d) {
    final List<MeshTypeCriterion> criterios = <MeshTypeCriterion>[
      MeshTypeCriterion(
        nombre: 'Diametro de perforacion',
        valor: Fmt.conUnidad(d.diametroMm, 'mm', 0),
        referencia: 'Subterranea hasta '
            '${Fmt.num2(diametroMaxSubterraneaMm, 0)} mm; '
            'superficial desde ${Fmt.num2(diametroMinSuperficialMm, 0)} mm.',
        compatibleSubterranea: d.diametroMm <= diametroMaxSubterraneaMm,
        compatibleSuperficial: d.diametroMm >= diametroMinSuperficialMm,
      ),
      MeshTypeCriterion(
        nombre: 'Altura de banco o avance',
        valor: Fmt.conUnidad(d.alturaBancoM, 'm'),
        referencia: 'Subterranea hasta '
            '${Fmt.num2(alturaMaxSubterraneaM, 0)} m de avance; '
            'superficial desde ${Fmt.num2(alturaMinSuperficialM, 0)} m de '
            'banco.',
        compatibleSubterranea: d.alturaBancoM <= alturaMaxSubterraneaM,
        compatibleSuperficial: d.alturaBancoM >= alturaMinSuperficialM,
      ),
      MeshTypeCriterion(
        nombre: 'Subperforacion',
        valor: Fmt.conUnidad(d.subperforacionM, 'm'),
        referencia: 'En labores subterraneas no se perfora bajo el piso; en '
            'banco la subperforacion es parte del diseno.',
        compatibleSubterranea: d.subperforacionM <= 0,
        compatibleSuperficial: d.subperforacionM > 0,
      ),
      MeshTypeCriterion(
        nombre: 'Longitud de perforacion',
        valor: Fmt.conUnidad(d.longitudPerforacionM, 'm'),
        referencia: 'Subterranea hasta '
            '${Fmt.num2(longitudMaxSubterraneaM, 0)} m; superficial desde '
            '${Fmt.num2(longitudMinSuperficialM, 1)} m.',
        compatibleSubterranea:
            d.longitudPerforacionM <= longitudMaxSubterraneaM,
        compatibleSuperficial:
            d.longitudPerforacionM >= longitudMinSuperficialM,
      ),
    ];

    final int subterranea = criterios
        .where((MeshTypeCriterion c) => c.compatibleSubterranea)
        .length;
    final int superficial = criterios
        .where((MeshTypeCriterion c) => c.compatibleSuperficial)
        .length;

    final MeshEnvironment tipo = _decidir(subterranea, superficial);

    return MeshTypeAssessment(
      tipo: tipo,
      criterios: criterios,
      coincidenciasSubterranea: subterranea,
      coincidenciasSuperficial: superficial,
      resumen: _resumen(tipo, criterios.length, subterranea, superficial),
    );
  }

  MeshEnvironment _decidir(int subterranea, int superficial) {
    if (subterranea >= coincidenciasMinimas &&
        superficial >= coincidenciasMinimas) {
      return MeshEnvironment.ambas;
    }
    if (superficial > subterranea) {
      return MeshEnvironment.superficial;
    }
    if (subterranea > superficial) {
      return MeshEnvironment.subterranea;
    }
    return MeshEnvironment.ambas;
  }

  String _resumen(
    MeshEnvironment tipo,
    int total,
    int subterranea,
    int superficial,
  ) {
    switch (tipo) {
      case MeshEnvironment.subterranea:
        return 'El ejercicio activo cumple $subterranea de $total rasgos de '
            'una malla subterranea y $superficial de una malla superficial.';
      case MeshEnvironment.superficial:
        return 'El ejercicio activo cumple $superficial de $total rasgos de '
            'una malla superficial y $subterranea de una malla subterranea.';
      case MeshEnvironment.ambas:
        return 'El ejercicio activo cumple $subterranea de $total rasgos '
            'subterraneos y $superficial de $total superficiales: la malla '
            'queda en la franja comun a los dos metodos.';
    }
  }
}

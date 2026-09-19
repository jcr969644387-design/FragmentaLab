import 'package:flutter/material.dart';

import '../models/education_config.dart';
import '../services/config_service.dart';
import '../utils/app_strings.dart';
import '../utils/ui_feedback.dart';
import '../widgets/app_card.dart';
import '../widgets/safety_banner.dart';
import 'screen_scaffold.dart';

/// Descripcion educativa de un parametro del curso.
class _Parametro {
  const _Parametro({
    required this.nombre,
    required this.simbolo,
    required this.unidad,
    required this.rango,
    required this.definicion,
    required this.influencia,
    required this.error,
  });

  final String nombre;
  final String simbolo;
  final String unidad;
  final String rango;
  final String definicion;
  final String influencia;
  final String error;
}

/// Modulo 3: parametros tecnicos.
///
/// Glosario de los trece parametros que el MVP maneja, con unidades, rangos de
/// entrada razonables para fines academicos y el error conceptual mas frecuente
/// asociado a cada uno.
class ParametersScreen extends StatelessWidget {
  const ParametersScreen({super.key, this.embebida = false});

  final bool embebida;

  @override
  Widget build(BuildContext context) {
    final EducationConfig config = ConfigService.instance.config;
    final List<_Parametro> parametros = _construirParametros(config);

    final Widget cuerpo = ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      children: <Widget>[
        const SafetyBanner(compacto: true),
        const SectionTitle(
          'Glosario de parametros',
          icono: Icons.menu_book_outlined,
          subtitulo:
              'Unidades y rangos de entrada razonables para uso academico.',
        ),
        ...parametros.map((_Parametro p) => _TarjetaParametro(p)),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Sobre los rangos mostrados',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Los rangos provienen de la configuracion educativa del '
                'proyecto y existen para acotar los ejercicios, no para '
                'describir practicas de campo. Un valor dentro de rango no '
                'significa que un diseno sea correcto, y un valor fuera de '
                'rango no significa que sea imposible: significa que el '
                'ejercicio sale del ambito previsto para el curso.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.limitacionModelo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );

    return envolverModulo(
      context: context,
      titulo: 'Parametros tecnicos',
      cuerpo: cuerpo,
      embebida: embebida,
    );
  }

  List<_Parametro> _construirParametros(EducationConfig config) {
    return <_Parametro>[
      _Parametro(
        nombre: 'Diametro de perforacion',
        simbolo: 'D',
        unidad: 'mm (se convierte a m en los calculos)',
        rango: '${config.rangoDiametroMm} mm',
        definicion:
            'Diametro del taladro perforado. Es la variable de referencia: el '
            'resto de las dimensiones geometricas se suele expresar como '
            'multiplo suyo.',
        influencia:
            'Al aumentar el diametro con los mismos coeficientes, la malla se '
            'abre y se requieren menos taladros para el mismo volumen, pero la '
            'distribucion se concentra en menos puntos.',
        error: 'Mezclar unidades: usar milimetros en una formula que espera '
            'metros multiplica el resultado por mil.',
      ),
      _Parametro(
        nombre: 'Burden',
        simbolo: 'B',
        unidad: 'm',
        rango: '${config.rangoBurdenDiametro} diametros',
        definicion:
            'Distancia perpendicular entre el taladro y la cara libre. Es la '
            'dimension que gobierna el confinamiento frontal.',
        influencia:
            'Un burden grande se asocia conceptualmente a fragmentacion '
            'gruesa y pie de banco; uno pequeno, a fragmentacion fina con '
            'mayor proyeccion.',
        error:
            'Confundir burden con espaciamiento. El burden mira hacia la cara '
            'libre; el espaciamiento, hacia el taladro vecino de la fila.',
      ),
      _Parametro(
        nombre: 'Espaciamiento',
        simbolo: 'S',
        unidad: 'm',
        rango: 'S/B entre ${config.rangoSobreBurden}',
        definicion:
            'Distancia entre taladros contiguos de una misma fila. Gobierna la '
            'interaccion lateral dentro de la fila.',
        influencia:
            'Muy corto, desperdicia perforacion; muy amplio, deja material '
            'grueso en la zona intermedia entre taladros.',
        error: 'Analizarlo de forma aislada. Siempre se lee junto al burden a '
            'traves de la relacion S/B.',
      ),
      _Parametro(
        nombre: 'Altura de banco',
        simbolo: 'H',
        unidad: 'm',
        rango: '${config.rangoAlturaBancoM} m',
        definicion:
            'Altura del banco que se pretende cortar, medida desde la cresta '
            'hasta el nivel de piso proyectado.',
        influencia:
            'Define el volumen conceptual por taladro y, junto al burden, la '
            'esbeltez del diseno.',
        error:
            'Confundirla con la longitud del taladro: la longitud incluye la '
            'subperforacion y depende de la inclinacion.',
      ),
      _Parametro(
        nombre: 'Longitud de perforacion',
        simbolo: 'L',
        unidad: 'm',
        rango: 'Coherente con H y J (tolerancia '
            '${(config.toleranciaLongitudPerforacion * 100).toStringAsFixed(0)} %)',
        definicion:
            'Longitud total del taladro. Geometricamente equivale a la altura '
            'de banco dividida por el coseno de la inclinacion, mas la '
            'subperforacion.',
        influencia:
            'Determina la esbeltez y, con ella, la sensibilidad del diseno a '
            'la desviacion de perforacion.',
        error:
            'Ingresar una longitud menor que la altura de banco: el taladro no '
            'alcanzaria el nivel de piso.',
      ),
      _Parametro(
        nombre: 'Subperforacion',
        simbolo: 'J',
        unidad: 'm',
        rango: '${config.rangoSubperforacionDiametro} diametros',
        definicion:
            'Longitud perforada por debajo del nivel de piso proyectado.',
        influencia:
            'Insuficiente, deja resaltes en el piso; excesiva, se asocia a '
            'dano bajo el nivel de piso y sobreexcavacion.',
        error: 'Tratarla como longitud sobrante. Es una decision de diseno con '
            'consecuencias sobre el piso del banco.',
      ),
      _Parametro(
        nombre: 'Taco',
        simbolo: 'T',
        unidad: 'm',
        rango: 'T/B entre ${config.rangoTacoBurden}',
        definicion:
            'Porcion superior del taladro ocupada por material inerte, cuya '
            'funcion conceptual es mantener el confinamiento.',
        influencia:
            'Corto, se asocia a proyeccion y onda aerea; largo, a bloques '
            'gruesos en la cresta del banco.',
        error:
            'Definirlo como un valor fijo. Se controla como relacion respecto '
            'al burden y al diametro.',
      ),
      _Parametro(
        nombre: 'Inclinacion del taladro',
        simbolo: 'alfa',
        unidad: 'grados respecto a la vertical',
        rango: '${config.rangoInclinacionGrados} grados',
        definicion:
            'Angulo del taladro respecto a la vertical. Modifica la longitud '
            'necesaria para alcanzar el mismo nivel de piso.',
        influencia:
            'Conceptualmente mejora la uniformidad del burden en toda la '
            'altura del banco y la estabilidad de la cara resultante.',
        error:
            'Olvidar el factor 1/cos(alfa) al calcular la longitud teorica del '
            'taladro.',
      ),
      const _Parametro(
        nombre: 'Desviacion de perforacion',
        simbolo: 'e',
        unidad: 'm o grados (no se calcula en el MVP)',
        rango: 'Cualitativo',
        definicion: 'Diferencia entre la trayectoria real del taladro y la '
            'proyectada, por efecto del equipo, el terreno o el operador.',
        influencia:
            'Su efecto crece con la longitud del taladro: el burden real en el '
            'fondo puede diferir mucho del burden de diseno.',
        error: 'Suponer que el diseno calculado es el diseno ejecutado. La '
            'desviacion explica buena parte de las diferencias de resultado.',
      ),
      const _Parametro(
        nombre: 'Densidad de la roca',
        simbolo: 'rho',
        unidad: 't/m³ (referencial, no se calcula en el MVP)',
        rango: 'Cualitativo',
        definicion:
            'Masa por unidad de volumen del macizo. Permite pasar de volumen '
            'geometrico a masa, calculo que el MVP deliberadamente no realiza.',
        influencia:
            'Condiciona el tonelaje asociado a un mismo volumen geometrico.',
        error: 'Usar la densidad de una muestra como densidad del macizo, que '
            'incluye discontinuidades y vacios.',
      ),
      const _Parametro(
        nombre: 'Resistencia de la roca',
        simbolo: 'sigma',
        unidad: 'MPa (referencial)',
        rango: 'Cualitativo: blanda a muy dura',
        definicion:
            'Capacidad del macizo para resistir esfuerzos. En Fragmenta Lab se '
            'representa mediante cuatro categorias de dureza.',
        influencia:
            'Cuanto mayor es la dureza, mas exigente resulta el balance frente '
            'a la categoria energetica seleccionada.',
        error: 'Considerar solo la resistencia de la matriz e ignorar las '
            'discontinuidades, que suelen gobernar el comportamiento real.',
      ),
      const _Parametro(
        nombre: 'Presencia de agua',
        simbolo: '-',
        unidad: 'Cualitativo: seco, humedo, con agua',
        rango: 'Tres categorias',
        definicion: 'Condicion de agua dentro del taladro, declarada de forma '
            'cualitativa.',
        influencia:
            'Con agua declarada, el criterio conceptual de seleccion prioriza '
            'la resistencia al agua por encima de la energia relativa.',
        error: 'Elegir primero por energia y despues revisar el agua: el orden '
            'correcto de los criterios es el inverso.',
      ),
      const _Parametro(
        nombre: 'Estructuras geologicas',
        simbolo: '-',
        unidad: 'Cualitativo',
        rango: 'No modelado en el MVP',
        definicion:
            'Fallas, diaclasas, estratificacion y contactos litologicos '
            'presentes en el macizo.',
        influencia:
            'Pueden dominar el resultado por encima de la geometria de la '
            'malla, guiando la rotura por planos preexistentes.',
        error: 'Suponer un macizo homogeneo. El MVP asume homogeneidad por '
            'simplificacion, y esa es una de sus principales limitaciones.',
      ),
    ];
  }
}

class _TarjetaParametro extends StatelessWidget {
  const _TarjetaParametro(this.parametro);

  final _Parametro parametro;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme esquema = tema.colorScheme;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: tema.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (_) => UiFeedback.seleccion(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: esquema.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              parametro.simbolo,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w800,
                color: esquema.primary,
              ),
            ),
          ),
          title: Text(
            parametro.nombre,
            style: tema.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            'Unidad: ${parametro.unidad}',
            style: tema.textTheme.bodySmall,
          ),
          children: <Widget>[
            _bloque(context, 'Definicion', parametro.definicion),
            _bloque(context, 'Influencia conceptual', parametro.influencia),
            _bloque(context, 'Error frecuente', parametro.error),
            _bloque(context, 'Rango de entrada academico', parametro.rango),
          ],
        ),
      ),
    );
  }

  Widget _bloque(BuildContext context, String titulo, String texto) {
    final ThemeData tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            titulo,
            style: tema.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: tema.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(texto, style: tema.textTheme.bodySmall),
        ],
      ),
    );
  }
}

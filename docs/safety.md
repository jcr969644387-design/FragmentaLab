# Seguridad y limites de uso

## 1. Uso educativo exclusivo

> Fragmenta Lab es una aplicacion **exclusivamente educativa y conceptual**. No
> reemplaza un diseno de voladura elaborado por un ingeniero autorizado ni una
> evaluacion de campo.

Su unico proposito es ayudar a un estudiante a **razonar sobre relaciones
geometricas y efectos cualitativos** en un entorno de aula. Cualquier otro uso
esta fuera del alcance previsto por sus autores.

## 2. Contenido deliberadamente excluido

La aplicacion **no incluye y no incluira**:

- instrucciones para fabricar explosivos;
- instrucciones para manipular, transportar o almacenar explosivos;
- cantidades reales de explosivo para una voladura operativa;
- procedimientos de carga, conexion, iniciacion o disparo;
- tiempos de retardo, cargas operantes por intervalo o secuencias ejecutables;
- marcas comerciales, formulaciones o especificaciones de productos;
- recomendaciones operativas definitivas.

Esta exclusion es una **decision de diseno del producto**, no una limitacion
tecnica pendiente de resolver. Las categorias de explosivos del modulo 4 son
abstractas (baja, media y alta energia; resistencia al agua baja o buena) y sus
indices son adimensionales: no representan ninguna propiedad medible de un
producto real ni permiten inferirla.

## 3. Prohibicion de uso operativo

Los resultados de Fragmenta Lab **no constituyen un diseno de voladura**. Esta
prohibido:

- usar sus salidas como base de una malla a perforar;
- presentarlas como memoria de calculo, informe tecnico o documento de respaldo;
- trasladarlas a una operacion real, aunque sea "como referencia";
- interpretar el nivel de riesgo como una evaluacion de seguridad del trabajo.

Un diseno real exige caracterizacion geomecanica del macizo, seleccion de
explosivo, analisis de vibraciones y proyecciones, control de perforacion,
evaluacion de riesgos del sitio, cumplimiento del marco legal aplicable y la
responsabilidad de un profesional habilitado. Nada de eso existe en esta
aplicacion.

## 4. Limitaciones del modelo

- **No hay fisica.** No se resuelven ecuaciones de detonacion, propagacion de
  ondas ni fragmentacion. Los indicadores provienen de reglas cualitativas
  declaradas en `docs/formulas.md`.
- **No hay formula universal de burden.** Los coeficientes son referencias
  academicas configurables; el valor real depende de roca, explosivo, equipo,
  banco, confinamiento y experiencia de campo.
- **Comparativo, no predictivo.** Los indices solo tienen sentido al comparar
  variantes del mismo ejercicio entre si; su valor absoluto no significa nada
  fuera de la aplicacion.
- **Geometria idealizada.** Malla regular, banco uniforme, taladros paralelos y
  de igual longitud, macizo homogeneo, sin estructuras ni desviacion real.
- **Volumen conceptual.** `B x S x H x N` es geometria, no produccion.
- **Secuencia sin tiempos.** Solo orden relativo adimensional.

## 5. Supervision profesional

El uso recomendado es **acompanado por un docente** del curso de Perforacion y
Voladura u Operaciones Mineras, que contextualice los resultados, senale las
diferencias con la practica real y corrija interpretaciones erroneas. La
aplicacion es un apoyo a la clase, no un sustituto de la formacion ni de la
experiencia supervisada en campo.

## 6. Advertencias generales

- La voladura es una actividad de **alto riesgo** regulada por normativa
  especifica en cada pais. Su ejecucion corresponde unicamente a personal
  autorizado, con licencia vigente y bajo supervision competente.
- El acceso, manejo y almacenamiento de explosivos estan sujetos a control legal
  estricto. Ninguna aplicacion movil puede habilitar a una persona para esas
  tareas.
- Ante cualquier duda operativa, la respuesta correcta esta en el procedimiento
  de la operacion y en el ingeniero responsable, no en esta aplicacion.
- Si un contenido de la aplicacion parece sugerir una practica operativa, debe
  entenderse como un error de redaccion y reportarse: el criterio que prevalece
  es el de este documento.

## 7. Presencia de la advertencia en la aplicacion

La advertencia de uso educativo se muestra de forma permanente:

- completa en la pantalla de inicio, antes de cualquier calculo;
- en version compacta en todos los modulos de calculo, simulacion, evaluacion y
  tutor;
- como bloque destacado de alcance en el modulo conceptual de explosivos;
- como limitacion explicita junto a cada formula y a cada resultado.

El estudiante nunca debe poder ver un resultado sin ver, en la misma pantalla,
el recordatorio de que es conceptual.

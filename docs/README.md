# Guia funcional de Fragmenta Lab

Este documento describe **como se usa** la aplicacion. Para las formulas ver
`formulas.md`, para la estructura tecnica `architecture.md` y para los limites
de uso `safety.md`.

---

## Idea central

Fragmenta Lab trabaja siempre sobre **un unico ejercicio activo**. El estudiante
define una malla en el modulo 2 y todos los demas modulos (calculadora,
explosivos, secuencia, simulacion, tutor) leen ese mismo ejercicio. Cambiar el
burden en la simulacion cambia tambien el diagnostico del tutor.

Al iniciar, el ejercicio contiene un caso educativo de referencia
(D = 89 mm, B = 2.6 m, S = 3.0 m, H = 8.0 m, L = 8.9 m, J = 0.9 m, T = 2.4 m,
3 filas x 6 taladros, tresbolillo) que puede restablecerse desde la pantalla de
inicio.

---

## Navegacion

- **Barra inferior**: Inicio, Malla, Simulacion, Evaluacion y Tutor (los cuatro
  modulos de uso frecuente).
- **Pantalla de inicio**: accesos a los nueve modulos, incluidos los que no
  estan en la barra (burden y espaciamiento, parametros, explosivos, secuencia).

---

## Modulo 1 — Inicio

Muestra el nombre, el logotipo textual, la descripcion, el objetivo educativo,
la advertencia de seguridad y el indicador de que todos los resultados son
conceptuales. Desde aqui tambien se reinicia el ejercicio al caso de referencia.

## Modulo 2 — Diseno de malla

Entradas: diametro, burden, espaciamiento, altura de banco, longitud de
perforacion, subperforacion, taco, numero de filas, taladros por fila y tipo de
geometria (cuadrada, rectangular o tresbolillo).

Salidas: relacion S/B, area teorica por taladro, numero total de taladros,
volumen geometrico conceptual, longitud cargada conceptual, longitud de taco,
nivel de riesgo (bajo, medio, alto) y mensajes de validacion clasificados en
errores, advertencias e informativos.

El boton *Sugerir B y S desde el diametro* rellena burden y espaciamiento con el
modelo configurable del modulo 3.

## Modulo 3 — Burden y espaciamiento

Calculadora educativa con dos coeficientes ajustables:

- `k_B`: burden como multiplo del diametro.
- `k_S`: espaciamiento como relacion respecto al burden.

Para cada calculo se muestra formula, variables, unidades, resultado,
interpretacion y limitaciones. Los coeficientes por defecto se leen de
`assets/config/education_config.json` y pueden modificarse en el archivo sin
tocar el codigo.

## Modulo 4 — Parametros tecnicos

Ficha educativa de 13 parametros (diametro, burden, espaciamiento, altura de
banco, longitud de perforacion, subperforacion, taco, inclinacion, desviacion,
densidad de la roca, resistencia de la roca, presencia de agua y estructuras
geologicas) con definicion, unidad, rango academico razonable, influencia y
error frecuente.

## Modulo 5 — Explosivos (conceptual)

Solo categorias abstractas: energia baja / media / alta y resistencia al agua
baja / buena. Devuelve lectura cualitativa de energia relativa, fragmentacion
esperada, desplazamiento esperado, sensibilidad al agua y adecuacion conceptual
a la roca. **No hay marcas, cantidades, recetas ni procedimientos.**

## Modulo 6 — Secuencia de retardos

Cuatro patrones: uniforme, escalonada, por filas y por taladros. Muestra el
orden conceptual de salida sobre la malla, la matriz de ordenes, los intervalos
relativos (adimensionales), la direccion de desplazamiento esperada y la
influencia sobre fragmentacion y vibracion. **No hay tiempos en milisegundos ni
instrucciones de conexion.**

## Modulo 7 — Simulacion conceptual

Vista en planta de la malla con los taladros como circulos y su orden de salida.
Controles rapidos de burden, espaciamiento, diametro, filas, taladros, tipo de
malla, categoria energetica y secuencia. Indicadores: uniformidad,
fragmentacion, desplazamiento, posible sobreexcavacion, posible subexcavacion,
eficiencia conceptual estimada y nivel de riesgo. Es una simulacion **visual y
basada en reglas**.

## Modulo 8 — Evaluacion

Quince preguntas de seleccion multiple sobre burden, espaciamiento, relacion
S/B, diametro, taco, subperforacion, desviacion, agua, secuencia, fragmentacion
y seguridad. Cada respuesta muestra si fue correcta, cual era la correcta y la
explicacion tecnica. Al final: puntaje, porcentaje, errores cometidos, temas a
repasar y revision detallada.

## Modulo 9 — Tutor local

Base de reglas cerrada, sin conexion y sin claves. Responde por palabras clave
a las preguntas frecuentes del curso y produce un **diagnostico del ejercicio
activo** (por ejemplo, si el burden quedo por encima del rango educativo). Si no
encuentra coincidencia, lo dice en vez de improvisar.

---

## Flujo de uso sugerido para estudiantes

1. **Leer la advertencia** en la pantalla de inicio.
2. **Modulo 4**: revisar el significado de los parametros que se van a usar.
3. **Modulo 3**: obtener un burden y un espaciamiento de partida desde el
   diametro y entender de donde salen.
4. **Modulo 2**: completar la malla, leer las validaciones y corregir hasta que
   no queden errores.
5. **Modulo 5**: declarar la categoria energetica y las condiciones de roca y
   agua del ejercicio.
6. **Modulo 6**: elegir un patron de secuencia y observar como cambia la lectura
   de desplazamiento y vibracion.
7. **Modulo 7**: mover un parametro a la vez y observar el efecto sobre los
   indicadores. Esta comparacion es el nucleo del aprendizaje.
8. **Modulo 9**: consultar el diagnostico del ejercicio y las dudas puntuales.
9. **Modulo 8**: rendir la evaluacion y repasar los temas marcados como error.

## Sugerencia de uso en aula

- Plantear un mismo caso y pedir tres variantes: una con S/B fuera de rango, una
  con taco insuficiente y una equilibrada; comparar indicadores y justificar.
- Pedir que el estudiante explique **por que** cambia el indicador, no solo que
  reporte el numero.

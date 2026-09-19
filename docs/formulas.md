# Formulas, supuestos y limitaciones

Todas las expresiones de este documento son **educativas**. Ninguna debe usarse
como criterio de diseno operativo. Los coeficientes y rangos se leen de
`assets/config/education_config.json` y pueden modificarse sin tocar el codigo.

---

## 1. Notacion y unidades

| Simbolo | Variable | Unidad |
|---------|----------|--------|
| `D` | Diametro del taladro | mm (se convierte a m: `D_m = D / 1000`) |
| `B` | Burden | m |
| `S` | Espaciamiento | m |
| `H` | Altura de banco | m |
| `L` | Longitud de perforacion | m |
| `J` | Subperforacion | m |
| `T` | Taco | m |
| `alfa` | Inclinacion respecto a la vertical | grados |
| `n_f` | Numero de filas | adimensional (entero) |
| `n_t` | Taladros por fila | adimensional (entero) |
| `N` | Numero total de taladros | adimensional (entero) |

---

## 2. Modelo configurable de burden y espaciamiento

```
B = k_B x D_m          (k_B por defecto = 30)
S = k_S x B            (k_S por defecto = 1.15)
```

Factor implicito (lectura inversa, util para interpretar un diseno dado):

```
k_B_implicito = B / D_m
```

**Supuesto.** Se asume unicamente que el burden escala con el diametro del
taladro y que el espaciamiento escala con el burden. Es la relacion mas simple
que permite razonar sobre proporciones.

**Limitacion critica.** No existe una formula universal de burden. El valor real
depende de la roca (resistencia, densidad, estructuras), del explosivo, del
equipo de perforacion, de la altura y el confinamiento del banco y de la
experiencia de campo. Modelos como Langefors-Kihlstrom, Konya o Ash introducen
esas variables de forma distinta y con supuestos propios. Fragmenta Lab
deliberadamente **no** adopta uno de ellos como verdad: expone un coeficiente
visible y ajustable para que el estudiante entienda que el coeficiente es una
decision, no una constante de la naturaleza.

*Ejemplo educativo.* Con `D = 89 mm` → `D_m = 0.089 m` y `k_B = 30`:
`B = 30 x 0.089 = 2.67 m`. Con `k_S = 1.15`: `S = 1.15 x 2.67 = 3.07 m`.

---

## 3. Relaciones geometricas

```
S/B            = S / B                      (adimensional)
Area/taladro   = B x S                      (m2)
N              = n_f x n_t                  (adimensional)
Volumen/taladro= B x S x H                  (m3)
Volumen total  = B x S x H x N              (m3)
L_cargada      = max(0, L - T)              (m)
L_teorica      = H / cos(alfa) + J          (m)
Desviacion_L   = (L - L_teorica) / L_teorica (adimensional)
Burden en D    = B / D_m                    (adimensional)
Taco en B      = T / B                      (adimensional)
Subperf. en D  = J / D_m                    (adimensional)
Esbeltez       = L / B                      (adimensional)
Ancho de malla = (n_t - 1) x S              (m)
Profundidad    = (n_f - 1) x B              (m)
```

**Supuestos.** Malla regular, banco de altura constante, taladros paralelos
entre si y de igual longitud, terreno homogeneo, sin considerar desviacion real
de perforacion.

**Limitaciones.** `L_cargada` es una **longitud geometrica**, no una carga: no
representa masa, densidad lineal ni distribucion de energia. El volumen es
geometrico conceptual y no equivale a produccion (no considera esponjamiento,
dilucion, perdidas ni recuperacion).

*Ejemplo educativo.* `B = 2.6`, `S = 3.0`, `H = 8.0`, `n_f = 3`, `n_t = 6`:
`S/B = 1.15`; `Area = 7.8 m2`; `N = 18`; `Volumen = 7.8 x 8.0 x 18 = 1123.2 m3`.

---

## 4. Rangos educativos de referencia

Definidos en `education_config.json`:

| Relacion | Rango educativo | Rango optimo |
|----------|-----------------|--------------|
| `S / B` | 0.8 – 1.8 | 1.0 – 1.4 |
| `B / D_m` | 20 – 45 | — |
| `T / B` | 0.6 – 1.4 | — |
| `J / D_m` | 6 – 14 | — |
| `L / B` (esbeltez) | 1.5 – 8 | — |
| `D` | 25 – 400 mm | — |
| `H` | 1 – 30 m | — |
| `alfa` | 0 – 30 grados | — |
| Tolerancia de longitud | 0.20 (20 %) | — |

Estar fuera de rango **no significa** que un diseno sea incorrecto en la
realidad: significa que queda fuera del intervalo que la aplicacion usa para
razonar en clase, y que el estudiante debe justificar la diferencia.

---

## 5. Clasificacion de riesgo (7 criterios)

El clasificador evalua siete criterios y asigna a cada uno un nivel:

| Criterio | Bajo | Medio | Alto |
|----------|------|-------|------|
| Relacion S/B | dentro del rango optimo | dentro del rango educativo | fuera del rango educativo |
| Burden / diametro | dentro del rango | hasta 1.3 veces el limite | mas alla de 1.3 veces el limite |
| Taco / burden | dentro del rango | desviacion moderada | menos de 0.6 veces el minimo |
| Subperforacion / diametro | dentro del rango | fuera del rango | muy por debajo o muy por encima |
| Esbeltez L/B | dentro del rango | fuera del rango | — |
| Coherencia de L con H y J | desviacion ≤ 10 % | ≤ 20 % | > 20 % |
| Coherencia de la geometria declarada | consistente con S/B | inconsistente | — |

El **puntaje** (0–100) es el porcentaje de criterios conformes ponderado por la
severidad de cada hallazgo. El nivel global es el nivel mas severo encontrado.

---

## 6. Indice conceptual de eficiencia (fragmentacion)

Sistema de reglas aditivo, declarado aqui en su totalidad:

```
Base                                              50
S/B en rango optimo                              +12
S/B en rango educativo (no optimo)                +4
S/B fuera del rango educativo                    -15
B/D_m en rango                                    +8
B/D_m hasta 1.3 veces el limite                  -10
B/D_m mas alla                                   -15
T/B en rango                                      +8
T/B por debajo del minimo                        -15
T/B por encima del maximo                        -10
J/D_m en rango                                    +4
J/D_m por encima                                 -10
J/D_m por debajo                                  -8
Balance energia/dureza en [0.95, 1.35]            +8
Balance por debajo (energia insuficiente)        -12
Balance por encima (energia excedida)             -6
Agua declarada con baja resistencia al agua      -15
Agua declarada con buena resistencia al agua      -3
Geometria tresbolillo                             +4
Esbeltez fuera de rango                           -6
Desviacion de longitud > tolerancia              -10
```

El resultado se limita al intervalo **5 – 95** (nunca 0 ni 100: un modelo
conceptual no puede afirmar perfeccion ni fracaso absoluto). Lectura del nivel
de riesgo asociado: `>= 70` bajo, `>= 45` medio, `< 45` alto.

El **balance energia/dureza** es el cociente entre el indice de la categoria
energetica (baja 0.7, media 1.0, alta 1.3) y el indice de dureza de la roca
(blanda 0.7, media 1.0, dura 1.25, muy dura 1.5). Ambos son **adimensionales y
abstractos**: no representan potencia relativa por peso, velocidad de
detonacion, energia especifica ni ninguna propiedad medible de un producto real.

---

## 7. Secuencia de retardos

Orden de salida segun el patron, con `f` = indice de fila (0 = mas cercana a la
cara libre) y `c` = indice de columna:

```
Uniforme      orden = 1
Por filas     orden = f + 1
Por taladros  orden = f x n_t + c + 1
Escalonada    orden = f + c + 1
Intervalo relativo = orden - 1   (adimensional)
```

**Limitacion.** No se calculan tiempos, no se definen elementos de iniciacion y
no se describen conexiones. El modulo solo permite comparar el **efecto
conceptual del orden** entre cuatro patrones tipicos.

---

## 8. Validaciones

Errores (bloquean la lectura del resultado): valores negativos; diametro,
burden, espaciamiento o altura iguales a cero; numero de taladros no entero o
fuera de 1–200; taco mayor o igual que la longitud del taladro; altura de banco
mayor que la longitud de perforacion; subperforacion negativa o mayor que la
longitud; longitud incoherente con `H` y `J` mas alla de la tolerancia.

Advertencias (permiten continuar): relaciones geometricas fuera de los rangos
educativos configurados.

Informativos: subperforacion nula, inclinacion cero, mallas de una sola fila y
situaciones similares que conviene comentar en clase.

---

## 9. Que NO calcula esta aplicacion

- Masa de explosivo, densidad lineal de carga o factor de carga.
- Tiempos de retardo, ventanas de disparo o cargas operantes por intervalo.
- Curvas de fragmentacion reales (Kuz-Ram u otras), P80 o tamano medio.
- Vibracion, sobrepresion de aire o proyeccion de fragmentos.
- Costos, productividad o programacion de la operacion.

Todo lo anterior queda fuera del alcance de forma **deliberada**, por seguridad
y porque no es necesario para el objetivo educativo del MVP.

# Fragmenta Lab

**Fragmenta Lab: Simulador Educativo de Perforacion y Voladura**

Aplicacion movil educativa (Flutter / Dart / Material 3, Android) para que
estudiantes de Ingenieria de Minas exploren de forma **conceptual** como los
parametros geometricos de una malla de perforacion se relacionan entre si y que
lectura cualitativa producen sobre fragmentacion, desplazamiento, eficiencia y
riesgo.

---

## Advertencia de seguridad

> La aplicacion es **exclusivamente educativa y conceptual**. No reemplaza un
> diseno de voladura elaborado por un ingeniero autorizado ni una evaluacion de
> campo.

Fragmenta Lab **no contiene** y **no debe usarse para obtener**:

- instrucciones para fabricar explosivos,
- instrucciones para manipular explosivos,
- cantidades reales para una voladura operativa,
- procedimientos de carga, conexion o iniciacion de detonadores,
- marcas comerciales de productos explosivos,
- recomendaciones operativas definitivas.

El modulo de explosivos trabaja solo con **categorias abstractas de energia y
resistencia al agua**, y el modulo de secuencias solo con **orden relativo de
salida**, sin tiempos ni accesorios. Ver `docs/safety.md`.

---

## Objetivo educativo

Ayudar al estudiante a comprender como el diametro de perforacion, el burden,
el espaciamiento, la altura de banco, la longitud de perforacion, la
subperforacion, el taco y la secuencia de iniciacion influyen, de forma
conceptual, en la fragmentacion, el desplazamiento, la eficiencia y el riesgo de
un diseno.

Competencias que se trabajan:

| # | Competencia |
|---|-------------|
| 1 | Comprender los elementos de una malla de perforacion |
| 2 | Diferenciar burden y espaciamiento |
| 3 | Calcular relaciones geometricas basicas |
| 4 | Analizar la influencia del diametro de perforacion |
| 5 | Comprender el efecto conceptual de la energia del explosivo |
| 6 | Interpretar secuencias de retardos |
| 7 | Evaluar fragmentacion y eficiencia de manera cualitativa |
| 8 | Identificar disenos con riesgo de sobreexcavacion, fragmentacion deficiente o proyeccion excesiva |

## Publico objetivo

Estudiantes de Ingenieria de Minas de los cursos de **Perforacion y Voladura**,
**Operaciones Mineras**, **Diseno de Minas** y **Seguridad Minera**.

---

## Modulos del MVP

| # | Modulo | Que hace |
|---|--------|----------|
| 1 | Inicio | Identidad, descripcion, advertencia y acceso a los modulos |
| 2 | Diseno de malla | 10 entradas, relaciones geometricas, riesgo y validaciones |
| 3 | Burden y espaciamiento | Modelo configurable `B = k_B x D`, `S = k_S x B` con formula, variables, unidades e interpretacion |
| 4 | Parametros tecnicos | 13 parametros con definicion, unidad, rango academico e influencia |
| 5 | Explosivos (conceptual) | Categorias abstractas y efectos cualitativos |
| 6 | Secuencia de retardos | Orden conceptual, intervalos relativos, direccion e influencia |
| 7 | Simulacion conceptual | Vista en planta de la malla e indicadores por reglas |
| 8 | Evaluacion | 15 preguntas con puntaje, respuesta correcta, explicacion y errores |
| 9 | Tutor local | Base de reglas sin conexion, con interfaz lista para IA futura |

Todos los modulos comparten **un solo ejercicio activo**: lo que se cambia en la
malla se refleja en la simulacion, el tutor y los indicadores.

---

## Tecnologias

- Flutter estable (canal `stable`, Dart SDK `>=3.4.0 <4.0.0`)
- Material 3, interfaz completamente en espanol, modo claro inicial
- Arquitectura por capas: `models`, `calculators`, `services`, `screens`,
  `widgets`, `theme`, `utils`
- Estado compartido con `ChangeNotifier` + `InheritedNotifier` (sin paquetes de
  terceros)
- **Cero dependencias externas** ademas de `flutter`, `flutter_test` y
  `flutter_lints`
- Funcionamiento 100 % local y sin conexion

---

## Ejecutar localmente

```bash
flutter --version          # canal stable
flutter pub get
flutter run                # dispositivo o emulador Android
```

Si es la primera vez que se abre el proyecto, Flutter generara automaticamente
los archivos del wrapper de Gradle (`gradlew`, `gradle-wrapper.jar`), que no se
versionan en este repositorio.

## Ejecutar las pruebas

```bash
flutter test                       # todas las pruebas
flutter test test/validators_test.dart   # un archivo
flutter analyze                    # analisis estatico
dart format .                      # formato (obligatorio antes del primer push)
```

> **Importante para CI:** el flujo `flutter_ci.yml` ejecuta
> `dart format --output=none --set-exit-if-changed .`. Ejecuta `dart format .`
> una vez en tu maquina y confirma el resultado antes del primer push, para que
> el formateador oficial no marque diferencias.

## Generar el APK

```bash
flutter build apk --release
# salida: build/app/outputs/flutter-apk/app-release.apk
```

Se genera **un unico APK universal**. El proyecto no usa `--split-per-abi` ni
matrices de arquitecturas.

La configuracion de firma de `release` apunta deliberadamente a la firma de
depuracion para que el repositorio **no contenga claves ni contrasenas**. Para
una publicacion real debe configurarse un `keystore` propio fuera del control de
versiones.

---

## GitHub Actions

### `.github/workflows/flutter_ci.yml`

Se ejecuta en `push` a `main` y `develop`, y en `pull_request` hacia `main`.
Pasos: `actions/checkout` → Java (Temurin 17) → Flutter (canal stable) →
`flutter pub get` → `dart format --output=none --set-exit-if-changed .` →
`flutter analyze` → `flutter test`.

### `.github/workflows/build_apk.yml`

Se ejecuta manualmente (`workflow_dispatch`) y al publicar un tag `v*`.
Pasos: `actions/checkout` → Java → Flutter → `flutter pub get` → `flutter test`
→ `flutter build apk --release` → verificacion del APK → carga del artifact
`blast-design-lab-apk` con la ruta
`build/app/outputs/flutter-apk/app-release.apk`.

Solo se sube el archivo `app-release.apk`; nunca la carpeta `build/` ni el
proyecto completo.

```bash
git tag v1.0.0
git push origin v1.0.0    # dispara build_apk.yml
```

---

## Estructura del proyecto

```
FragmentaLab/
├── .github/workflows/     flutter_ci.yml, build_apk.yml
├── android/               configuracion Android (AGP 8.3, Kotlin 1.9, Java 17)
├── assets/
│   ├── config/            education_config.json (coeficientes y rangos)
│   └── images/            sin imagenes externas (ver README de la carpeta)
├── docs/                  README, formulas, architecture, safety
├── lib/
│   ├── main.dart          arranque y carga de configuracion
│   ├── app.dart           MaterialApp, tema y estado compartido
│   ├── models/            datos inmutables (13 archivos)
│   ├── calculators/       logica pura de calculo y reglas (5 archivos)
│   ├── services/          configuracion, estado, banco de preguntas, tutor
│   ├── screens/           los 9 modulos + shell de navegacion
│   ├── widgets/           componentes reutilizables
│   ├── theme/             colores y tema Material 3
│   └── utils/             textos, formato y validaciones
├── test/                  10 archivos de prueba (unitarias + widget)
├── pubspec.yaml
├── analysis_options.yaml
├── CHANGELOG.md
└── .gitignore
```

---

## Limitaciones del modelo

- Los coeficientes `k_B` y `k_S` son **referencias academicas configurables**,
  no valores universales. El burden real depende de roca, explosivo, equipo,
  banco, confinamiento y experiencia de campo.
- Los indicadores de fragmentacion, eficiencia y riesgo provienen de un sistema
  de **reglas cualitativas declaradas** en `docs/formulas.md`, no de un modelo
  fisico. No predicen resultados operacionales.
- El volumen es **geometrico conceptual** (`B x S x H x N`), no un calculo de
  produccion.
- La secuencia de retardos expresa **orden relativo**, no tiempos en
  milisegundos.

## Futuras mejoras

- Guardar y comparar varios ejercicios del estudiante.
- Exportar el analisis del ejercicio en PDF para entregarlo en clase.
- Banco de preguntas ampliable por el docente desde archivo local.
- Tutor con IA (interfaz `TutorEngine` ya preparada) previa validacion academica
  de las respuestas, manejo de claves fuera del repositorio y alternativa local
  sin conexion.
- Casos guiados por tipo de yacimiento y modo docente con seguimiento de
  progreso.

---

Proyecto educativo. Ver `docs/safety.md` antes de cualquier uso en aula.

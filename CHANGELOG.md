# Changelog

Todos los cambios relevantes de Fragmenta Lab se documentan en este archivo.
El formato sigue la idea general de [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/)
y el proyecto usa versionado semantico.

## [1.0.0] - 2026-09-12

### Agregado

- Version inicial del MVP de **Fragmenta Lab: Simulador Educativo de
  Perforacion y Voladura**.
- Modulo 1: pantalla de inicio con identidad textual, descripcion, advertencia
  de seguridad e ingreso a los nueve modulos.
- Modulo 2: diseno de malla con entrada de parametros geometricos, calculo de
  relacion S/B, area por taladro, numero de taladros, volumen conceptual,
  longitud cargada conceptual e indicadores de riesgo.
- Modulo 3: calculadora educativa de burden y espaciamiento con coeficientes
  configurables desde `assets/config/education_config.json`.
- Modulo 4: glosario de parametros tecnicos con unidades y rangos academicos.
- Modulo 5: modulo conceptual de explosivos basado en categorias abstractas de
  energia y resistencia al agua (sin marcas, recetas ni cantidades).
- Modulo 6: secuencias de retardos conceptuales (uniforme, escalonada, por
  filas, por taladros) con visualizacion de orden relativo.
- Modulo 7: simulacion conceptual de malla basada en reglas, con indicadores de
  uniformidad, fragmentacion, desplazamiento y eficiencia estimada.
- Modulo 8: evaluacion con 15 preguntas de seleccion multiple, puntaje,
  respuestas correctas y explicacion tecnica.
- Modulo 9: tutor local basado en reglas, sin API externa ni claves, con
  interfaz `TutorEngine` preparada para una futura integracion de IA.
- Tema Material 3 con paleta minera, modo claro por defecto y modo oscuro
  disponible.
- Validaciones numericas completas y mensajes de error comprensibles.
- Pruebas unitarias de calculadoras, validadores, clasificador de riesgo,
  evaluador conceptual de fragmentacion y secuenciador de retardos.
- Prueba de widget de la pantalla principal.
- Workflows de GitHub Actions: `flutter_ci.yml` y `build_apk.yml`.
- Documentacion en `docs/`: guia funcional, formulas, arquitectura y seguridad.

### Decisiones de compatibilidad

- No se usan paquetes externos: solo `flutter`, `flutter_test` y
  `flutter_lints`.
- Se evitan APIs que cambiaron de forma entre versiones de Flutter:
  se usa un widget propio `AppCard` en lugar de `CardTheme`; la barra superior
  y la decoracion de los campos se construyen en el widget
  (`barraSuperior`, `AppTheme.entrada`) en lugar de `ThemeData.appBarTheme` y
  `ThemeData.inputDecorationTheme`; los desplegables usan
  `InputDecorator` + `DropdownButton` en lugar de `DropdownButtonFormField`;
  la seleccion de secuencia usa `InkWell` en lugar de `RadioListTile`; y no se
  declara `useMaterial3`, porque Material 3 ya es el comportamiento por
  defecto.

### Notas

- Antes del primer push se recomienda ejecutar `dart format .` para que el paso
  `dart format --output=none --set-exit-if-changed .` del CI pase sin cambios.
- La aplicacion es exclusivamente educativa y conceptual. No sustituye un
  diseno de voladura elaborado por un ingeniero autorizado.

## [No liberado]

### Planificado

- Integracion opcional de un tutor con IA mediante `RemoteTutorEngine`.
- Persistencia local del historial de evaluaciones.
- Exportacion de reportes educativos en PDF.

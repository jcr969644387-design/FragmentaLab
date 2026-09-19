# Arquitectura de Fragmenta Lab

## 1. Principio de organizacion

El proyecto se organiza en capas con una regla de dependencia estricta:

```
screens / widgets        (interfaz, Flutter)
        ↓
services                 (estado, configuracion, contenido educativo)
        ↓
calculators              (logica pura, sin Flutter)
        ↓
models                   (datos inmutables, sin Flutter)
```

- `models` y `calculators` **no importan `package:flutter/material.dart`**
  (salvo el uso de `dart:math`), por lo que son verificables con pruebas
  unitarias puras y reutilizables en otra interfaz.
- `screens` no contiene formulas: pide los resultados a `calculators` y solo se
  ocupa de presentarlos.
- Toda cadena visible vive en `utils/app_strings.dart` o en la propia pantalla,
  nunca dentro de una calculadora.

## 2. Estado compartido

No se usa ningun paquete de gestion de estado. El ejercicio activo es un
`BlastDesign` inmutable dentro de `DesignStore` (`ChangeNotifier`), publicado en
el arbol con `DesignScope` (`InheritedNotifier`).

```dart
final DesignStore store = DesignScope.of(context);
store.actualizar(store.design.copyWith(burdenM: 3.0));
```

Cualquier pantalla que lea `DesignScope.of(context)` se reconstruye cuando el
ejercicio cambia. Esto permite que los nueve modulos trabajen sobre el mismo
caso sin duplicar datos ni sincronizar copias.

`ConfigService` es un singleton `ChangeNotifier` con los coeficientes educativos;
`app.dart` lo escucha para que un cambio de configuracion recalcule toda la
aplicacion.

## 3. Responsabilidad de cada carpeta

| Carpeta | Responsabilidad | No debe contener |
|---------|-----------------|------------------|
| `lib/models` | Datos inmutables y enumeraciones del dominio | Logica de calculo, widgets |
| `lib/calculators` | Formulas y reglas puras | Estado, acceso a archivos, widgets |
| `lib/services` | Estado compartido, configuracion, contenido | Formulas geometricas |
| `lib/screens` | La pantalla de inicio, los 8 modulos y la navegacion | Formulas |
| `lib/widgets` | Componentes reutilizables sin logica de dominio | Reglas educativas |
| `lib/theme` | Colores y `ThemeData` Material 3 | Textos |
| `lib/utils` | Textos, formato, validaciones de entrada y retroalimentacion de interfaz | Widgets |

## 4. Modelos (`lib/models`)

| Archivo | Contenido |
|---------|-----------|
| `blast_design.dart` | `BlastDesign` (ejercicio completo, 16 campos, `copyWith`, `ejemploEducativo()`) y `MeshGeometry` |
| `geometry_result.dart` | Resultados geometricos derivados |
| `education_config.dart` | `EducationConfig` y `Rango` (coeficientes y rangos) |
| `risk_level.dart` | `RiskLevel` (bajo, medio, alto) y `nivelMasSevero` |
| `risk_assessment.dart` | `RiskFinding` y `RiskAssessment` |
| `validation.dart` | `ValidationIssue`, `IssueSeverity`, `ValidationResult` |
| `formula_explanation.dart` | `FormulaExplanation` y `FormulaVariable` |
| `explosive_concept.dart` | `EnergyCategory`, `WaterResistance`, `ExplosiveConceptProfile` |
| `rock_context.dart` | `RockHardness`, `WaterPresence` |
| `delay_sequence.dart` | `DelayPattern`, `DelayStep`, `DelayPlan` |
| `fragmentation_outlook.dart` | Lectura conceptual de fragmentacion y eficiencia |
| `quiz.dart` | `QuizTopic`, `QuizQuestion`, `QuizAnswer`, `QuizResult` |
| `tutor_topic.dart` | `TutorTopic`, `TutorAnswer` |
| `mesh_type.dart` | `MeshEnvironment` (subterranea, superficial, ambas), `MeshTypeCriterion`, `MeshTypeAssessment` |

Los modelos son inmutables (`final` + `const` donde es posible) y exponen
`copyWith`, lo que hace que el estado sea facil de razonar y de probar.

## 5. Calculadoras (`lib/calculators`)

| Archivo | Responsabilidad |
|---------|-----------------|
| `geometry_calculator.dart` | S/B, area por taladro, numero de taladros, volumenes, longitudes, relaciones adimensionales |
| `burden_calculator.dart` | Modelo configurable `B = k_B x D`, `S = k_S x B` y sus explicaciones (`FormulaExplanation`) |
| `risk_classifier.dart` | Siete criterios → `RiskAssessment` con puntaje 0–100 |
| `fragmentation_evaluator.dart` | Reglas cualitativas → `FragmentationOutlook` (indice 5–95) |
| `delay_sequencer.dart` | Orden conceptual de salida por patron y efectos asociados |
| `mesh_type_classifier.dart` | Cuatro rasgos geometricos → `MeshTypeAssessment`: malla subterranea, superficial o ambas |

Todas son clases `const`-construibles y sin estado: la misma entrada produce
siempre la misma salida, condicion necesaria para que las pruebas sean estables.

## 6. Servicios (`lib/services`)

| Archivo | Responsabilidad |
|---------|-----------------|
| `config_service.dart` | Carga `assets/config/education_config.json`, con valores por defecto si el archivo falta; permite ajustar coeficientes en caliente |
| `design_store.dart` | `DesignStore` + `DesignScope`: ejercicio activo compartido |
| `explosive_concept_service.dart` | Perfiles conceptuales de categorias energeticas |
| `quiz_service.dart` | Banco de 15 preguntas, calificacion y errores por tema |
| `tutor_service.dart` | `TutorEngine` (interfaz), `LocalRuleTutorEngine` (MVP) y `RemoteTutorEngine` (reservado) |

La interfaz `TutorEngine` es el punto de extension previsto para IA: una version
futura registra otra implementacion sin tocar la pantalla del tutor. El MVP no
realiza ninguna llamada de red y no contiene claves.

## 7. Pantallas (`lib/screens`)

`main_shell.dart` mantiene la barra inferior con cinco destinos (Inicio, Malla,
Simulacion, Evaluacion, Tutor) usando `IndexedStack` para conservar el estado de
cada modulo. Los modulos que no estan en la barra se abren como rutas desde la
pantalla de inicio.

`screen_scaffold.dart` expone `envolverModulo`, que permite que una misma
pantalla funcione **embebida** en la barra inferior o **como ruta** con su propio
`AppBar`, sin duplicar codigo (`embebida: true/false`).

## 8. Widgets (`lib/widgets`)

`AppCard` y `SectionTitle` (estructura), `SafetyBanner` (advertencia, en version
completa y compacta), `RiskChip`, `MetricBar` y `ResultRow` (indicadores),
`FormulaCard` (formula, variables, unidades, resultado, interpretacion y
limitaciones), `NumericField` y `EnumDropdown` (entrada validada),
`MeshPainter` / `MeshPreview` (`CustomPainter` de la malla) y `ModuleTile`.

La retroalimentacion tactil y sonora vive en `utils/ui_feedback.dart`
(`UiFeedback`), no en cada pantalla: los widgets compartidos (`ModuleTile`,
`EnumDropdown`, los deslizadores) ya la emiten, de modo que una pantalla nueva
la hereda sin escribir codigo. Usa solo `HapticFeedback` y `SystemSound` de
Flutter —sin paquetes, sin archivos de audio y sin permisos— y puede apagarse
por completo con `UiFeedback.habilitada`, que es lo que hacen las pruebas de
widget.

Varias decisiones buscan que el proyecto compile igual en distintas versiones
de Flutter, evitando APIs que cambiaron de forma con el tiempo:

| En lugar de | Se usa | Motivo |
|-------------|--------|--------|
| `ThemeData.cardTheme` | widget propio `AppCard` | `CardTheme` cambio de tipo |
| `ThemeData.appBarTheme` | `barraSuperior(context, subtitulo)` en `screen_scaffold.dart` | `AppBarTheme` cambio de tipo |
| `ThemeData.inputDecorationTheme` | `AppTheme.entrada(context, ...)` por campo | `InputDecorationTheme` cambio de tipo |
| `DropdownButtonFormField` | `InputDecorator` + `DropdownButton` | el parametro de valor cambio de nombre |
| `RadioListTile` | `InkWell` con icono de seleccion | la API de grupo de radios cambio |
| `useMaterial3: true` | nada (es el valor por defecto) | parametro obsoleto |
| `Color.withOpacity` | `Color.withValues(alpha: ...)` | reemplazo vigente |

## 9. Pruebas (`test/`)

| Archivo | Cubre |
|---------|-------|
| `geometry_calculator_test.dart` | S/B, area, numero de taladros, volumenes, longitudes, relaciones |
| `burden_calculator_test.dart` | Burden, espaciamiento, factor implicito y explicaciones |
| `validators_test.dart` | Validacion de campos y validacion global del ejercicio |
| `risk_classifier_test.dart` | Clasificacion del riesgo y niveles |
| `fragmentation_evaluator_test.dart` | Evaluacion conceptual de fragmentacion |
| `delay_sequencer_test.dart` | Los cuatro patrones de secuencia |
| `explosive_concept_test.dart` | Seleccion conceptual de categoria energetica |
| `quiz_service_test.dart` | Banco de preguntas y calificacion |
| `tutor_service_test.dart` | Reglas del tutor local y motor remoto reservado |
| `mesh_type_classifier_test.dart` | Reconocimiento de malla subterranea, superficial y ambas |
| `home_screen_widget_test.dart` | Prueba de widget de la pantalla principal |

Ejecucion: `flutter test`.

## 10. Decisiones tecnicas y por que

| Decision | Motivo |
|----------|--------|
| Cero dependencias externas | Un proyecto academico debe compilar dentro de dos anos sin resolver conflictos de versiones |
| Estado propio en vez de un paquete | El alcance del MVP no lo justifica y reduce la curva de lectura del codigo |
| Calculadoras puras separadas de la UI | Permite probar las reglas educativas sin levantar widgets |
| Reglas declaradas en `docs/formulas.md` | El estudiante puede auditar el criterio; una caja negra no es material didactico |
| Configuracion en JSON de assets | El docente ajusta coeficientes y rangos sin recompilar la logica |
| Firma de release apuntando a debug | Evita incluir claves o contrasenas en el repositorio |
| APK universal unico | Requisito de distribucion simple para el aula |

## 11. Limites arquitectonicos asumidos

- No hay persistencia: al cerrar la aplicacion el ejercicio vuelve al caso de
  referencia. Guardar y comparar ejercicios esta listado como mejora futura.
- No hay capa de red ni de autenticacion, por diseno.
- La configuracion se edita en el archivo de assets; no hay pantalla de
  administracion en el MVP.

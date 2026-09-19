# assets/images

Fragmenta Lab esta disenada para funcionar **sin imagenes externas**: toda la
interfaz se construye con Material 3, iconografia del framework y graficos
vectoriales dibujados en tiempo de ejecucion con `CustomPainter`
(`lib/widgets/mesh_painter.dart`).

Esta carpeta queda reservada para material grafico educativo futuro
(por ejemplo, esquemas de banco o diagramas de secuencia). Si se agregan
archivos aqui, debe declararse la carpeta en `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
```

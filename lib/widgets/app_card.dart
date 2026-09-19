import 'package:flutter/material.dart';

/// Tarjeta base de la aplicacion.
///
/// Se implementa como widget propio (en vez de un `CardTheme` global) para
/// mantener una apariencia estable entre versiones de Flutter y centralizar
/// el radio, el borde y el espaciado de todas las tarjetas.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    // El fondo y el borde se pintan con `Material` y no con la decoracion de
    // un `Container`: asi los hijos que dependen de un `Material` cercano
    // (`ListTile`, `ExpansionTile`, `InkWell`) dibujan su fondo y su tinta
    // sobre la tarjeta en lugar de quedar ocultos detras de ella.
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: color ?? esquema.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor ?? esquema.outlineVariant),
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Encabezado de seccion con icono opcional.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.texto, {super.key, this.icono, this.subtitulo});

  final String texto;
  final IconData? icono;
  final String? subtitulo;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icono != null)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 2),
              child: Icon(icono, size: 20, color: tema.colorScheme.primary),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  texto,
                  style: tema.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitulo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitulo!,
                      style: tema.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

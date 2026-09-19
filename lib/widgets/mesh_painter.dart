import 'package:flutter/material.dart';

import '../models/blast_design.dart';
import '../models/delay_sequence.dart';

/// Dibujo vectorial de la malla conceptual.
///
/// Representa la planta de la malla: cada taladro es un circulo cuyo diametro
/// visual escala con el diametro real, las filas se desplazan medio
/// espaciamiento cuando la malla es en tresbolillo y, opcionalmente, se
/// rotula el orden conceptual de salida.
///
/// Es una representacion **geometrica y basada en reglas**: no simula la
/// propagacion de energia ni la fragmentacion real.
class MeshPainter extends CustomPainter {
  MeshPainter({
    required this.design,
    required this.plan,
    required this.colorTaladro,
    required this.colorLinea,
    required this.colorCaraLibre,
    required this.colorTexto,
    this.mostrarOrden = true,
  });

  final BlastDesign design;
  final DelayPlan? plan;
  final Color colorTaladro;
  final Color colorLinea;
  final Color colorCaraLibre;
  final Color colorTexto;
  final bool mostrarOrden;

  @override
  void paint(Canvas canvas, Size size) {
    final int filas = design.filas <= 0 ? 1 : design.filas;
    final int columnas = design.taladrosPorFila <= 0
        ? 1
        : design.taladrosPorFila;
    final double burden = design.burdenM <= 0 ? 1 : design.burdenM;
    final double espaciamiento =
        design.espaciamientoM <= 0 ? 1 : design.espaciamientoM;
    final bool tresbolillo = design.geometria == MeshGeometry.tresbolillo;

    // Extension real de la malla en metros, con margen de media celda.
    final double anchoReal =
        (columnas - 1) * espaciamiento + (tresbolillo ? espaciamiento / 2 : 0);
    final double altoReal = (filas - 1) * burden;
    final double anchoTotal = anchoReal + espaciamiento;
    final double altoTotal = altoReal + burden * 1.4;

    const double margen = 26;
    final double escalaX = (size.width - margen * 2) / anchoTotal;
    final double escalaY = (size.height - margen * 2) / altoTotal;
    final double escala = escalaX < escalaY ? escalaX : escalaY;

    final double offsetX =
        (size.width - anchoTotal * escala) / 2 + (espaciamiento / 2) * escala;
    final double offsetY = margen;

    final Paint pincelLinea = Paint()
      ..color = colorLinea
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final Paint pincelTaladro = Paint()
      ..color = colorTaladro
      ..style = PaintingStyle.fill;

    final Paint pincelBorde = Paint()
      ..color = colorTaladro
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Radio visual: proporcional al diametro real pero con limites legibles.
    final double radioReal = (design.diametroMm / 1000.0) / 2;
    double radio = radioReal * escala * 6;
    if (radio < 4) {
      radio = 4;
    }
    if (radio > 14) {
      radio = 14;
    }

    // Cara libre en la parte inferior del dibujo.
    final double yCaraLibre = offsetY + (altoReal + burden * 0.7) * escala;
    final Paint pincelCara = Paint()
      ..color = colorCaraLibre
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(margen / 2, yCaraLibre),
      Offset(size.width - margen / 2, yCaraLibre),
      pincelCara,
    );
    _texto(
      canvas,
      'Cara libre',
      Offset(margen / 2 + 2, yCaraLibre + 4),
      colorCaraLibre,
      11,
    );

    // Taladros. La fila 0 se dibuja arriba (fila mas alejada de la cara libre
    // es la de mayor indice, coherente con la numeracion del secuenciador).
    for (int fila = 0; fila < filas; fila++) {
      final int filaDibujo = filas - 1 - fila;
      final double desplazamiento =
          (tresbolillo && filaDibujo.isOdd) ? espaciamiento / 2 : 0;

      for (int columna = 0; columna < columnas; columna++) {
        final double x =
            offsetX + (columna * espaciamiento + desplazamiento) * escala;
        final double y = offsetY + (fila * burden) * escala;
        final Offset centro = Offset(x, y);

        canvas.drawCircle(centro, radio, pincelTaladro);
        canvas.drawCircle(centro, radio + 2.5, pincelBorde);

        if (mostrarOrden && plan != null) {
          final DelayStep? paso = _buscarPaso(filaDibujo, columna);
          if (paso != null) {
            _texto(
              canvas,
              '${paso.orden}',
              Offset(x + radio + 4, y - 7),
              colorTexto,
              11,
            );
          }
        }
      }
    }

    // Cotas de burden y espaciamiento.
    if (columnas > 1) {
      final double y = offsetY - 12;
      final double x1 = offsetX;
      final double x2 = offsetX + espaciamiento * escala;
      canvas.drawLine(Offset(x1, y), Offset(x2, y), pincelLinea);
      _texto(
        canvas,
        'S = ${espaciamiento.toStringAsFixed(2)} m',
        Offset(x1 + 2, y - 15),
        colorTexto,
        11,
      );
    }
    if (filas > 1) {
      final double x = offsetX - radio - 16;
      final double y1 = offsetY;
      final double y2 = offsetY + burden * escala;
      canvas.drawLine(Offset(x, y1), Offset(x, y2), pincelLinea);
      _texto(
        canvas,
        'B = ${burden.toStringAsFixed(2)} m',
        Offset(x + 4, (y1 + y2) / 2 - 8),
        colorTexto,
        11,
      );
    }
  }

  DelayStep? _buscarPaso(int fila, int columna) {
    for (final DelayStep paso in plan!.pasos) {
      if (paso.fila == fila && paso.columna == columna) {
        return paso;
      }
    }
    return null;
  }

  void _texto(
    Canvas canvas,
    String texto,
    Offset posicion,
    Color color,
    double tamano,
  ) {
    final TextPainter pintor = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(
          color: color,
          fontSize: tamano,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    pintor.layout();
    pintor.paint(canvas, posicion);
  }

  @override
  bool shouldRepaint(covariant MeshPainter oldDelegate) {
    return oldDelegate.design != design ||
        oldDelegate.plan != plan ||
        oldDelegate.mostrarOrden != mostrarOrden ||
        oldDelegate.colorTaladro != colorTaladro;
  }
}

/// Contenedor con relacion de aspecto para el dibujo de la malla.
class MeshPreview extends StatelessWidget {
  const MeshPreview({
    super.key,
    required this.design,
    this.plan,
    this.mostrarOrden = true,
    this.altura = 240,
  });

  final BlastDesign design;
  final DelayPlan? plan;
  final bool mostrarOrden;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    return Container(
      height: altura,
      width: double.infinity,
      decoration: BoxDecoration(
        color: esquema.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: esquema.outlineVariant),
      ),
      child: CustomPaint(
        painter: MeshPainter(
          design: design,
          plan: plan,
          colorTaladro: esquema.primary,
          colorLinea: esquema.outline,
          colorCaraLibre: esquema.secondary,
          colorTexto: esquema.onSurfaceVariant,
          mostrarOrden: mostrarOrden,
        ),
      ),
    );
  }
}

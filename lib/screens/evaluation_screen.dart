import 'package:flutter/material.dart';

import '../models/quiz.dart';
import '../services/quiz_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/risk_indicator.dart';
import '../widgets/safety_banner.dart';
import 'screen_scaffold.dart';

/// Modulo 8: evaluacion.
///
/// Quince preguntas de seleccion multiple con puntaje, respuesta correcta,
/// explicacion tecnica y resumen de errores por tema.
class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key, this.embebida = false});

  final bool embebida;

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  static const QuizService _servicio = QuizService();

  late final List<QuizQuestion> _preguntas = _servicio.preguntas();
  final Map<String, int> _seleccion = <String, int>{};
  int _indice = 0;
  bool _verificada = false;
  bool _finalizada = false;

  QuizQuestion get _actual => _preguntas[_indice];

  void _seleccionar(int opcion) {
    if (_verificada) {
      return;
    }
    setState(() => _seleccion[_actual.id] = opcion);
  }

  void _verificar() {
    if (!_seleccion.containsKey(_actual.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una alternativa.')),
      );
      return;
    }
    setState(() => _verificada = true);
  }

  void _siguiente() {
    if (_indice + 1 >= _preguntas.length) {
      setState(() => _finalizada = true);
      return;
    }
    setState(() {
      _indice++;
      _verificada = false;
    });
  }

  void _reiniciar() {
    setState(() {
      _seleccion.clear();
      _indice = 0;
      _verificada = false;
      _finalizada = false;
    });
  }

  List<QuizAnswer> get _respuestas => _preguntas
      .map(
        (QuizQuestion p) => QuizAnswer(
          pregunta: p,
          indiceSeleccionado: _seleccion[p.id] ?? -1,
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final Widget cuerpo =
        _finalizada ? _construirResultado() : _construirPregunta();
    return envolverModulo(
      context: context,
      titulo: 'Evaluacion',
      cuerpo: cuerpo,
      embebida: widget.embebida,
    );
  }

  Widget _construirPregunta() {
    final ThemeData tema = Theme.of(context);
    final QuizQuestion p = _actual;
    final int? elegida = _seleccion[p.id];

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Pregunta ${_indice + 1} de ${_preguntas.length}',
              style: tema.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tema.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                p.tema.etiqueta,
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (_indice + 1) / _preguntas.length,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Text(
            p.enunciado,
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 6),
        ...List<Widget>.generate(p.opciones.length, (int i) {
          final bool seleccionada = elegida == i;
          final bool esCorrecta = i == p.indiceCorrecto;
          Color borde = tema.colorScheme.outlineVariant;
          Color fondo = Colors.transparent;
          IconData icono = Icons.radio_button_unchecked;

          if (_verificada) {
            if (esCorrecta) {
              borde = AppColors.riesgoBajo;
              fondo = AppColors.riesgoBajo.withValues(alpha: 0.08);
              icono = Icons.check_circle;
            } else if (seleccionada) {
              borde = AppColors.riesgoAlto;
              fondo = AppColors.riesgoAlto.withValues(alpha: 0.08);
              icono = Icons.cancel;
            }
          } else if (seleccionada) {
            borde = tema.colorScheme.primary;
            fondo = tema.colorScheme.primary.withValues(alpha: 0.07);
            icono = Icons.radio_button_checked;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _seleccionar(i),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: fondo,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borde),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(icono, size: 20, color: borde),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p.opciones[i],
                        style: tema.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (_verificada)
          AppCard(
            borderColor: elegida == p.indiceCorrecto
                ? AppColors.riesgoBajo
                : AppColors.riesgoAlto,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      elegida == p.indiceCorrecto
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: elegida == p.indiceCorrecto
                          ? AppColors.riesgoBajo
                          : AppColors.riesgoAlto,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      elegida == p.indiceCorrecto
                          ? 'Respuesta correcta'
                          : 'Respuesta incorrecta',
                      style: tema.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Correcta: ${p.respuestaCorrecta}',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explicacion tecnica',
                  style: tema.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tema.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(p.explicacion, style: tema.textTheme.bodySmall),
              ],
            ),
          ),
        const SizedBox(height: 10),
        if (!_verificada)
          FilledButton.icon(
            onPressed: _verificar,
            icon: const Icon(Icons.check),
            label: const Text('Verificar respuesta'),
          )
        else
          FilledButton.icon(
            onPressed: _siguiente,
            icon: Icon(
              _indice + 1 >= _preguntas.length
                  ? Icons.flag_outlined
                  : Icons.arrow_forward,
            ),
            label: Text(
              _indice + 1 >= _preguntas.length
                  ? 'Ver resultado final'
                  : 'Siguiente pregunta',
            ),
          ),
        const SizedBox(height: 10),
        const SafetyBanner(compacto: true),
      ],
    );
  }

  Widget _construirResultado() {
    final ThemeData tema = Theme.of(context);
    final List<QuizAnswer> respuestas = _respuestas;
    final QuizResult resultado = _servicio.calificar(respuestas);
    final Map<QuizTopic, int> errores = _servicio.erroresPorTema(respuestas);

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      children: <Widget>[
        const SectionTitle(
          'Resultado final',
          icono: Icons.emoji_events_outlined,
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${resultado.correctas}',
                    style: tema.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: tema.colorScheme.primary,
                    ),
                  ),
                  Text(
                    ' / ${resultado.total} correctas',
                    style: tema.textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              MetricBar(
                titulo: 'Puntaje obtenido',
                valor: resultado.porcentaje / 100,
                texto: '${Fmt.num2(resultado.porcentaje, 1)} %',
              ),
              const SizedBox(height: 12),
              ResultRow(
                etiqueta: 'Respuestas correctas',
                valor: '${resultado.correctas}',
              ),
              ResultRow(
                etiqueta: 'Errores cometidos',
                valor: '${resultado.incorrectas}',
              ),
              const SizedBox(height: 6),
              Text(resultado.valoracion, style: tema.textTheme.bodyMedium),
            ],
          ),
        ),
        if (errores.isNotEmpty) ...<Widget>[
          const SectionTitle(
            'Temas a repasar',
            icono: Icons.psychology_outlined,
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: errores.entries
                  .map(
                    (MapEntry<QuizTopic, int> e) => ResultRow(
                      etiqueta: e.key.etiqueta,
                      valor: '${e.value} error(es)',
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        const SectionTitle(
          'Revision de errores',
          icono: Icons.rule_folder_outlined,
        ),
        if (resultado.errores.isEmpty)
          AppCard(
            child: Text(
              'No hubo errores en esta evaluacion. Repite el cuestionario mas '
              'adelante para verificar que los conceptos se mantienen.',
              style: tema.textTheme.bodyMedium,
            ),
          )
        else
          ...resultado.errores.map(
            (QuizAnswer r) => AppCard(
              borderColor: AppColors.riesgoAlto.withValues(alpha: 0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    r.pregunta.enunciado,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    r.indiceSeleccionado >= 0
                        ? 'Tu respuesta: '
                            '${r.pregunta.opciones[r.indiceSeleccionado]}'
                        : 'Pregunta sin responder.',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: AppColors.riesgoAlto,
                    ),
                  ),
                  Text(
                    'Correcta: ${r.pregunta.respuestaCorrecta}',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: AppColors.riesgoBajo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    r.pregunta.explicacion,
                    style: tema.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _reiniciar,
          icon: const Icon(Icons.replay),
          label: const Text('Repetir evaluacion'),
        ),
        const SizedBox(height: 10),
        const SafetyBanner(compacto: true),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../calculators/geometry_calculator.dart';
import '../models/blast_design.dart';
import '../models/education_config.dart';
import '../models/geometry_result.dart';
import '../models/tutor_topic.dart';
import '../services/config_service.dart';
import '../services/design_store.dart';
import '../services/tutor_service.dart';
import '../theme/app_theme.dart';
import '../utils/ui_feedback.dart';
import '../widgets/app_card.dart';
import '../widgets/safety_banner.dart';
import 'screen_scaffold.dart';

/// Modulo 8: tutor local.
///
/// Funciona con una base de reglas cerrada, sin conexion, sin API externa y
/// sin claves. La interfaz `TutorEngine` deja preparada la sustitucion por un
/// motor con IA en una version futura sin modificar esta pantalla.
class TutorScreen extends StatefulWidget {
  const TutorScreen({super.key, this.embebida = false});

  final bool embebida;

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  static const LocalRuleTutorEngine _tutor = LocalRuleTutorEngine();
  final TextEditingController _consulta = TextEditingController();
  TutorAnswer? _respuesta;

  @override
  void dispose() {
    _consulta.dispose();
    super.dispose();
  }

  Future<void> _preguntar() async {
    final TutorAnswer respuesta = await _tutor.responder(_consulta.text);
    if (!mounted) {
      return;
    }
    setState(() => _respuesta = respuesta);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final BlastDesign d = DesignScope.of(context).design;
    final EducationConfig config = ConfigService.instance.config;
    const GeometryCalculator geometria = GeometryCalculator();
    final GeometryResult g = geometria.calcular(d);
    final List<String> diagnostico = _tutor.diagnosticar(d, g, config);

    final Widget cuerpo = ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      children: <Widget>[
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.support_agent_outlined,
                    color: tema.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _tutor.nombre,
                      style: tema.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tema.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Sin conexion',
                      style: tema.textTheme.bodySmall?.copyWith(
                        color: tema.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'El tutor del MVP responde con reglas escritas y revisadas por '
                'el equipo educativo. No genera texto, no consulta servicios '
                'externos y no almacena claves: si una consulta queda fuera de '
                'la base de reglas, lo dice en vez de improvisar.',
                style: tema.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SectionTitle(
          'Diagnostico del ejercicio activo',
          icono: Icons.troubleshoot_outlined,
          subtitulo: 'Se actualiza con los valores del modulo de malla.',
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: diagnostico
                .map(
                  (String nota) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: tema.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(nota, style: tema.textTheme.bodySmall),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SectionTitle('Consulta al tutor', icono: Icons.search),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _consulta,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _preguntar(),
                decoration: AppTheme.entrada(
                  context,
                  etiqueta: 'Escribe tu pregunta',
                  pista: 'Por ejemplo: que pasa si el burden es muy grande',
                  iconoInicial: const Icon(Icons.help_outline),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _preguntar,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Consultar'),
              ),
              if (_respuesta != null) ...<Widget>[
                const Divider(height: 24),
                Text(
                  _respuesta!.titulo,
                  style: tema.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(_respuesta!.contenido, style: tema.textTheme.bodyMedium),
                const SizedBox(height: 6),
                Text(
                  'Origen de la respuesta: ${_respuesta!.origen}',
                  style: tema.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SectionTitle(
          'Temas disponibles',
          icono: Icons.list_alt_outlined,
          subtitulo: 'Base de reglas completa del MVP.',
        ),
        ..._tutor.temas().map(
              (TutorTopic t) => AppCard(
                padding: EdgeInsets.zero,
                child: Theme(
                  data: tema.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    onExpansionChanged: (_) => UiFeedback.seleccion(),
                    tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                    childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    title: Text(
                      t.pregunta,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          t.respuesta,
                          style: tema.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Preparado para IA en una version futura',
                style: tema.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'La pantalla depende de la interfaz TutorEngine, no de una '
                'implementacion concreta. Una version posterior puede '
                'registrar un motor remoto sin tocar la interfaz de usuario, '
                'siempre que se resuelvan antes tres condiciones: validacion '
                'academica de las respuestas generadas, manejo de claves '
                'fuera del repositorio y una alternativa local cuando no haya '
                'conexion. El MVP no realiza ninguna llamada externa.',
                style: tema.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const SafetyBanner(compacto: true),
      ],
    );

    return envolverModulo(
      context: context,
      titulo: 'Tutor local',
      cuerpo: cuerpo,
      embebida: widget.embebida,
    );
  }
}

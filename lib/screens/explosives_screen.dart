import 'package:flutter/material.dart';

import '../models/blast_design.dart';
import '../models/explosive_concept.dart';
import '../models/rock_context.dart';
import '../services/design_store.dart';
import '../services/explosive_concept_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';
import '../widgets/app_card.dart';
import '../widgets/numeric_field.dart';
import '../widgets/risk_indicator.dart';
import '../widgets/safety_banner.dart';
import 'screen_scaffold.dart';

/// Modulo 5: modulo conceptual de explosivos.
///
/// LIMITE EXPLICITO DEL PRODUCTO: este modulo trabaja unicamente con
/// categorias abstractas. No contiene marcas, composiciones, cantidades,
/// densidades de producto ni procedimientos de carga, conexion o iniciacion,
/// porque nada de eso es necesario para el objetivo educativo: entender el
/// efecto **relativo** de la energia disponible sobre un diseno geometrico.
class ExplosivesScreen extends StatelessWidget {
  const ExplosivesScreen({super.key, this.embebida = false});

  final bool embebida;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final DesignStore store = DesignScope.of(context);
    final BlastDesign d = store.design;
    const ExplosiveConceptService servicio = ExplosiveConceptService();

    final ExplosiveConceptProfile perfil = servicio.perfil(
      energia: d.energia,
      resistenciaAgua: d.resistenciaAgua,
      dureza: d.dureza,
      agua: d.agua,
    );

    final Widget cuerpo = ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.riesgoAlto.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.riesgoAlto.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.block_outlined, color: AppColors.riesgoAlto),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Alcance de este modulo',
                      style: tema.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.riesgoAlto,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.sinExplosivosOperativos,
                      style: tema.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionTitle(
          'Categorias conceptuales',
          icono: Icons.category_outlined,
          subtitulo: 'Selecciona categorias abstractas, no productos.',
        ),
        AppCard(
          child: Column(
            children: <Widget>[
              EnumDropdown<EnergyCategory>(
                etiqueta: 'Categoria de energia relativa',
                valor: d.energia,
                opciones: EnergyCategory.values,
                textoDe: (EnergyCategory e) => e.etiqueta,
                ayuda: 'Indice adimensional respecto a la energia media.',
                onChanged: (EnergyCategory e) =>
                    store.actualizar(d.copyWith(energia: e)),
              ),
              EnumDropdown<WaterResistance>(
                etiqueta: 'Categoria de resistencia al agua',
                valor: d.resistenciaAgua,
                opciones: WaterResistance.values,
                textoDe: (WaterResistance w) => w.etiqueta,
                onChanged: (WaterResistance w) =>
                    store.actualizar(d.copyWith(resistenciaAgua: w)),
              ),
              EnumDropdown<RockHardness>(
                etiqueta: 'Dureza conceptual de la roca',
                valor: d.dureza,
                opciones: RockHardness.values,
                textoDe: (RockHardness r) => r.etiqueta,
                onChanged: (RockHardness r) =>
                    store.actualizar(d.copyWith(dureza: r)),
              ),
              EnumDropdown<WaterPresence>(
                etiqueta: 'Presencia de agua en el taladro',
                valor: d.agua,
                opciones: WaterPresence.values,
                textoDe: (WaterPresence w) => w.etiqueta,
                onChanged: (WaterPresence w) =>
                    store.actualizar(d.copyWith(agua: w)),
              ),
            ],
          ),
        ),
        const SectionTitle(
          'Efectos conceptuales',
          icono: Icons.insights_outlined,
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ResultRow(
                etiqueta: 'Energia relativa',
                valor: d.energia.etiqueta,
                destacado: true,
                nota: perfil.energiaRelativa,
              ),
              ResultRow(
                etiqueta: 'Fragmentacion esperada',
                valor: '-',
                nota: perfil.fragmentacionEsperada,
              ),
              ResultRow(
                etiqueta: 'Desplazamiento esperado',
                valor: '-',
                nota: perfil.desplazamientoEsperado,
              ),
              ResultRow(
                etiqueta: 'Sensibilidad al agua',
                valor: d.resistenciaAgua.etiqueta,
                nota: perfil.sensibilidadAlAgua,
              ),
              ResultRow(
                etiqueta: 'Adecuacion conceptual al tipo de roca',
                valor: d.dureza.etiqueta,
                nota: perfil.adecuacionConceptual,
              ),
              const Divider(),
              Text(
                'Observacion educativa',
                style: tema.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tema.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                perfil.observacionEducativa,
                style: tema.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SectionTitle(
          'Comparacion de categorias',
          icono: Icons.compare_arrows,
        ),
        AppCard(
          child: Column(
            children: EnergyCategory.values
                .map(
                  (EnergyCategory e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MetricBar(
                      titulo: e.etiqueta,
                      valor: e.indiceRelativo / 1.6,
                      texto: 'Indice ${e.indiceRelativo.toStringAsFixed(1)}',
                      color: e == d.energia
                          ? tema.colorScheme.primary
                          : AppColors.rocaClara,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SafetyBanner(),
      ],
    );

    return envolverModulo(
      context: context,
      titulo: 'Explosivos (conceptual)',
      cuerpo: cuerpo,
      embebida: embebida,
    );
  }
}

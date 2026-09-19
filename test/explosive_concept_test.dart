import 'package:flutter_test/flutter_test.dart';
import 'package:fragmenta_lab/models/explosive_concept.dart';
import 'package:fragmenta_lab/models/rock_context.dart';
import 'package:fragmenta_lab/services/explosive_concept_service.dart';

void main() {
  const ExplosiveConceptService servicio = ExplosiveConceptService();

  ExplosiveConceptProfile perfil({
    EnergyCategory energia = EnergyCategory.media,
    WaterResistance resistencia = WaterResistance.buena,
    RockHardness dureza = RockHardness.media,
    WaterPresence agua = WaterPresence.seco,
  }) {
    return servicio.perfil(
      energia: energia,
      resistenciaAgua: resistencia,
      dureza: dureza,
      agua: agua,
    );
  }

  group('Seleccion conceptual de categoria energetica', () {
    test('expone exactamente las tres categorias abstractas', () {
      expect(servicio.categorias.length, 3);
      expect(servicio.categorias, contains(EnergyCategory.baja));
      expect(servicio.categorias, contains(EnergyCategory.media));
      expect(servicio.categorias, contains(EnergyCategory.alta));
    });

    test('los indices relativos son crecientes y adimensionales', () {
      expect(
        EnergyCategory.baja.indiceRelativo,
        lessThan(EnergyCategory.media.indiceRelativo),
      );
      expect(
        EnergyCategory.media.indiceRelativo,
        lessThan(EnergyCategory.alta.indiceRelativo),
      );
      expect(EnergyCategory.media.indiceRelativo, 1.0);
    });

    test('la dureza conceptual ordena la dificultad de fragmentar', () {
      expect(RockHardness.blanda.indice, lessThan(RockHardness.media.indice));
      expect(RockHardness.dura.indice, lessThan(RockHardness.muyDura.indice));
    });

    test('energia baja frente a roca muy dura se declara insuficiente', () {
      final ExplosiveConceptProfile p = perfil(
        energia: EnergyCategory.baja,
        dureza: RockHardness.muyDura,
      );
      expect(p.fragmentacionEsperada, contains('insuficiente'));
    });

    test('energia equilibrada con la roca se declara coherente', () {
      final ExplosiveConceptProfile p = perfil();
      expect(p.fragmentacionEsperada, contains('equilibrada'));
      expect(p.adecuacionConceptual, contains('coherente'));
    });

    test('energia alta en roca blanda se declara excedida', () {
      final ExplosiveConceptProfile p = perfil(
        energia: EnergyCategory.alta,
        dureza: RockHardness.blanda,
      );
      expect(p.fragmentacionEsperada, contains('excedida'));
      expect(p.desplazamientoEsperado, contains('alto'));
    });

    test('agua con baja resistencia se marca como combinacion critica', () {
      final ExplosiveConceptProfile p = perfil(
        resistencia: WaterResistance.baja,
        agua: WaterPresence.saturado,
      );
      expect(p.sensibilidadAlAgua, contains('critica'));
      expect(p.adecuacionConceptual, contains('agua'));
    });

    test('sin agua declarada la resistencia al agua no condiciona', () {
      final ExplosiveConceptProfile p = perfil(
        resistencia: WaterResistance.baja,
      );
      expect(p.sensibilidadAlAgua, contains('no condiciona'));
    });

    test('todas las combinaciones devuelven texto completo', () {
      for (final EnergyCategory e in EnergyCategory.values) {
        for (final WaterResistance w in WaterResistance.values) {
          for (final RockHardness r in RockHardness.values) {
            for (final WaterPresence a in WaterPresence.values) {
              final ExplosiveConceptProfile p = servicio.perfil(
                energia: e,
                resistenciaAgua: w,
                dureza: r,
                agua: a,
              );
              expect(p.energiaRelativa.isNotEmpty, isTrue);
              expect(p.fragmentacionEsperada.isNotEmpty, isTrue);
              expect(p.desplazamientoEsperado.isNotEmpty, isTrue);
              expect(p.sensibilidadAlAgua.isNotEmpty, isTrue);
              expect(p.adecuacionConceptual.isNotEmpty, isTrue);
              expect(p.observacionEducativa.isNotEmpty, isTrue);
            }
          }
        }
      }
    });
  });
}

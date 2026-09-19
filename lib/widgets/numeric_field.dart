import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Campo numerico con validacion, unidad y texto de ayuda.
class NumericField extends StatelessWidget {
  const NumericField({
    super.key,
    required this.controller,
    required this.etiqueta,
    required this.unidad,
    this.ayuda,
    this.validator,
    this.soloEnteros = false,
    this.onChanged,
    this.icono,
  });

  final TextEditingController controller;
  final String etiqueta;
  final String unidad;
  final String? ayuda;
  final String? Function(String?)? validator;
  final bool soloEnteros;
  final ValueChanged<String>? onChanged;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: soloEnteros
            ? TextInputType.number
            : const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(
            soloEnteros ? RegExp(r'[0-9]') : RegExp(r'[0-9.,]'),
          ),
        ],
        textInputAction: TextInputAction.next,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: AppTheme.entrada(
          context,
          etiqueta: etiqueta,
          sufijo: unidad,
          ayuda: ayuda,
          iconoInicial: icono == null ? null : Icon(icono, size: 20),
        ),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}

/// Selector desplegable generico para enumeraciones.
class EnumDropdown<T> extends StatelessWidget {
  const EnumDropdown({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.opciones,
    required this.textoDe,
    required this.onChanged,
    this.ayuda,
  });

  final String etiqueta;
  final T valor;
  final List<T> opciones;
  final String Function(T) textoDe;
  final ValueChanged<T> onChanged;
  final String? ayuda;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        // Se usa InputDecorator + DropdownButton en lugar de
        // DropdownButtonFormField porque el nombre del parametro de valor de
        // ese widget cambio entre versiones de Flutter; esta combinacion es
        // estable y produce el mismo resultado visual en Material 3.
        decoration: AppTheme.entrada(
          context,
          etiqueta: etiqueta,
          ayuda: ayuda,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: valor,
            isExpanded: true,
            isDense: true,
            borderRadius: BorderRadius.circular(12),
            items: opciones
                .map(
                  (T o) => DropdownMenuItem<T>(
                    value: o,
                    child: Text(textoDe(o), overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (T? nuevo) {
              if (nuevo != null) {
                onChanged(nuevo);
              }
            },
          ),
        ),
      ),
    );
  }
}

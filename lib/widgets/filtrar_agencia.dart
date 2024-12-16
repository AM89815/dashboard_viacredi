// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class FiltrarAgencia extends StatefulWidget {
  final List<String> agencias;
  final String selectedAgencia;
  final ValueChanged<String> onChanged;

  const FiltrarAgencia({
    super.key,
    required this.agencias,
    required this.selectedAgencia,
    required this.onChanged,
  });

  @override
  _FiltrarAgenciaState createState() => _FiltrarAgenciaState();
}

class _FiltrarAgenciaState extends State<FiltrarAgencia> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: widget.selectedAgencia,
      icon: const Icon(Icons.filter_list),
      onChanged: (String? newValue) {
        if (newValue != null) {
          widget.onChanged(newValue);
        }
      },
      items: widget.agencias.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value == 'Todas as agências' ? value : 'Agência $value'),
        );
      }).toList(),
    );
  }
}

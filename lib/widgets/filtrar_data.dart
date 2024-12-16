// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class FiltrarData extends StatefulWidget {
  final Function(DateTime startDate, DateTime endDate) onDateRangeSelected;

  const FiltrarData({required this.onDateRangeSelected, super.key});

  @override
  _FiltrarDataState createState() => _FiltrarDataState();
}

class _FiltrarDataState extends State<FiltrarData> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked.start != _startDate && picked.end != _endDate) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      widget.onDateRangeSelected(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.date_range),
      onPressed: () => _selectDateRange(context),
    );
  }
}

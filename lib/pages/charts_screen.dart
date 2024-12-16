// ignore_for_file: library_private_types_in_public_api, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_viacredi/widgets/filtrar_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dashboard_viacredi/widgets/filtrar_agencia.dart';
import 'package:dashboard_viacredi/widgets/navigator_bar.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  String _selectedAgencia = 'Todas as agências';
  DateTime? _startDate;
  DateTime? _endDate;

  List<String> agencias = ['Todas as agências', '1', '2', '3'];

  Stream<QuerySnapshot> _getFeedbackStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('feedback')
        .orderBy('timestamp', descending: false);
    return query.snapshots();
  }

  List<FlSpot> _getSpots(List<DocumentSnapshot> docs, String key) {
    List<FlSpot> spots = [];
    for (int i = 0; i < docs.length; i++) {
      var data = docs[i].data() as Map<String, dynamic>;
      List<dynamic> estrelas = data['estrelas'] ?? [0, 0, 0];
      double value = 0;
      if (key == 'nota') {
        value = (data[key] ?? 0).toDouble();
      } else if (key == 'estrelas_ambiente') {
        value = (estrelas[0] ?? 0).toDouble();
      } else if (key == 'estrelas_atendimento') {
        value = (estrelas[1] ?? 0).toDouble();
      } else if (key == 'estrelas_tempo_espera') {
        value = (estrelas[2] ?? 0).toDouble();
      }
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    List<DocumentSnapshot> _filterByDate(List<DocumentSnapshot> docs) {
      if (_startDate == null || _endDate == null) return docs;
      return docs.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        var timestamp = (data['timestamp'] as Timestamp).toDate();
        return timestamp
                .isAfter(_startDate!.subtract(const Duration(days: 1))) &&
            timestamp.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráficos'),
        actions: [
          FiltrarAgencia(
            agencias: agencias,
            selectedAgencia: _selectedAgencia,
            onChanged: (String newValue) {
              setState(() {
                _selectedAgencia = newValue;
              });
            },
          ),
          FiltrarData(onDateRangeSelected: (start, end) {
            setState(() {
              _startDate = start;
              _endDate = end;
            });
          }),
        ],
      ),
      drawer: const NavigatorBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getFeedbackStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar dados'));
          }

          List<DocumentSnapshot<Object?>> feedbackDocs = snapshot.data!.docs;

          if (_selectedAgencia != 'Todas as agências') {
            feedbackDocs = feedbackDocs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return data['agencia'].toString() == _selectedAgencia;
            }).toList();
          }

          feedbackDocs = _filterByDate(feedbackDocs);

          if (feedbackDocs.isEmpty) {
            return const Center(child: Text('Nenhum feedback encontrado'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                children: [
                  const Text(
                    'Notas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: screenHeight * 0.3,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: _getSpots(feedbackDocs, 'nota'),
                            color: Colors.blue,
                            barWidth: 2,
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                return value.toInt() == value
                                    ? Text(value.toInt().toString())
                                    : Container();
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                return value.toInt() == value
                                    ? Text(value.toInt().toString())
                                    : Container();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Estrelas do Ambiente',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: screenHeight * 0.3,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: _getSpots(feedbackDocs, 'estrelas_ambiente'),
                            color: Colors.green,
                            barWidth: 2,
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                return value.toInt() == value
                                    ? Text(value.toInt().toString())
                                    : Container();
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                return value.toInt() == value
                                    ? Text(value.toInt().toString())
                                    : Container();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Estrelas do Atendimento',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: screenHeight * 0.3,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots:
                                _getSpots(feedbackDocs, 'estrelas_atendimento'),
                            color: Colors.red,
                            barWidth: 2,
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                return value.toInt() == value
                                    ? Text(value.toInt().toString())
                                    : Container();
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                return value.toInt() == value
                                    ? Text(value.toInt().toString())
                                    : Container();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Estrelas do Tempo de Espera',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: screenHeight * 0.3,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: _getSpots(
                                feedbackDocs, 'estrelas_tempo_espera'),
                            color: Colors.purple,
                            barWidth: 2,
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                return value.toInt() == value
                                    ? Text(value.toInt().toString())
                                    : Container();
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                return value.toInt() == value
                                    ? Text(value.toInt().toString())
                                    : Container();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

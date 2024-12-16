// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dashboard_viacredi/widgets/filtrar_agencia.dart';
import 'package:dashboard_viacredi/widgets/navigator_bar.dart';
import 'package:dashboard_viacredi/widgets/filtrar_data.dart';

class PieChartScreen extends StatefulWidget {
  const PieChartScreen({super.key});

  @override
  _PieChartScreenState createState() => _PieChartScreenState();
}

class _PieChartScreenState extends State<PieChartScreen> {
  String _selectedAgencia = 'Todas as agências';
  DateTime? _startDate;
  DateTime? _endDate;
  final ValueNotifier<int> _touchedIndexNotifier = ValueNotifier<int>(-1);

  List<String> agencias = ['Todas as agências', '1', '2', '3'];

  Stream<QuerySnapshot> _getFeedbackStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('feedback').orderBy('timestamp', descending: false);
    return query.snapshots();
  }

  List<PieChartSectionData> _getSections(List<DocumentSnapshot> docs, int touchedIndex) {
    List<int> votes = List.filled(11, 0);
    for (var doc in docs) {
      var data = doc.data() as Map<String, dynamic>;
      var nota = data['nota'] as int? ?? 0;
      if (nota >= 0 && nota <= 10) {
        votes[nota]++;
      }
    }

    int totalVotes = votes.reduce((a, b) => a + b);
    if (totalVotes == 0) return [];

    return List.generate(11, (i) {
      double percentage = (votes[i] / totalVotes) * 100;
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;
      final fontSize = isTouched ? 18.0 : 14.0;

      return PieChartSectionData(
        color: Colors.primaries[i % Colors.primaries.length],
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
  }

  List<DocumentSnapshot> _filterByDate(List<DocumentSnapshot> docs) {
    if (_startDate == null || _endDate == null) return docs;
    return docs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;
      var timestamp = (data['timestamp'] as Timestamp).toDate();
      return timestamp.isAfter(_startDate!.subtract(const Duration(days: 1))) && timestamp.isBefore(_endDate!.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico interativo'),
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

          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: _touchedIndexNotifier,
                      builder: (context, touchedIndex, child) {
                        return SizedBox(
                          height: screenHeight * 0.5,
                          child: PieChart(
                            PieChartData(
                              sections: _getSections(feedbackDocs, touchedIndex),
                              centerSpaceRadius: 70,
                              sectionsSpace: 0,
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                    _touchedIndexNotifier.value = -1;
                                    return;
                                  }
                                  _touchedIndexNotifier.value = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    ValueListenableBuilder<int>(
                      valueListenable: _touchedIndexNotifier,
                      builder: (context, touchedIndex, child) {
                        if (touchedIndex == -1) {
                          return const Center(
                            child: Text(
                              'Interaja com o gráfico\npara ver uma legenda.',
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else {
                          final sectionData = _getSections(feedbackDocs, touchedIndex)[touchedIndex];
                          return Center(
                            child: Column(
                              children: [
                                Text(
                                  'Nota $touchedIndex',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '${sectionData.value.toStringAsFixed(1)}%',
                                  style: const TextStyle(fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 10,
                      children: List.generate(11, (i) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: Colors.primaries[i % Colors.primaries.length],
                            ),
                            const SizedBox(width: 4),
                            Text('Nota $i'),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

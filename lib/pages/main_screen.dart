import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_viacredi/widgets/feedback_card.dart';
import 'package:dashboard_viacredi/widgets/filtrar_agencia.dart';
import 'package:dashboard_viacredi/widgets/navigator_bar.dart';
import 'package:dashboard_viacredi/widgets/filtrar_data.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _sortParameter = 'timestamp';
  bool _descending = true;
  String _selectedAgencia = 'Todas as agências';
  DateTime? _startDate;
  DateTime? _endDate;

  List<String> agencias = ['Todas as agências', '1', '2', '3'];

  Stream<QuerySnapshot> _getFeedbackStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('feedback')
        .orderBy(_sortParameter, descending: _descending);
    return query.snapshots();
  }

  List<DocumentSnapshot> _filterByDate(List<DocumentSnapshot> docs) {
    if (_startDate == null || _endDate == null) return docs;
    return docs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;
      var timestamp = (data['timestamp'] as Timestamp).toDate();
      return timestamp.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
          timestamp.isBefore(_endDate!.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliações'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                if (value == 'Notas mais altas' || value == 'Notas mais baixas') {
                  _sortParameter = 'nota';
                  _descending = value == 'Notas mais altas';
                } else {
                  _sortParameter = 'timestamp';
                  _descending = value == 'Mais recentes';
                }
              });
            },
            itemBuilder: (BuildContext context) {
              return {'Mais recentes', 'Mais antigas', 'Notas mais altas', 'Notas mais baixas'}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
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

          return ListView.builder(
            itemCount: feedbackDocs.length,
            itemBuilder: (context, index) {
              var feedbackData =
                  feedbackDocs[index].data() as Map<String, dynamic>;
              return FeedbackCard(feedbackData: feedbackData);
            },
          );
        },
      ),
    );
  }
}

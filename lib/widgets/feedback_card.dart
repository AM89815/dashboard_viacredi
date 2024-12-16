import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FeedbackCard extends StatelessWidget {
  final Map<String, dynamic> feedbackData;

  const FeedbackCard({super.key, required this.feedbackData});

  Widget starRating(int rating) {
    return Row(
      children: List.generate(rating, (index) {
        return const Icon(
          FontAwesomeIcons.solidStar,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    var timestamp = feedbackData['timestamp'] as Timestamp?;
    var formattedDate = timestamp != null
        ? DateFormat('dd/MM/yyyy - HH:mm').format(timestamp.toDate())
        : 'Data indisponível';

    List<dynamic> estrelas = feedbackData['estrelas'] ?? [0, 0, 0];

    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(
          'Nota: ${feedbackData['nota'] ?? 'N/A'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Ambiente: '),
                starRating(estrelas[0]),
                Text(
                  ' (${estrelas[0]}/5)',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Atendimento: '),
                starRating(estrelas[1]),
                Text(
                  ' (${estrelas[1]}/5)',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Tempo de espera: '),
                starRating(estrelas[2]),
                Text(
                  ' (${estrelas[2]}/5)',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
            Row(
              children: [
                const Text('CPF: '),
                Text(feedbackData['cpf'] ?? 'N/A'),
              ],
            ),
            Row(
              children: [
                const Text('Comentário: '),
                Expanded(child: Text(feedbackData['comentario'] ?? 'N/A')),
              ],
            ),
            Row(
              children: [
                const Text('Agência: '),
                Text(feedbackData['agencia']?.toString() ?? 'N/A'),
              ],
            ),
            Row(
              children: [
                const Text('Data: '),
                Text(formattedDate),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

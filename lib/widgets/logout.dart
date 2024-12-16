// ignore_for_file: use_build_context_synchronously, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/auth');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao sair. Tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sair'),
      content: const Text('Tem certeza que deseja sair?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Não'),
        ),
        TextButton(
          onPressed: () {
            _signOut(context);
          },
          child: const Text('Sim'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }
}

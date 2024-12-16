// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _errorMessage = '';
  bool _obscureText = true;

  Future<void> _signIn() async {
    setState(() {
      _errorMessage = ''; // reset
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Credenciais inválidas.';
      });
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      _errorMessage = ''; // reset
    });

    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, insira seu e-mail para redefinir a senha.';
      });
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link de redefinição de senha enviado! Verifique seu e-mail.')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Por favor, insira seu e-mail para redefinir a senha.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.10,
            vertical: screenHeight * 0.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.25,
                child: Image.asset(
                  "assets/images/images-dash/logo.png",
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              SizedBox(height: screenHeight * 0.05),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(2, 119, 189, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50.0,
                    vertical: 20.0,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _signIn,
                child: const Text('Login'),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextButton(
                onPressed: _resetPassword,
                child: const Text('Esqueceu a senha?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

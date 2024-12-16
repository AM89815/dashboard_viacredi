// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 150.0, end: 200.0).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    ));

    _controller!.forward().then((_) {
      _controller!.reverse();
    });

    Future.delayed(const Duration(seconds: 2), () {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _animation!,
          builder: (context, child) {
            return SizedBox(
              width: _animation!.value,
              height: _animation!.value,
              child: child,
            );
          },
          child: Image.asset("assets/images/images-dash/favicon.jpg"),
        ),
      ),
    );
  }
}
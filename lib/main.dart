import 'package:dashboard_viacredi/firebase_options.dart';
import 'package:dashboard_viacredi/pages/auth_screen.dart';
import 'package:dashboard_viacredi/pages/charts_screen.dart';
import 'package:dashboard_viacredi/pages/main_screen.dart';
import 'package:dashboard_viacredi/pages/pie_chart_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Color.fromRGBO(2, 119, 189, 1),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/main': (context) => const MainScreen(),
        '/charts': (context) => const ChartScreen(),
        '/piechart': (context) => const PieChartScreen(),
        '/auth': (context) => const AuthScreen(),
      },
    );
  }
}

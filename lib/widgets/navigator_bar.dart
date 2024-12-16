import 'package:dashboard_viacredi/widgets/logout.dart';
import 'package:flutter/material.dart';

class NavigatorBar extends StatelessWidget {
  const NavigatorBar({super.key});

  @override
  Widget build(BuildContext context) {
    //final mediaQuery = MediaQuery.of(context);
    //final screenHeight = mediaQuery.size.height;
    //final screenWidth = mediaQuery.size.width;

    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(2, 119, 189, 1),
            ),
            child: Center(
              child: SizedBox(
                height: 200,
                child: Image.asset('assets/images/images-dash/logo_white.png'),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.comment),
                  title: const Text('Avaliações'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/main');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.show_chart),
                  title: const Text('Estatísticas'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/charts');
                  },
                ),
                                ListTile(
                  leading: const Icon(Icons.pie_chart),
                  title: const Text('Gráfico interativo'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/piechart');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Sair'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const LogoutDialog();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

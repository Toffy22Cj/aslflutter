import 'package:flutter/material.dart';
import 'login_page.dart';
import '../widgets/comic_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondoPrueba2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Logo central
          Positioned(
            top: screenHeight * 0.2,
            left: screenWidth * 0.5 - 100,
            child: Image.asset(
              'assets/images/logo_final.png',
              width: 200,
            ),
          ),

          // Personajes
          Positioned(
            bottom: -60,
            left: 50,
            child: Image.asset(
              'assets/images/11.png',
              height: 280,
            ),
          ),

          Positioned(
            bottom: -60,
            left: 150,
            child: Image.asset(
              'assets/images/12.png',
              height: 260,
            ),
          ),

          Positioned(
            bottom: -70,
            left: 250,
            child: Image.asset(
              'assets/images/13.png',
              height: 260,
            ),
          ),

          Positioned(
            bottom: 0,
            right: 40,
            child: Image.asset(
              'assets/images/14.png',
              height: 300,
            ),
          ),

          // Botón ENTRAR
          Positioned(
            bottom: 40,
            left: screenWidth * 0.5 - 80,
            child: ComicButton(
              text: '¡ENTRAR!',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aprendizaje Sin Límites',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        fontFamily: 'Bangers',
      ),
      home: const WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
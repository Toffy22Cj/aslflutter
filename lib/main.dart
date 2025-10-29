import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ INICIALIZAR CONFIGURACIÓN CON MANEJO DE ERRORES
    await AppConfig.initialize();
    print('✅ Configuración inicializada correctamente');
  } catch (e) {
    print('❌ Error inicializando configuración: $e');
  }

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
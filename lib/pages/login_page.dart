import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/user.dart';
import '../widgets/comic_button.dart';
import '../widgets/comic_text_field.dart';
import '../widgets/loader.dart';
import 'main_page.dart';
import '../config/app_config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('🔄 [LOGIN] Página de login inicializada');
  }

  void _showError(String message) {
    print('❌ [LOGIN UI] Mostrando error: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Próximamente',
          style: TextStyle(
            fontFamily: 'Bangers',
            fontSize: 24,
          ),
        ),
        content: Text(
          'La funcionalidad de $feature estará disponible en la próxima versión.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    print('🔐 [LOGIN] === INICIANDO LOGIN ===');
    print('📧 [LOGIN] Email: $email');
    print('🔑 [LOGIN] Password: ${'*' * password.length}');
    print('🌐 [LOGIN] URL Spring: ${AppConfig.springBaseUrl}');
    print('🌐 [LOGIN] URL Node: ${AppConfig.nodeBaseUrl}');

    if (email.isEmpty || password.isEmpty) {
      print('❌ [LOGIN] Campos vacíos - Email: $email, Password vacío: ${password.isEmpty}');
      _showError('Por favor, completa todos los campos.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ PASO 1: VERIFICAR CONEXIÓN PRIMERO
      print('🔍 [LOGIN] Verificando conexión con servidores...');
      final conexionResultados = await AuthService.verificarConexionServidores();
      print('📊 [LOGIN] Resultados conexión: $conexionResultados');

      if (!conexionResultados['spring']!) {
        print('❌ [LOGIN] Spring Boot no está accesible');
        throw Exception('No se puede conectar al servidor de autenticación. Verifica que Spring Boot esté corriendo.');
      }

      // ✅ PASO 2: LOGIN EN SPRING BOOT
      print('🚀 [LOGIN] Paso 1: Login en Spring Boot...');
      final loginRequest = LoginRequest(
        email: email,
        password: password,
      );

      print('📤 [LOGIN] Enviando request: ${loginRequest.toJson()}');

      final loginResponse = await AuthService.loginSpringBoot(loginRequest);

      print('✅ [LOGIN] Login Spring Boot exitoso');
      print('📋 [LOGIN] Respuesta: ID: ${loginResponse.id}, Nombre: ${loginResponse.nombre}');

      // ✅ PASO 3: SINCRONIZAR CON MONGODB
      print('🔄 [LOGIN] Paso 2: Sincronizando con MongoDB...');
      final syncResponse = await AuthService.syncUser(
        loginResponse.id!,
        loginResponse.nombre!,
        loginResponse.email!,
      );

      print('✅ [LOGIN] Sincronización MongoDB exitosa');
      print('📋 [LOGIN] MongoId: ${syncResponse['mongoId']}');

      // ✅ PASO 4: GUARDAR DATOS DEL USUARIO
      final user = User(
        mongoId: syncResponse['mongoId'] ?? 'spring_${loginResponse.id}',
        springId: loginResponse.id!,
        nombre: loginResponse.nombre!,
        email: loginResponse.email!,
        tipo: loginResponse.tipo!,
        token: loginResponse.token!,
      );

      print('👤 [LOGIN] Usuario creado: ${user.nombre} (${user.email})');

      // ✅ PASO 5: CONFIGURAR TOKEN
      AuthService.setAuthToken(loginResponse.token!);
      print('🔑 [LOGIN] Token configurado para futuras peticiones');

      // ✅ PASO 6: NAVEGAR A PÁGINA PRINCIPAL
      print('🎯 [LOGIN] Navegando a MainPage...');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(user: user),
        ),
      );

      print('✅ [LOGIN] Login completado exitosamente');

    } catch (e) {
      print('❌ [LOGIN] ERROR DURANTE LOGIN: $e');
      print('🔍 [LOGIN] Tipo de error: ${e.runtimeType}');
      print('🔍 [LOGIN] Stack trace: ${e.toString()}');

      String errorMessage = 'Error durante el login';

      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Timeout: El servidor no responde. Verifica la conexión.';
        print('⏰ [LOGIN] Timeout detectado - Posible problema de red');
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Error de conexión: No se puede alcanzar el servidor.';
        print('🌐 [LOGIN] SocketException - Problema de red/URL');
      } else if (e.toString().contains('401')) {
        errorMessage = 'Credenciales incorrectas.';
        print('🔐 [LOGIN] Error 401 - Credenciales inválidas');
      } else if (e.toString().contains('403')) {
        errorMessage = 'Cuenta no activada. Revisa tu correo.';
        print('🚫 [LOGIN] Error 403 - Cuenta no activada');
      } else if (e.toString().contains('500')) {
        errorMessage = 'Error interno del servidor.';
        print('💥 [LOGIN] Error 500 - Problema del servidor');
      }

      _showError('$errorMessage\nDetalle: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('🔚 [LOGIN] Proceso de login finalizado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/FONDO1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Personajes
          Positioned(
            bottom: -40,
            left: 20,
            child: Image.asset(
              'assets/images/11.png',
              height: 200,
            ),
          ),

          Positioned(
            bottom: -20,
            right: 20,
            child: Image.asset(
              'assets/images/14.png',
              height: 200,
            ),
          ),

          // Contenido principal
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 400,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 6),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(10, 10),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Logo de fondo semitransparente
                    Opacity(
                      opacity: 0.2,
                      child: Center(
                        child: Image.asset(
                          'assets/images/10.png',
                          width: 300,
                          height: 300,
                        ),
                      ),
                    ),

                    // Contenido del formulario
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontFamily: 'Bangers',
                            fontSize: 32,
                            color: Color(0xFF8B1E1E),
                            shadows: [
                              Shadow(
                                offset: Offset(3, 3),
                                color: Colors.black,
                                blurRadius: 0,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        ComicTextField(
                          hintText: 'Email',
                          controller: _emailController,
                          icon: Icons.person,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        ComicTextField(
                          hintText: 'Contraseña',
                          controller: _passwordController,
                          obscureText: true,
                          icon: Icons.lock,
                        ),

                        const SizedBox(height: 20),

                        _isLoading
                            ? const Loader(show: true, message: 'Iniciando sesión...')
                            : ComicButton(
                          text: 'Iniciar sesión',
                          onPressed: _login,
                        ),

                        const SizedBox(height: 20),

                        Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                _showComingSoon('registro');
                              },
                              child: const Text(
                                '¿No tienes cuenta? Regístrate aquí',
                                style: TextStyle(
                                  fontFamily: 'Bangers',
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                _showComingSoon('recuperación de contraseña');
                              },
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  fontFamily: 'Bangers',
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botón volver
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 40),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
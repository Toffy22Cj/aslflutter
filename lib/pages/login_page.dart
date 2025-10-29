import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/user.dart';
import '../widgets/comic_button.dart';
import '../widgets/comic_text_field.dart';
import '../widgets/loader.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showError(String message) {
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
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Por favor, completa todos los campos.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Paso 1: Login en Spring Boot
      final loginResponse = await AuthService.loginSpringBoot(
        LoginRequest(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );

      // Paso 2: Sincronizar usuario en MongoDB
      final syncResponse = await AuthService.syncUser(
        loginResponse.id,
        loginResponse.nombre,
        loginResponse.email,
      );

      // Guardar datos del usuario
      final user = User(
        mongoId: syncResponse['mongoId'] ?? 'spring_${loginResponse.id}',
        springId: loginResponse.id,
        nombre: loginResponse.nombre,
        email: loginResponse.email,
        tipo: loginResponse.tipo,
        token: loginResponse.token,
      );

      // Configurar token para futuras peticiones
      AuthService.setAuthToken(loginResponse.token);

      // Navegar a la página principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(user: user),
        ),
      );

    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
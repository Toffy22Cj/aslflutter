import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/login_request.dart';
import '../models/login_response.dart';
import 'api_service.dart';
import 'progreso_service.dart';

class AuthService {
  // ✅ GETTERS CORREGIDOS - AHORA SÍNCRONOS
  static String get springBaseUrl => ApiService.springBaseUrl;
  static String get nodeBaseUrl => ApiService.nodeBaseUrl;

  // Variable para almacenar el mongoId
  static String? _mongoUserId;

  // Getter para obtener el mongoId
  static String? get mongoUserId => _mongoUserId;

  // Paso 1: Login en Spring Boot
  static Future<LoginResponse> loginSpringBoot(LoginRequest request) async {
    try {
      print('🔐 [FLUTTER] Iniciando login...');
      ApiService.printConfig();

      final currentSpringUrl = springBaseUrl;
      print('📧 [FLUTTER] Email: ${request.email}');
      print('🌐 [FLUTTER] URL: $currentSpringUrl/login');

      final response = await ApiService.post(
        '$currentSpringUrl/login',
        request.toJson(),
      );

      print('📊 [FLUTTER] Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final loginResponse = LoginResponse.fromJson(jsonResponse);

        print('✅ [FLUTTER] Login exitoso - ID: ${loginResponse.id}');

        // 🔄 SINCRONIZAR CON MONGODB INMEDIATAMENTE
        await _syncUserWithMongoDB(
            loginResponse.id!,
            loginResponse.nombre!,
            loginResponse.email!
        );

        return loginResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Credenciales incorrectas');
      } else if (response.statusCode == 403) {
        throw Exception('Cuenta no activada. Revisa tu correo.');
      } else {
        throw Exception('Error del servidor: ${response.statusCode} - ${response.body}');
      }
    } on SocketException {
      final currentSpringUrl = springBaseUrl;
      throw Exception('No se pudo conectar al servidor. Verifica que Spring Boot esté corriendo en $currentSpringUrl');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // ✅ SINCRONIZAR USUARIO CON MONGODB - CORREGIDO
  static Future<Map<String, dynamic>> _syncUserWithMongoDB(int springId, String nombre, String email) async {
    try {
      print('🔄 [AUTH] Sincronizando usuario con MongoDB...');
      final currentNodeUrl = nodeBaseUrl;
      print('🌐 [AUTH] URL: $currentNodeUrl/sync-user');

      final response = await ApiService.post(
        '$currentNodeUrl/sync-user',
        {
          'springId': springId,
          'nombre': nombre,
          'email': email,
        },
      );

      Map<String, dynamic> result = {};

      if (response.statusCode == 200) {
        final syncData = json.decode(response.body);
        _mongoUserId = syncData['mongoId'];

        print('✅ [AUTH] Usuario sincronizado con MongoDB');
        print('📋 [AUTH] MongoId: $_mongoUserId');
        print('📋 [AUTH] SpringId: $springId');

        // ✅ CONFIGURAR EL MONGO ID EN EL SERVICIO DE PROGRESO
        ProgresoService.setMongoUserId(_mongoUserId!);

        result = {
          'success': true,
          'mongoId': _mongoUserId,
          'springId': springId,
          'email': email
        };
      } else {
        print('⚠️ [AUTH] Error en sincronización: ${response.statusCode}');
        print('📋 [AUTH] Respuesta del servidor: ${response.body}');

        throw Exception('No se pudo sincronizar con MongoDB: ${response.statusCode}');
      }

      return result;
    } catch (e) {
      print('❌ [AUTH] Error sincronizando con MongoDB: $e');
      throw Exception('Error de sincronización: $e');
    }
  }

  // Paso 2: Sincronizar usuario en MongoDB (método público)
  static Future<Map<String, dynamic>> syncUser(int springId, String nombre, String email) async {
    return await _syncUserWithMongoDB(springId, nombre, email);
  }

  // Método para configurar token
  static void setAuthToken(String token) {
    ApiService.setAuthToken(token);
  }

  // Método para obtener el mongoId
  static String? getMongoUserId() {
    return _mongoUserId;
  }

  // Método para verificar si hay un mongoId configurado
  static bool hasMongoUserId() {
    return _mongoUserId != null && _mongoUserId!.isNotEmpty;
  }

  // ✅ LOGOUT COMPLETO - CORREGIDO
  static Future<void> logout() async {
    print('🚪 [AUTH] Cerrando sesión...');

    try {
      final currentSpringUrl = springBaseUrl;
      await ApiService.post('$currentSpringUrl/logout', {});
    } catch (e) {
      print('⚠️ [AUTH] Error al hacer logout en servidor: $e');
    } finally {
      // Limpiar datos locales
      _mongoUserId = null;
      ProgresoService.clearMongoUserId();
      ApiService.removeAuthToken();
      print('✅ [AUTH] Sesión cerrada completamente');
    }
  }

  // ✅ VERIFICAR TOKEN - CORREGIDO
  static Future<bool> verifyToken() async {
    try {
      final currentSpringUrl = springBaseUrl;
      final response = await ApiService.get('$currentSpringUrl/verify');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ✅ MÉTODO PARA VERIFICAR CONEXIÓN CON LOS SERVIDORES - CORREGIDO
  static Future<Map<String, bool>> verificarConexionServidores() async {
    print('🔍 [AUTH] Verificando conexión con servidores...');

    final Map<String, bool> resultados = {
      'spring': false,
      'node': false
    };

    try {
      // Verificar Spring Boot
      print('🔍 [AUTH] Probando conexión con Spring Boot...');
      final springUrl = springBaseUrl;
      final springResponse = await http.get(
        Uri.parse('$springUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      resultados['spring'] = springResponse.statusCode == 200;
      // ✅ CORRECCIÓN: Usar el valor directamente en lugar del operador ternario con mapa
      final springStatus = resultados['spring'] ?? false;
      print('🌐 [AUTH] Spring Boot: ${springStatus ? "✅ CONECTADO" : "❌ DESCONECTADO"}');

      // Verificar Node.js
      print('🔍 [AUTH] Probando conexión con Node.js...');
      final nodeUrl = nodeBaseUrl;
      final nodeResponse = await http.get(
        Uri.parse('$nodeUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      resultados['node'] = nodeResponse.statusCode == 200;
      // ✅ CORRECCIÓN: Usar el valor directamente en lugar del operador ternario con mapa
      final nodeStatus = resultados['node'] ?? false;
      print('🌐 [AUTH] Node.js: ${nodeStatus ? "✅ CONECTADO" : "❌ DESCONECTADO"}');

    } catch (e) {
      print('❌ [AUTH] Error verificando conexión: $e');
    }

    print('📊 [AUTH] Resultados conexión: $resultados');
    return resultados;
  }

  // ✅ MÉTODO PARA OBTENER INFORMACIÓN DE CONFIGURACIÓN ACTUAL
  static Map<String, String> getConfiguracionActual() {
    return {
      'springUrl': springBaseUrl,
      'nodeUrl': nodeBaseUrl,
      'mongoUserId': _mongoUserId ?? 'No configurado',
      'tokenPresente': ApiService.headers['Authorization'] != null ? 'Sí' : 'No',
    };
  }

  // ✅ MÉTODO PARA IMPRIMIR CONFIGURACIÓN ACTUAL
  static void imprimirConfiguracion() {
    final config = getConfiguracionActual();
    print('\n🎯 [AUTH CONFIG] =========================');
    print('🌐 Spring URL: ${config['springUrl']}');
    print('🌐 Node URL: ${config['nodeUrl']}');
    print('👤 Mongo UserId: ${config['mongoUserId']}');
    print('🔑 Token: ${config['tokenPresente']}');
    print('🎯 [AUTH CONFIG] =========================\n');
  }

  // ✅ MÉTODO PARA REINICIALIZAR CONFIGURACIÓN (útil si cambia la red)
  static Future<void> reinicializarConfiguracion() async {
    print('🔄 [AUTH] Reinicializando configuración...');

    // Guardar datos actuales
    final token = ApiService.headers['Authorization'];
    final mongoId = _mongoUserId;

    // Limpiar
    _mongoUserId = null;
    ApiService.removeAuthToken();

    print('✅ [AUTH] Configuración reinicializada');
    print('💡 [AUTH] Token anterior: ${token != null ? "PRESENTE" : "AUSENTE"}');
    print('💡 [AUTH] MongoId anterior: $mongoId');

    // El usuario deberá hacer login nuevamente
  }

  // ✅ MÉTODO ALTERNATIVO MÁS SEGURO PARA VERIFICAR CONEXIÓN
  static Future<void> verificarConexionSimple() async {
    print('🔍 [AUTH] Verificando conexión simple con servidores...');

    try {
      // Verificar Spring Boot
      final springUrl = springBaseUrl;
      print('🌐 [AUTH] Probando Spring Boot en: $springUrl/health');

      final springResponse = await http.get(
        Uri.parse('$springUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (springResponse.statusCode == 200) {
        print('✅ [AUTH] Spring Boot: CONECTADO');
      } else {
        print('❌ [AUTH] Spring Boot: DESCONECTADO (Status: ${springResponse.statusCode})');
      }

      // Verificar Node.js
      final nodeUrl = nodeBaseUrl;
      print('🌐 [AUTH] Probando Node.js en: $nodeUrl/health');

      final nodeResponse = await http.get(
        Uri.parse('$nodeUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (nodeResponse.statusCode == 200) {
        print('✅ [AUTH] Node.js: CONECTADO');
      } else {
        print('❌ [AUTH] Node.js: DESCONECTADO (Status: ${nodeResponse.statusCode})');
      }

    } catch (e) {
      print('❌ [AUTH] Error en verificación de conexión: $e');
    }
  }
}
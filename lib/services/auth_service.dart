import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/login_request.dart';
import '../models/login_response.dart';
import 'api_service.dart';
import 'progreso_service.dart'; // 👈 IMPORTAR PROGRESO SERVICE

class AuthService {
  // ✅ USA LAS URLs FLEXIBLES DE ApiService
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
      ApiService.printConfig(); // ✅ MUESTRA LA CONFIGURACIÓN
      print('📧 [FLUTTER] Email: ${request.email}');
      print('🌐 [FLUTTER] URL: $springBaseUrl/login');

      final response = await ApiService.post(
        '$springBaseUrl/login',
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
      throw Exception('No se pudo conectar al servidor. Verifica que Spring Boot esté corriendo en $springBaseUrl');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // En auth_service.dart - REEMPLAZAR EL MÉTODO _syncUserWithMongoDB
  static Future<Map<String, dynamic>> _syncUserWithMongoDB(int springId, String nombre, String email) async {
    try {
      print('🔄 [AUTH] Sincronizando usuario con MongoDB...');
      print('🌐 [AUTH] URL: $nodeBaseUrl/sync-user');

      final response = await ApiService.post(
        '$nodeBaseUrl/sync-user',
        {
          'springId': springId,
          'nombre': nombre,
          'email': email,
        },
      );

      Map<String, dynamic> result = {};

      if (response.statusCode == 200) {
        final syncData = json.decode(response.body);
        _mongoUserId = syncData['mongoId']; // ✅ ObjectId válido de MongoDB

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

        // ❌ NO USAR spring_1 - Mejor lanzar excepción
        throw Exception('No se pudo sincronizar con MongoDB: ${response.statusCode}');
      }

      return result;
    } catch (e) {
      print('❌ [AUTH] Error sincronizando con MongoDB: $e');
      throw Exception('Error de sincronización: $e');
    }
  }

  // Paso 2: Sincronizar usuario en MongoDB (método público por si acaso)
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

  // Método para limpiar los datos de sesión
  static void clearSession() {
    _mongoUserId = null;
    ProgresoService.clearMongoUserId();
    // Si ApiService tiene un método clearAuthToken, úsalo, si no, omite esta línea
    // ApiService.clearAuthToken();
  }
}
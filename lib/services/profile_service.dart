import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'api_service.dart';

class ProfileService {
  // ✅ GETTER CORREGIDO - AHORA SÍNCRONO
  static String get baseUrl => ApiService.springBaseUrl;

  // Obtener perfil del usuario
  static Future<UserProfile> getUserProfile(int userId) async {
    try {
      print('🔍 [PROFILE] Obteniendo perfil para usuario: $userId');
      final currentBaseUrl = baseUrl; // ✅ CORREGIDO: Sin await

      final response = await ApiService.get('$currentBaseUrl/user/$userId');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('✅ [PROFILE] Perfil obtenido: $jsonResponse');
        return UserProfile.fromJson(jsonResponse);
      } else if (response.statusCode == 403) {
        print('❌ [PROFILE] 403 Forbidden - Revisar @PreAuthorize en Spring Boot');
        throw Exception('Acceso denegado. Posible problema de autorización.');
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [PROFILE] Error completo: $e');
      rethrow;
    }
  }

  // Actualizar perfil del usuario
  static Future<Map<String, dynamic>> updateUserProfile(
      int userId, UserProfile profile) async {
    try {
      print('🔍 [PROFILE] Actualizando perfil para usuario: $userId');
      print('📦 [PROFILE] Datos a enviar: ${profile.toJson()}');

      final currentBaseUrl = baseUrl; // ✅ CORREGIDO: Sin await

      final response = await ApiService.put(
        '$currentBaseUrl/user/$userId',
        profile.toJson(),
      );

      print('📊 [PROFILE] Respuesta - Status: ${response.statusCode}');
      print('📄 [PROFILE] Respuesta - Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ [PROFILE] Perfil actualizado exitosamente');
        return result;
      } else if (response.statusCode == 403) {
        throw Exception('403 Forbidden: No tienes permisos para actualizar este perfil');
      } else {
        throw Exception('Error HTTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [PROFILE] Error actualizando perfil: $e');
      throw e;
    }
  }

  // Obtener trastornos del usuario
  static Future<List<String>> getUserTrastornos(int userId) async {
    try {
      final currentBaseUrl = baseUrl; // ✅ CORREGIDO: Sin await
      final response = await ApiService.get('$currentBaseUrl/user/$userId/trastornos');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final trastornos = List<String>.from(jsonResponse['trastornos'] ?? []);
        return trastornos;
      } else {
        throw Exception('Error al obtener trastornos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [PROFILE] Error obteniendo trastornos: $e');
      return [];
    }
  }

  // ✅ CAMBIAR CONTRASEÑA - CORREGIDO
  static Future<bool> changePassword(int userId, String currentPassword, String newPassword) async {
    try {
      final currentBaseUrl = baseUrl; // ✅ CORREGIDO: Sin await
      final response = await ApiService.put(
        '$currentBaseUrl/user/$userId/password',
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ [PROFILE] Error cambiando contraseña: $e');
      return false;
    }
  }

  // ✅ SUBIR FOTO DE PERFIL - CORREGIDO
  static Future<String> uploadProfileImage(int userId, String imagePath) async {
    try {
      final currentBaseUrl = baseUrl; // ✅ CORREGIDO: Sin await
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('$currentBaseUrl/user/$userId/upload-image')
      );

      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      request.headers['Authorization'] = ApiService.headers['Authorization'] ?? '';

      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(respStr);
        return jsonResponse['imageUrl'];
      } else {
        throw Exception('Error subiendo imagen: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [PROFILE] Error subiendo imagen: $e');
      throw e;
    }
  }

  // ✅ NUEVO: ELIMINAR FOTO DE PERFIL
  static Future<bool> deleteProfileImage(int userId) async {
    try {
      final currentBaseUrl = baseUrl;
      final response = await ApiService.delete('$currentBaseUrl/user/$userId/profile-image');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ [PROFILE] Error eliminando imagen: $e');
      return false;
    }
  }

  // ✅ NUEVO: VERIFICAR SI EL EMAIL ESTÁ DISPONIBLE
  static Future<bool> checkEmailAvailable(String email, {int? currentUserId}) async {
    try {
      final currentBaseUrl = baseUrl;
      final response = await ApiService.post(
        '$currentBaseUrl/user/check-email',
        {
          'email': email,
          'currentUserId': currentUserId,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['available'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ [PROFILE] Error verificando email: $e');
      return false;
    }
  }

  // ✅ NUEVO: OBTENER ESTADÍSTICAS DEL USUARIO
  static Future<Map<String, dynamic>> getUserStatistics(int userId) async {
    try {
      final currentBaseUrl = baseUrl;
      final response = await ApiService.get('$currentBaseUrl/user/$userId/statistics');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Error al obtener estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [PROFILE] Error obteniendo estadísticas: $e');
      return {};
    }
  }

  // ✅ NUEVO: ACTUALIZAR PREFERENCIAS DEL USUARIO
  static Future<bool> updateUserPreferences(int userId, Map<String, dynamic> preferences) async {
    try {
      final currentBaseUrl = baseUrl;
      final response = await ApiService.put(
        '$currentBaseUrl/user/$userId/preferences',
        preferences,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ [PROFILE] Error actualizando preferencias: $e');
      return false;
    }
  }

  // ✅ NUEVO: OBTENER HISTORIAL DE ACTIVIDAD
  static Future<List<dynamic>> getUserActivityHistory(int userId) async {
    try {
      final currentBaseUrl = baseUrl;
      final response = await ApiService.get('$currentBaseUrl/user/$userId/activity');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return List<dynamic>.from(jsonResponse['activities'] ?? []);
      } else {
        throw Exception('Error al obtener historial: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [PROFILE] Error obteniendo historial: $e');
      return [];
    }
  }

  // ✅ NUEVO: VERIFICAR CONEXIÓN CON EL SERVICIO
  static Future<bool> verifyConnection() async {
    try {
      final currentBaseUrl = baseUrl;
      final response = await http.get(
        Uri.parse('$currentBaseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ [PROFILE] Error de conexión: $e');
      return false;
    }
  }

  // ✅ NUEVO: IMPRIMIR CONFIGURACIÓN ACTUAL
  static void printCurrentConfig() {
    print('\n🎯 [PROFILE CONFIG] =========================');
    print('🌐 Base URL: $baseUrl');
    print('🔑 Token presente: ${ApiService.headers['Authorization'] != null ? "Sí" : "No"}');
    print('🎯 [PROFILE CONFIG] =========================\n');
  }
}
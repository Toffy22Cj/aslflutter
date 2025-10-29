import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'api_service.dart';

class ProfileService {
  //static const String baseUrl = 'http://localhost:8080/api/auth';
  static const String baseUrl = 'http://10.0.2.2:8080/api/auth';
  // Obtener perfil del usuario
  static Future<UserProfile> getUserProfile(int userId) async {
    try {
      print('🔍 [PROFILE] Obteniendo perfil para usuario: $userId');

      final response = await ApiService.get('$baseUrl/user/$userId');

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

      final response = await ApiService.put(
        '$baseUrl/user/$userId',
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
      final response = await ApiService.get('$baseUrl/user/$userId/trastornos');

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
}
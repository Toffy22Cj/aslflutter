import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import '../config/app_config.dart';
class ApiService {
  // ✅ DETECCIÓN AUTOMÁTICA DEL ENTORNO
  static String get springBaseUrl => AppConfig.springBaseUrl;
  static String get nodeBaseUrl => AppConfig.nodeBaseUrl;

  // ✅ MÉTODO PARA DEBUG - MOSTRAR CONFIGURACIÓN ACTUAL
  static void printConfig() {
    print('🔧 [API SERVICE] Configuración detectada:');
    print('🔧 [API SERVICE] Spring URL: $springBaseUrl');
    print('🔧 [API SERVICE] Node URL: $nodeBaseUrl');
    print('🔧 [API SERVICE] Platform: ${Platform.operatingSystem}');
    print('🔧 [API SERVICE] Headers: $headers');
  }

  static Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  static void setAuthToken(String token) {
    headers['Authorization'] = 'Bearer $token';
    print('🔑 [FLUTTER] Token configurado para: $springBaseUrl');
    print('🔑 [FLUTTER] Token: ${token.substring(0, 20)}...');
  }

  static void removeAuthToken() {
    headers.remove('Authorization');
    print('🔑 [FLUTTER] Token removido');
  }

  static Future<http.Response> post(String url, Map<String, dynamic> body) async {
    try {
      print('🌐 [FLUTTER] Enviando POST a: $url');
      print('🔑 [FLUTTER] Token: ${headers['Authorization'] != null ? "PRESENTE" : "AUSENTE"}');
      if (headers['Authorization'] != null) {
        print('🔑 [FLUTTER] Token value: ${headers['Authorization']!.substring(0, 30)}...');
      }
      print('📦 [FLUTTER] Body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      print('✅ [FLUTTER] Respuesta - Status: ${response.statusCode}');
      print('📨 [FLUTTER] Body: ${response.body}');

      return response;
    } catch (e) {
      print('❌ [FLUTTER] Error en POST: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<http.Response> put(String url, Map<String, dynamic> body) async {
    try {
      print('🌐 [FLUTTER] Enviando PUT a: $url');
      print('🔑 [FLUTTER] Token: ${headers['Authorization'] != null ? "PRESENTE" : "AUSENTE"}');
      if (headers['Authorization'] != null) {
        print('🔑 [FLUTTER] Token value: ${headers['Authorization']!.substring(0, 30)}...');
      }
      print('📦 [FLUTTER] Body: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      print('✅ [FLUTTER] Respuesta - Status: ${response.statusCode}');
      print('📨 [FLUTTER] Body: ${response.body}');

      return response;
    } catch (e) {
      print('❌ [FLUTTER] Error en PUT: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<http.Response> get(String url) async {
    try {
      print('🌐 [FLUTTER] Enviando GET a: $url');
      print('🔑 [FLUTTER] Token: ${headers['Authorization'] != null ? "PRESENTE" : "AUSENTE"}');
      if (headers['Authorization'] != null) {
        print('🔑 [FLUTTER] Token value: ${headers['Authorization']!.substring(0, 30)}...');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('✅ [FLUTTER] Respuesta - Status: ${response.statusCode}');
      print('📨 [FLUTTER] Body: ${response.body}');
      return response;
    } catch (e) {
      print('❌ [FLUTTER] Error en GET: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
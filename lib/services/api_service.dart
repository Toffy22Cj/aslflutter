import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import '../config/app_config.dart';

class ApiService {
  // ✅ HEADERS COMPARTIDOS
  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // ✅ URLS BASE SÍNCRONAS - CORREGIDO
  static String get springBaseUrl => AppConfig.springBaseUrl;
  static String get nodeBaseUrl => AppConfig.nodeBaseUrl;

  // ✅ MÉTODO PARA DEBUG - MOSTRAR CONFIGURACIÓN ACTUAL
  static void printConfig() {
    print('🔧 [API SERVICE] Configuración detectada:');
    print('🔧 [API SERVICE] Spring URL: $springBaseUrl');
    print('🔧 [API SERVICE] Node URL: $nodeBaseUrl');
    print('🔧 [API SERVICE] Platform: ${Platform.operatingSystem}');
    print('🔧 [API SERVICE] Headers: $_headers');
  }

  // ✅ CONFIGURAR TOKEN DE AUTENTICACIÓN
  static void setAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
    print('🔑 [FLUTTER] Token configurado');
    print('🔑 [FLUTTER] Token: ${token.substring(0, 20)}...');
  }

  // ✅ REMOVER TOKEN
  static void removeAuthToken() {
    _headers.remove('Authorization');
    print('🔑 [FLUTTER] Token removido');
  }

  // ✅ OBTENER HEADERS ACTUALES
  static Map<String, String> get headers => Map.from(_headers);

  // ✅ MÉTODO POST MEJORADO
  static Future<http.Response> post(String url, Map<String, dynamic> body) async {
    try {
      print('🌐 [FLUTTER] Enviando POST a: $url');
      print('🔑 [FLUTTER] Token: ${_headers['Authorization'] != null ? "PRESENTE" : "AUSENTE"}');
      if (_headers['Authorization'] != null) {
        print('🔑 [FLUTTER] Token value: ${_headers['Authorization']!.substring(0, 30)}...');
      }
      print('📦 [FLUTTER] Body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      _logResponse('POST', response);
      return response;
    } catch (e) {
      print('❌ [FLUTTER] Error en POST: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // ✅ MÉTODO GET MEJORADO
  static Future<http.Response> get(String url) async {
    try {
      print('🌐 [FLUTTER] Enviando GET a: $url');
      print('🔑 [FLUTTER] Token: ${_headers['Authorization'] != null ? "PRESENTE" : "AUSENTE"}');
      if (_headers['Authorization'] != null) {
        print('🔑 [FLUTTER] Token value: ${_headers['Authorization']!.substring(0, 30)}...');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      _logResponse('GET', response);
      return response;
    } catch (e) {
      print('❌ [FLUTTER] Error en GET: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // ✅ MÉTODO PUT MEJORADO
  static Future<http.Response> put(String url, Map<String, dynamic> body) async {
    try {
      print('🌐 [FLUTTER] Enviando PUT a: $url');
      print('🔑 [FLUTTER] Token: ${_headers['Authorization'] != null ? "PRESENTE" : "AUSENTE"}');
      if (_headers['Authorization'] != null) {
        print('🔑 [FLUTTER] Token value: ${_headers['Authorization']!.substring(0, 30)}...');
      }
      print('📦 [FLUTTER] Body: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      _logResponse('PUT', response);
      return response;
    } catch (e) {
      print('❌ [FLUTTER] Error en PUT: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // ✅ MÉTODO DELETE
  static Future<http.Response> delete(String url) async {
    try {
      print('🌐 [FLUTTER] Enviando DELETE a: $url');
      print('🔑 [FLUTTER] Token: ${_headers['Authorization'] != null ? "PRESENTE" : "AUSENTE"}');

      final response = await http.delete(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      _logResponse('DELETE', response);
      return response;
    } catch (e) {
      print('❌ [FLUTTER] Error en DELETE: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // ✅ MÉTODO PARA LOGGING DE RESPUESTAS
  static void _logResponse(String method, http.Response response) {
    print('✅ [FLUTTER] $method Respuesta - Status: ${response.statusCode}');

    if (response.statusCode >= 400) {
      print('❌ [FLUTTER] Error ${response.statusCode}: ${response.body}');
    } else {
      print('📨 [FLUTTER] Body: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');
    }
  }

  // ✅ LIMPIAR TODA LA CONFIGURACIÓN
  static void clear() {
    _headers.clear();
    _headers['Content-Type'] = 'application/json';
    print('🔧 [API SERVICE] Configuración limpiada');
  }
}
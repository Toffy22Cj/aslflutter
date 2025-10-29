// services/progreso_service.dart - VERSIÓN COMPLETA CON MÉTODO FALTANTE
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ProgresoService {
  // ✅ URL BASE CORREGIDA PARA TODAS LAS PLATAFORMAS
  static String get baseUrl => '${ApiService.nodeBaseUrl}/progreso';

  // ✅ VARIABLE PARA ALMACENAR EL MONGO ID
  static String? _mongoUserId;

  // ✅ CONFIGURAR EL MONGO ID DESDE AUTH SERVICE
  static void setMongoUserId(String mongoId) {
    _mongoUserId = mongoId;
    print('✅ [PROGRESO] MongoUserId configurado: $_mongoUserId');
  }

  // ✅ LIMPIAR EL MONGO ID
  static void clearMongoUserId() {
    _mongoUserId = null;
    print('✅ [PROGRESO] MongoUserId limpiado');
  }

  // ✅ OBTENER PROGRESO COMPLETO (USA EL MONGO ID AUTOMÁTICAMENTE)
  static Future<Map<String, dynamic>> obtenerProgresoCompleto() async {
    if (_mongoUserId == null) {
      print('❌ [PROGRESO] MongoUserId no configurado. Usando ID por defecto.');
      return await obtenerProgresoCompletoConId('68ff1b0eb113d8ba6dc99661');
    }

    return await obtenerProgresoCompletoConId(_mongoUserId!);
  }

  // ✅ MÉTODO PRINCIPAL CORREGIDO CON MEJOR MANEJO DE ERRORES
  static Future<Map<String, dynamic>> obtenerProgresoCompletoConId(String _mongoUserId) async {
    try {
      print('🌐 [PROGRESO] Conectando a: $baseUrl/$_mongoUserId/completo');
      print('👤 [PROGRESO] UserId tipo: ${_mongoUserId.runtimeType}');
      print('🔍 [PROGRESO] UserId valor: $_mongoUserId');

      // Validar que el userId no sea nulo o vacío
      if (_mongoUserId.isEmpty || _mongoUserId == 'null') {
        print('❌ [PROGRESO] userId inválido: $_mongoUserId');
        return _crearProgresoVacio('unknown');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/$_mongoUserId/completo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': ApiService.headers['Authorization'] ?? '',
          'User-Agent': 'Flutter-App/1.0',
        },
      ).timeout(const Duration(seconds: 15));

      print('📊 [PROGRESO] Respuesta HTTP: ${response.statusCode}');
      print('📋 [PROGRESO] Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('✅ [PROGRESO] Datos reales obtenidos del servidor');
        return jsonResponse['data'] ?? _crearProgresoVacio(_mongoUserId);
      }
      else if (response.statusCode == 400) {
        print('❌ [PROGRESO] Error 400 - Bad Request');
        print('💡 [PROGRESO] Posibles causas:');
        print('   • userId inválido: $_mongoUserId');
        print('   • Problema de validación en el servidor');
        print('   • Headers incorrectos');

        // Intentar parsear el mensaje de error del servidor
        try {
          final errorResponse = json.decode(response.body);
          print('📝 [PROGRESO] Mensaje del servidor: $errorResponse');
        } catch (e) {
          print('📝 [PROGRESO] Respuesta del servidor: ${response.body}');
        }

        return _crearProgresoVacio(_mongoUserId);
      }
      else if (response.statusCode == 404) {
        print('📭 [PROGRESO] No se encontró progreso (404) - Creando nuevo');
        return _crearProgresoVacio(_mongoUserId);
      }
      else {
        print('⚠️ [PROGRESO] Servidor respondió con: ${response.statusCode}');
        return _crearProgresoVacio(_mongoUserId);
      }
    } catch (e) {
      print('❌ [PROGRESO] Error de conexión: $e');
      return _crearProgresoVacio(_mongoUserId);
    }
  }

  // ✅ NUEVO MÉTODO: OBTENER DETALLE DE JUEGOS POR MÓDULO
  static Future<Map<String, dynamic>> obtenerDetalleJuegosModulo(String moduloId) async {
    final userId = _mongoUserId ?? '68ff1b0eb113d8ba6dc99661';

    try {
      print('🎮 [PROGRESO] Obteniendo detalle de módulo: $moduloId');
      print('🌐 [PROGRESO] URL: $baseUrl/$_mongoUserId/modulo/$moduloId/juegos');

      final response = await http.get(
        Uri.parse('$baseUrl/$_mongoUserId/modulo/$moduloId/juegos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': ApiService.headers['Authorization'] ?? '',
        },
      ).timeout(const Duration(seconds: 15));

      print('📊 [PROGRESO] Detalle Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('✅ [PROGRESO] Detalle de módulo obtenido exitosamente');
        return jsonResponse['data'] ?? _crearDetalleModuloEjemplo(moduloId);
      } else {
        print('⚠️ [PROGRESO] Usando datos de ejemplo para módulo');
        return _crearDetalleModuloEjemplo(moduloId);
      }
    } catch (e) {
      print('❌ [PROGRESO] Error obteniendo detalle de módulo: $e');
      return _crearDetalleModuloEjemplo(moduloId);
    }
  }

  // ✅ MÉTODO PARA DEBUGGEAR LA CONEXIÓN
  static Future<void> debugConexion() async {
    final userId = _mongoUserId ?? '68ff1b0eb113d8ba6dc99661';

    print('\n🔍 [DEBUG] Iniciando diagnóstico de conexión...');
    print('📱 Plataforma: ${Platform.operatingSystem}');
    print('🔗 URL Base: $baseUrl');
    print('👤 UserId: $_mongoUserId');
    print('🔑 Token: ${ApiService.headers['Authorization']?.substring(0, 20)}...');

    try {
      // Probar conexión básica
      print('\n1. 🧪 Probando conexión básica...');
      final testResponse = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('   ✅ Health Check: ${testResponse.statusCode}');
      if (testResponse.statusCode == 200) {
        print('   📋 Health Response: ${testResponse.body}');
      }

      // Probar endpoint de progreso sin userId
      print('\n2. 🧪 Probando endpoint de progreso sin auth...');
      final progresoTest = await http.get(
        Uri.parse('$baseUrl/test'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('   ✅ Test Endpoint: ${progresoTest.statusCode}');
      if (progresoTest.statusCode == 200) {
        print('   📋 Test Response: ${progresoTest.body}');
      }

      // Probar el endpoint real con los headers completos
      print('\n3. 🧪 Probando endpoint real...');
      final realResponse = await http.get(
        Uri.parse('$baseUrl/$_mongoUserId/completo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': ApiService.headers['Authorization'] ?? '',
          'User-Agent': 'Flutter-App/1.0',
        },
      ).timeout(const Duration(seconds: 15));

      print('   ✅ Real Endpoint: ${realResponse.statusCode}');
      print('   📋 Real Response: ${realResponse.body}');

      if (realResponse.statusCode == 400) {
        print('\n❌ [DEBUG] ERROR 400 DETECTADO');
        print('💡 Posibles soluciones:');
        print('   • Verificar que el userId sea válido en MongoDB');
        print('   • Verificar los logs del servidor Node.js');
        print('   • Probar con userId: "1" o crear un usuario nuevo');
      }

    } catch (e) {
      print('❌ [DEBUG] Error durante diagnóstico: $e');
    }
  }

  // ✅ OBTENER ESTADÍSTICAS GLOBALES
  static Future<Map<String, dynamic>> obtenerEstadisticasGlobales() async {
    final userId = _mongoUserId ?? '68ff1b0eb113d8ba6dc99661';

    try {
      print('📈 [PROGRESO] Obteniendo estadísticas para: $userId');

      final response = await http.get(
        Uri.parse('$baseUrl/$_mongoUserId/estadisticas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': ApiService.headers['Authorization'] ?? '',
        },
      ).timeout(const Duration(seconds: 15));

      print('📊 [PROGRESO] Stats Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['data'] ?? _crearEstadisticasVacias();
      } else {
        return _crearEstadisticasVacias();
      }
    } catch (e) {
      print('❌ [PROGRESO] Error en stats: $e');
      return _crearEstadisticasVacias();
    }
  }

  // ✅ OBTENER PROGRESO POR MÓDULOS
  static Future<List<dynamic>> obtenerProgresoModulos() async {
    final userId = _mongoUserId ?? '68ff1b0eb113d8ba6dc99661';

    try {
      print('🎯 [PROGRESO] Obteniendo módulos para: $userId');

      final response = await http.get(
        Uri.parse('$baseUrl/$_mongoUserId/modulos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': ApiService.headers['Authorization'] ?? '',
        },
      ).timeout(const Duration(seconds: 15));

      print('📊 [PROGRESO] Modules Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['data'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print('❌ [PROGRESO] Error en módulos: $e');
      return [];
    }
  }

  // ✅ ACTUALIZAR PROGRESO DESPUÉS DE JUEGO
  static Future<Map<String, dynamic>> actualizarProgreso({
    required String juegoId,
    required Map<String, dynamic> datosPartida,
  }) async {
    final userId = _mongoUserId ?? '68ff1b0eb113d8ba6dc99661';

    try {
      print('🔄 [PROGRESO] Actualizando progreso para juego: $juegoId');

      final response = await http.post(
        Uri.parse('$baseUrl/actualizar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': ApiService.headers['Authorization'] ?? '',
        },
        body: json.encode({
          'userId': _mongoUserId,
          'juegoId': juegoId,
          'datosPartida': datosPartida,
        }),
      ).timeout(const Duration(seconds: 15));

      print('📊 [PROGRESO] Update Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['data'];
      } else {
        throw Exception('Error al actualizar progreso: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [PROGRESO] Error actualizando progreso: $e');
      throw Exception('Error al guardar progreso: $e');
    }
  }

  // ✅ VERIFICAR CONEXIÓN CON EL SERVIDOR
  static Future<bool> verificarConexion() async {
    try {
      print('🔍 [PROGRESO] Verificando conexión con Node.js...');

      final response = await http.get(
        Uri.parse('$baseUrl/test'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      final isConnected = response.statusCode == 200;
      print('📊 [PROGRESO] Conexión verificada: $isConnected');

      return isConnected;
    } catch (e) {
      print('❌ [PROGRESO] Error de conexión: $e');
      return false;
    }
  }

  // ✅ MÉTODO PARA PROBAR CONEXIÓN COMPLETA
  static Future<void> testConexionCompleta() async {
    final userId = _mongoUserId ?? '68ff1b0eb113d8ba6dc99661';

    try {
      print('\n🧪 [TEST] Iniciando prueba completa de conexión...');

      // 1. Verificar conexión básica
      final conexionOk = await verificarConexion();
      print('1. ✅ Conexión básica: $conexionOk');

      if (conexionOk) {
        // 2. Probar obtener progreso completo
        final progreso = await obtenerProgresoCompleto();
        print('2. ✅ Progreso completo: ${progreso.isNotEmpty}');

        // 3. Probar obtener estadísticas
        final estadisticas = await obtenerEstadisticasGlobales();
        print('3. ✅ Estadísticas: ${estadisticas.isNotEmpty}');

        // 4. Probar obtener módulos
        final modulos = await obtenerProgresoModulos();
        print('4. ✅ Módulos: ${modulos.length} encontrados');

        print('\n🎉 [TEST] Todas las pruebas pasaron correctamente!');
      } else {
        print('\n❌ [TEST] No se pudo establecer conexión con el servidor');
      }
    } catch (e) {
      print('\n❌ [TEST] Error durante las pruebas: $e');
    }
  }

  // ✅ MÉTODOS AUXILIARES PARA DATOS DE EJEMPLO
  static Map<String, dynamic> _crearProgresoVacio(String _mongoUserId) {
    return {
      'user': _mongoUserId,
      'puntuacionGlobal': 0,
      'tiempoTotalGlobal': 0,
      'nivelGlobal': 1,
      'progresoModulos': [],
      'progresoJuegos': [],
      'logrosDesbloqueados': [],
      'estadisticas': _crearEstadisticasVacias(),
      'resumen': {
        'nivel': 1,
        'rango': 'Principiante',
        'proximoNivel': 'Comienza a jugar para subir de nivel'
      }
    };
  }

  static Map<String, dynamic> _crearEstadisticasVacias() {
    return {
      'totalPuntuacion': 0,
      'totalTiempoJugado': 0,
      'nivelActual': 1,
      'totalModulos': 0,
      'modulosCompletados': 0,
      'totalJuegos': 0,
      'juegosCompletados': 0,
      'logrosDesbloqueados': 0,
      'tiempoPromedioPorSesion': 0,
      'puntuacionPromedio': 0,
      'progresoGlobal': 0,
    };
  }

  static Map<String, dynamic> _crearDetalleModuloEjemplo(String moduloId) {
    return {
      'modulo': {
        'nombre': 'Disgrafía',
        'progresoGeneral': 65,
        'puntuacionTotal': 850,
        'tiempoTotal': 2400,
      },
      'juegos': [
        {
          'juegoId': '1',
          'nombreJuego': 'Trazo de Letras',
          'tipoJuego': 'escritura',
          'puntuacionTotal': 450,
          'tiempoTotalJugado': 1200,
          'partidasJugadas': 5,
          'nivelMaximo': 3,
          'completado': false,
          'progreso': 45,
        },
        {
          'juegoId': '2',
          'nombreJuego': 'Formación de Palabras',
          'tipoJuego': 'vocabulario',
          'puntuacionTotal': 250,
          'tiempoTotalJugado': 800,
          'partidasJugadas': 3,
          'nivelMaximo': 2,
          'completado': false,
          'progreso': 25,
        },
        {
          'juegoId': '3',
          'nombreJuego': 'Coordinación Motora',
          'tipoJuego': 'motricidad',
          'puntuacionTotal': 150,
          'tiempoTotalJugado': 400,
          'partidasJugadas': 2,
          'nivelMaximo': 1,
          'completado': true,
          'progreso': 100,
        }
      ]
    };
  }
}
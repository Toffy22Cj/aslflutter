import 'dart:io' show Platform, NetworkInterface, InternetAddress, Socket, Process;
import 'package:connectivity_plus/connectivity_plus.dart';

class AppConfig {
  // 🔧 Configura tus IPs locales
  static const String wifiIp = '192.168.1.22';      // 🏠 Tu red doméstica
  static const String hotspotIp = '192.168.137.112';  // 📱 IP del PC como hotspot (ESTÁTICA)

  // ✅ VARIABLES ESTÁTICAS PARA URLs (se inicializan una vez)
  static String? _springBaseUrl;
  static String? _nodeBaseUrl;
  static String? _activeIp;

  // ✅ INICIALIZAR CONFIGURACIÓN (llamar esto al iniciar la app)
  static Future<void> initialize() async {
    print('🎯 [APP CONFIG] Inicializando configuración...');

    _activeIp = await getActiveIp();
    _springBaseUrl = await _buildSpringBaseUrl();
    _nodeBaseUrl = await _buildNodeBaseUrl();

    await printConfig();

    // ✅ VERIFICAR CONEXIÓN INMEDIATAMENTE
    await _verifyConnection();
  }

  // ✅ VERIFICAR CONEXIÓN AL INICIALIZAR
  static Future<void> _verifyConnection() async {
    print('🔍 [APP CONFIG] Verificando conectividad con servidores...');

    final springHost = _springBaseUrl!.replaceFirst('http://', '').split(':')[0];
    final nodeHost = _nodeBaseUrl!.replaceFirst('http://', '').split(':')[0];

    print('🌐 [VERIFY] Probando Spring Boot en: $springHost:8080');
    print('🌐 [VERIFY] Probando Node.js en: $nodeHost:3000');

    try {
      // Probar Spring Boot
      final springTest = await testIpAccessibility(springHost, 8080);

      // Probar Node.js
      final nodeTest = await testIpAccessibility(nodeHost, 3000);

      if (springTest && nodeTest) {
        print('✅ [APP CONFIG] ¡Todos los servidores son accesibles!');
      } else {
        print('❌ [APP CONFIG] Algunos servidores no son accesibles:');
        print('❌ [APP CONFIG] - Spring Boot: ${springTest ? "✅" : "❌"}');
        print('❌ [APP CONFIG] - Node.js: ${nodeTest ? "✅" : "❌"}');
      }
    } catch (e) {
      print('❌ [APP CONFIG] Error verificando conexión: $e');
    }
  }

  // ✅ Detecta la net y elige la IP correcta
  static Future<String> getActiveIp() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    print('📶 [APP CONFIG] Estado de conectividad: $connectivityResult');

    if (connectivityResult == ConnectivityResult.wifi) {
      print('📶 [APP CONFIG] Conectado a WiFi - Usando: $wifiIp');
      return wifiIp;
    } else if (connectivityResult == ConnectivityResult.mobile) {
      print('📶 [APP CONFIG] Conectado a Hotspot del PC - Usando: $hotspotIp');
      return hotspotIp;
    }

    print('📶 [APP CONFIG] Conexión no determinada - Usando: $wifiIp');
    return wifiIp;
  }

  // ✅ Detección de emulador
  static bool get isEmulator {
    try {
      if (!Platform.isAndroid) return false;

      final env = Platform.environment;
      final model = env['MODEL']?.toLowerCase() ?? '';
      final product = env['PRODUCT']?.toLowerCase() ?? '';
      final hardware = env['HARDWARE']?.toLowerCase() ?? '';

      final deviceInfo = '$model$product$hardware';
      final isEmu = deviceInfo.contains('sdk') ||
          deviceInfo.contains('emulator') ||
          deviceInfo.contains('google_sdk') ||
          hardware.contains('goldfish') ||
          hardware.contains('ranchu');

      return isEmu;
    } catch (_) {
      return true;
    }
  }

  // ✅ URL dinámica para Spring Boot (privado)
  static Future<String> _buildSpringBaseUrl() async {
    final ip = _activeIp ?? await getActiveIp();
    final base = Platform.isAndroid
        ? (isEmulator ? 'http://10.0.2.2:8080' : 'http://$ip:8080')
        : 'http://localhost:8080';
    return '$base/api/auth';
  }

  // ✅ URL dinámica para Node.js (privado)
  static Future<String> _buildNodeBaseUrl() async {
    final ip = _activeIp ?? await getActiveIp();
    final base = Platform.isAndroid
        ? (isEmulator ? 'http://10.0.2.2:3000' : 'http://$ip:3000')
        : 'http://localhost:3000';
    return '$base/api';
  }

  // ✅ GETTERS SÍNCRONOS PARA URLs
  static String get springBaseUrl {
    if (_springBaseUrl == null) {
      throw Exception('AppConfig no inicializado. Llama a AppConfig.initialize() primero.');
    }
    return _springBaseUrl!;
  }

  static String get nodeBaseUrl {
    if (_nodeBaseUrl == null) {
      throw Exception('AppConfig no inicializado. Llama a AppConfig.initialize() primero.');
    }
    return _nodeBaseUrl!;
  }

  static String get activeIp {
    if (_activeIp == null) {
      throw Exception('AppConfig no inicializado. Llama a AppConfig.initialize() primero.');
    }
    return _activeIp!;
  }

  // ✅ Método para imprimir configuración actual
  static Future<void> printConfig() async {
    print('🎯 [APP CONFIG] =========================');
    print('📱 Plataforma: ${Platform.operatingSystem}');
    print('🔧 Es emulador: $isEmulator');
    print('🌐 IP activa: $_activeIp');
    print('🌐 Spring URL: $_springBaseUrl');
    print('🌐 Node URL: $_nodeBaseUrl');
    print('🎯 [APP CONFIG] =========================');
  }

  // ✅ ACTUALIZAR CONFIGURACIÓN (si cambia la red)
  static Future<void> updateConfig() async {
    print('🔄 [APP CONFIG] Actualizando configuración...');
    await initialize();
  }

  // ✅ MÉTODO DE DIAGNÓSTICO COMPLETO
  static Future<void> diagnostic() async {
    print('🩺 [APP CONFIG DIAGNOSTIC] ========================');
    print('📱 Plataforma: ${Platform.operatingSystem}');
    print('🔧 Es emulador: $isEmulator');

    final connectivity = await Connectivity().checkConnectivity();
    print('📶 Conectividad: $connectivity');

    print('🌐 IP activa: $_activeIp');
    print('🌐 Spring URL: $_springBaseUrl');
    print('🌐 Node URL: $_nodeBaseUrl');

    // Test de conexión con servidores
    print('🔍 [DIAGNOSTIC] Probando conexión con servidores...');
    await _verifyConnection();

    // Detectar interfaces de red
    await _detectNetworkInterfaces();

    // Test de DNS básico
    await _testDnsConnectivity();

    // Test de conectividad básica al PC
    await _testBasicConnectivity();

    print('🩺 [APP CONFIG DIAGNOSTIC] ========================');
  }

  // ✅ DETECTAR INTERFACES DE RED
  static Future<void> _detectNetworkInterfaces() async {
    try {
      final interfaces = await NetworkInterface.list();
      print('🔍 [DIAGNOSTIC] Interfaces de red detectadas: ${interfaces.length}');

      for (var interface in interfaces) {
        print('🔍 [DIAGNOSTIC] Interface: ${interface.name}');
        for (var addr in interface.addresses) {
          final type = addr.isLoopback ? 'Loopback' :
          addr.address.contains(':') ? 'IPv6' : 'IPv4';
          print('🔍 [DIAGNOSTIC] - ${addr.address} ($type)');
        }
      }
    } catch (e) {
      print('❌ [DIAGNOSTIC] Error detectando interfaces: $e');
    }
  }

  // ✅ TEST DE CONECTIVIDAD DNS
  static Future<void> _testDnsConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      print('✅ [DIAGNOSTIC] DNS funciona: ${result.isNotEmpty}');
      if (result.isNotEmpty) {
        print('✅ [DIAGNOSTIC] Google resuelve a: ${result.first.address}');
      }
    } catch (e) {
      print('❌ [DIAGNOSTIC] Error DNS: $e');
    }
  }

  // ✅ TEST DE CONECTIVIDAD BÁSICA
  static Future<void> _testBasicConnectivity() async {
    print('🔍 [BASIC TEST] Probando conectividad básica...');

    // Probar si podemos alcanzar la IP del PC
    try {
      final result = await InternetAddress.lookup(hotspotIp);
      print('✅ [BASIC TEST] IP $hotspotIp es alcanzable: ${result.isNotEmpty}');
    } catch (e) {
      print('❌ [BASIC TEST] IP $hotspotIp NO es alcanzable: $e');
    }
  }

  // ✅ MÉTODO PARA VERIFICAR SI UNA IP ES ACCESIBLE
  static Future<bool> testIpAccessibility(String ip, int port) async {
    try {
      print('🔍 [IP TEST] Probando conectividad a $ip:$port');

      final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
      socket.destroy();
      print('✅ [IP TEST] $ip:$port es accesible');
      return true;
    } catch (e) {
      print('❌ [IP TEST] $ip:$port no es accesible: $e');
      return false;
    }
  }

  // ✅ MÉTODO PARA PROBAR CONEXIÓN DESDE EL TELÉFONO (CORREGIDO)
  static Future<void> testPhoneToPcConnection() async {
    print('📱 [PHONE TEST] Probando conexión desde teléfono al PC...');

    // Probar conectividad básica a la IP del PC
    try {
      final result = await InternetAddress.lookup(hotspotIp);
      print('✅ [PHONE TEST] IP $hotspotIp es alcanzable: ${result.isNotEmpty}');
      if (result.isNotEmpty) {
        print('✅ [PHONE TEST] Resuelve a: ${result.first.address}');
      }
    } catch (e) {
      print('❌ [PHONE TEST] IP $hotspotIp NO es alcanzable: $e');
    }
  }

  // ✅ MÉTODO PARA OBTENER CONFIGURACIÓN ACTUAL
  static Map<String, String> getCurrentConfig() {
    return {
      'platform': Platform.operatingSystem,
      'isEmulator': isEmulator.toString(),
      'activeIp': _activeIp ?? 'No configurada',
      'springUrl': _springBaseUrl ?? 'No configurada',
      'nodeUrl': _nodeBaseUrl ?? 'No configurada',
    };
  }

  // ✅ MÉTODO PARA OBTENER INFORMACIÓN DE RED COMPLETA
  static Future<Map<String, dynamic>> getNetworkInfo() async {
    final connectivity = await Connectivity().checkConnectivity();
    final interfaces = await NetworkInterface.list();

    List<Map<String, String>> interfaceList = [];

    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        interfaceList.add({
          'interface': interface.name,
          'address': addr.address,
          'type': addr.isLoopback ? 'Loopback' :
          addr.address.contains(':') ? 'IPv6' : 'IPv4',
        });
      }
    }

    return {
      'connectivity': connectivity.toString(),
      'isEmulator': isEmulator,
      'activeIp': _activeIp,
      'springUrl': _springBaseUrl,
      'nodeUrl': _nodeBaseUrl,
      'interfaces': interfaceList,
    };
  }
}
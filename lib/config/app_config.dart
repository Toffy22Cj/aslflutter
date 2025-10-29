import 'dart:io' show Platform;
import 'package:connectivity_plus/connectivity_plus.dart';

class AppConfig {
  // 🔧 Configura tus IPs locales
  static const String wifiIp = '192.168.1.22';      // 🏠 Tu red doméstica
  static const String hotspotIp = '10.155.178.19';  // 📱 Hotspot del celular

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
  }

  // ✅ Detecta la red y elige la IP correcta
  static Future<String> getActiveIp() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.wifi) {
      return wifiIp;
    } else if (connectivityResult == ConnectivityResult.mobile) {
      return hotspotIp;
    }
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
}
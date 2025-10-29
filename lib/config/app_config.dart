// lib/config/app_config.dart
import 'dart:io' show Platform;

class AppConfig {
  // ✅ CONFIGURACIÓN PARA DESARROLLO - CAMBIA ESTA IP
  static const String physicalDeviceIp = '192.168.1.22'; // ← TU IP AQUÍ

  // ✅ DETECCIÓN DE DISPOSITIVO
  static bool get isEmulator {
    try {
      if (!Platform.isAndroid) return false;

      final env = Platform.environment;
      final model = env['MODEL']?.toLowerCase() ?? '';
      final product = env['PRODUCT']?.toLowerCase() ?? '';
      final hardware = env['HARDWARE']?.toLowerCase() ?? '';

      final deviceInfo = '$model$product$hardware';
      final isEmulator = deviceInfo.contains('sdk') ||
          deviceInfo.contains('emulator') ||
          deviceInfo.contains('google_sdk') ||
          hardware.contains('goldfish') ||
          hardware.contains('ranchu');

      print('📱 [CONFIG] Dispositivo: ${isEmulator ? 'Emulador' : 'Físico'}');
      print('📱 [CONFIG] Info: $deviceInfo');

      return isEmulator;
    } catch (e) {
      return true; // En caso de error, asumir emulador
    }
  }

  // ✅ URLs DINÁMICAS
  static String get springBaseUrl {
    if (Platform.isAndroid) {
      final base = isEmulator ? 'http://10.0.2.2:8080' : 'http://$physicalDeviceIp:8080';
      return '$base/api/auth';
    } else if (Platform.isIOS) {
      return 'http://localhost:8080/api/auth';
    } else {
      return 'http://localhost:8080/api/auth';
    }
  }

  static String get nodeBaseUrl {
    if (Platform.isAndroid) {
      final base = isEmulator ? 'http://10.0.2.2:3000' : 'http://$physicalDeviceIp:3000';
      return '$base/api';
    } else if (Platform.isIOS) {
      return 'http://localhost:3000/api';
    } else {
      return 'http://localhost:3000/api';
    }
  }

  // ✅ MÉTODO PARA DEBUG
  static void printConfig() {
    print('🎯 [APP CONFIG] =========================');
    print('📱 Plataforma: ${Platform.operatingSystem}');
    print('🔧 Es emulador: $isEmulator');
    print('🌐 Spring URL: $springBaseUrl');
    print('🌐 Node URL: $nodeBaseUrl');
    print('🎯 [APP CONFIG] =========================');
  }
}
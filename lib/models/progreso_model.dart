// models/progreso_model.dart
class ProgresoCompleto {
  final String userId;
  final int puntuacionGlobal;
  final int tiempoTotalGlobal;
  final int nivelGlobal;
  final List<ProgresoModulo> progresoModulos;
  final List<dynamic> logrosDesbloqueados;
  final EstadisticasGlobales estadisticas;
  final ResumenProgreso resumen;

  ProgresoCompleto({
    required this.userId,
    required this.puntuacionGlobal,
    required this.tiempoTotalGlobal,
    required this.nivelGlobal,
    required this.progresoModulos,
    required this.logrosDesbloqueados,
    required this.estadisticas,
    required this.resumen,
  });

  factory ProgresoCompleto.fromJson(Map<String, dynamic> json) {
    return ProgresoCompleto(
      userId: json['user']?.toString() ?? '',
      puntuacionGlobal: json['puntuacionGlobal'] ?? 0,
      tiempoTotalGlobal: json['tiempoTotalGlobal'] ?? 0,
      nivelGlobal: json['nivelGlobal'] ?? 1,
      progresoModulos: (json['progresoModulos'] as List? ?? [])
          .map((mod) => ProgresoModulo.fromJson(mod))
          .toList(),
      logrosDesbloqueados: json['logrosDesbloqueados'] ?? [],
      estadisticas: EstadisticasGlobales.fromJson(json['estadisticas'] ?? {}),
      resumen: ResumenProgreso.fromJson(json['resumen'] ?? {}),
    );
  }
}

class ProgresoModulo {
  final String moduloId;
  final String nombreModulo;
  final int puntuacionTotal;
  final int tiempoTotalJugado;
  final int progresoPorcentaje;
  final int totalJuegos;
  final int juegosCompletados;
  final List<ProgresoJuego> progresoJuegos;

  ProgresoModulo({
    required this.moduloId,
    required this.nombreModulo,
    required this.puntuacionTotal,
    required this.tiempoTotalJugado,
    required this.progresoPorcentaje,
    required this.totalJuegos,
    required this.juegosCompletados,
    required this.progresoJuegos,
  });

  factory ProgresoModulo.fromJson(Map<String, dynamic> json) {
    return ProgresoModulo(
      moduloId: json['moduloId']?.toString() ?? '',
      nombreModulo: json['nombreModulo'] ?? 'Módulo Sin Nombre',
      puntuacionTotal: json['puntuacionTotal'] ?? 0,
      tiempoTotalJugado: json['tiempoTotalJugado'] ?? 0,
      progresoPorcentaje: json['progresoPorcentaje'] ?? 0,
      totalJuegos: json['totalJuegos'] ?? 0,
      juegosCompletados: json['juegosCompletados'] ?? 0,
      progresoJuegos: (json['progresoJuegos'] as List? ?? [])
          .map((juego) => ProgresoJuego.fromJson(juego))
          .toList(),
    );
  }
}

class ProgresoJuego {
  final String juegoId;
  final String nombreJuego;
  final String tipoJuego;
  final int puntuacionTotal;
  final int tiempoTotalJugado;
  final int partidasJugadas;
  final int nivelMaximo;
  final bool completado;
  final int progreso;

  ProgresoJuego({
    required this.juegoId,
    required this.nombreJuego,
    required this.tipoJuego,
    required this.puntuacionTotal,
    required this.tiempoTotalJugado,
    required this.partidasJugadas,
    required this.nivelMaximo,
    required this.completado,
    required this.progreso,
  });

  factory ProgresoJuego.fromJson(Map<String, dynamic> json) {
    return ProgresoJuego(
      juegoId: json['juegoId']?.toString() ?? '',
      nombreJuego: json['nombreJuego'] ?? 'Juego Sin Nombre',
      tipoJuego: json['tipoJuego'] ?? 'desconocido',
      puntuacionTotal: json['puntuacionTotal'] ?? 0,
      tiempoTotalJugado: json['tiempoTotalJugado'] ?? 0,
      partidasJugadas: json['partidasJugadas'] ?? 0,
      nivelMaximo: json['nivelMaximo'] ?? 1,
      completado: json['completado'] ?? false,
      progreso: json['progreso'] ?? 0,
    );
  }
}

class EstadisticasGlobales {
  final int totalPuntuacion;
  final int totalTiempoJugado;
  final int nivelActual;
  final int totalModulos;
  final int modulosCompletados;
  final int totalJuegos;
  final int juegosCompletados;
  final int logrosDesbloqueados;
  final int tiempoPromedioPorSesion;
  final int puntuacionPromedio;
  final int progresoGlobal;

  EstadisticasGlobales({
    required this.totalPuntuacion,
    required this.totalTiempoJugado,
    required this.nivelActual,
    required this.totalModulos,
    required this.modulosCompletados,
    required this.totalJuegos,
    required this.juegosCompletados,
    required this.logrosDesbloqueados,
    required this.tiempoPromedioPorSesion,
    required this.puntuacionPromedio,
    required this.progresoGlobal,
  });

  factory EstadisticasGlobales.fromJson(Map<String, dynamic> json) {
    return EstadisticasGlobales(
      totalPuntuacion: json['totalPuntuacion'] ?? 0,
      totalTiempoJugado: json['totalTiempoJugado'] ?? 0,
      nivelActual: json['nivelActual'] ?? 1,
      totalModulos: json['totalModulos'] ?? 0,
      modulosCompletados: json['modulosCompletados'] ?? 0,
      totalJuegos: json['totalJuegos'] ?? 0,
      juegosCompletados: json['juegosCompletados'] ?? 0,
      logrosDesbloqueados: json['logrosDesbloqueados'] ?? 0,
      tiempoPromedioPorSesion: json['tiempoPromedioPorSesion'] ?? 0,
      puntuacionPromedio: json['puntuacionPromedio'] ?? 0,
      progresoGlobal: json['progresoGlobal'] ?? 0,
    );
  }
}

class ResumenProgreso {
  final int nivel;
  final String rango;
  final String proximoNivel;

  ResumenProgreso({
    required this.nivel,
    required this.rango,
    required this.proximoNivel,
  });

  factory ResumenProgreso.fromJson(Map<String, dynamic> json) {
    return ResumenProgreso(
      nivel: json['nivel'] ?? 1,
      rango: json['rango'] ?? 'Principiante',
      proximoNivel: json['proximoNivel'] ?? 'Comienza a jugar',
    );
  }
}
// pages/modulo_detail_page.dart - VERSIÓN CORREGIDA
import 'package:flutter/material.dart';
import '../services/progreso_service.dart';
import '../widgets/comic_button.dart';
import '../widgets/loader.dart';

class ModuloDetailPage extends StatefulWidget {
  final String userId;
  final String moduloId;
  final String moduloNombre;

  const ModuloDetailPage({
    Key? key,
    required this.userId,
    required this.moduloId,
    required this.moduloNombre,
  }) : super(key: key);

  @override
  _ModuloDetailPageState createState() => _ModuloDetailPageState();
}

class _ModuloDetailPageState extends State<ModuloDetailPage> {
  Map<String, dynamic>? _detalleModulo;
  bool _isLoading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _cargarDetalleModulo();
  }

  Future<void> _cargarDetalleModulo() async {
    try {
      print('🎮 [MODULO] Cargando detalle del módulo: ${widget.moduloId}');

      // ✅ CORREGIDO: Usar el método correcto para detalle de módulo
      final data = await ProgresoService.obtenerDetalleJuegosModulo(widget.moduloId);

      setState(() {
        _detalleModulo = data;
        _isLoading = false;
        _error = false;
      });

      print('✅ [MODULO] Detalle del módulo cargado exitosamente');
      print('📊 [MODULO] Datos recibidos: $_detalleModulo');
    } catch (e) {
      print('❌ [MODULO] Error cargando detalle del módulo: $e');
      setState(() {
        _isLoading = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.moduloNombre,
          style: const TextStyle(
            fontFamily: 'Bangers',
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFFFD322),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/FONDO1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? const Center(child: Loader(show: true, message: 'Cargando módulo...'))
            : _error
            ? _buildErrorWidget()
            : _buildModuloContent(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 6),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(10, 10),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Error al cargar el módulo',
              style: TextStyle(
                fontFamily: 'Bangers',
                fontSize: 24,
                color: Color(0xFF8B1E1E),
              ),
            ),
            const SizedBox(height: 20),
            ComicButton(
              text: 'Reintentar',
              onPressed: _cargarDetalleModulo,
              backgroundColor: const Color(0xFFFFD322),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuloContent() {
    // ✅ CORREGIDO: Manejo seguro de datos nulos
    final modulo = _detalleModulo?['modulo'] as Map<String, dynamic>? ?? {};
    final juegos = _detalleModulo?['juegos'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Resumen del Módulo
          _buildResumenModulo(modulo),

          const SizedBox(height: 30),

          // Lista de Juegos
          _buildListaJuegos(juegos),
        ],
      ),
    );
  }

  Widget _buildResumenModulo(Map<String, dynamic> modulo) {
    final progresoGeneral = modulo['progresoGeneral']?.toInt() ?? 0;
    final puntuacionTotal = modulo['puntuacionTotal']?.toInt() ?? 0;
    final tiempoTotal = modulo['tiempoTotal']?.toInt() ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 6),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(10, 10),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Resumen del Módulo',
            style: TextStyle(
              fontFamily: 'Bangers',
              fontSize: 28,
              color: Color(0xFF8B1E1E),
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  color: Colors.black,
                  blurRadius: 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Estadísticas del módulo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildModuloStat('Progreso', '$progresoGeneral%', Icons.trending_up),
              _buildModuloStat('Puntuación', '$puntuacionTotal', Icons.score),
              _buildModuloStat('Tiempo', '${_formatTiempo(tiempoTotal)}', Icons.timer),
            ],
          ),

          const SizedBox(height: 20),

          // Barra de progreso principal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4),
              border: Border.all(color: Colors.black, width: 4),
            ),
            child: Column(
              children: [
                const Text(
                  'Progreso General del Módulo',
                  style: TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                    ),
                    Container(
                      height: 30,
                      width: (progresoGeneral / 100) * (MediaQuery.of(context).size.width - 80),
                      decoration: BoxDecoration(
                        color: _getProgressColor(progresoGeneral),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 6,
                      child: Text(
                        '$progresoGeneral% Completado',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaJuegos(List<dynamic> juegos) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 6),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(10, 10),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Juegos del Módulo',
            style: TextStyle(
              fontFamily: 'Bangers',
              fontSize: 28,
              color: Color(0xFF8B1E1E),
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  color: Colors.black,
                  blurRadius: 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (juegos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No hay juegos en este módulo aún.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ...juegos.asMap().entries.map((entry) {
              final index = entry.key;
              final juego = entry.value;
              return _buildJuegoItem(juego, index);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildJuegoItem(dynamic juego, int index) {
    // ✅ CORREGIDO: Manejo seguro de datos del juego
    final juegoMap = juego is Map<String, dynamic> ? juego : {};
    final nombreJuego = juegoMap['nombreJuego']?.toString() ?? 'Juego ${index + 1}';
    final tipoJuego = juegoMap['tipoJuego']?.toString() ?? 'Desconocido';
    final nivelMaximo = juegoMap['nivelMaximo']?.toInt() ?? 1;
    final partidasJugadas = juegoMap['partidasJugadas']?.toInt() ?? 0;
    final puntuacionTotal = juegoMap['puntuacionTotal']?.toInt() ?? 0;
    final progreso = juegoMap['progreso']?.toInt() ?? 0;
    final completado = juegoMap['completado'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icono del juego
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: completado ? Colors.green : const Color(0xFFFFD322),
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                completado ? Icons.check : Icons.videogame_asset,
                size: 30,
                color: Colors.black,
              ),
            ),

            const SizedBox(width: 16),

            // Información del juego
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreJuego,
                    style: const TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tipo: $tipoJuego',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Estadísticas del juego
                  Row(
                    children: [
                      _buildJuegoStat('Nivel', '$nivelMaximo'),
                      const SizedBox(width: 16),
                      _buildJuegoStat('Partidas', '$partidasJugadas'),
                      const SizedBox(width: 16),
                      _buildJuegoStat('Puntos', '$puntuacionTotal'),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Barra de progreso del juego
                  Stack(
                    children: [
                      Container(
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                      ),
                      Container(
                        height: 15,
                        width: (progreso / 100) * (MediaQuery.of(context).size.width - 200),
                        decoration: BoxDecoration(
                          color: _getProgressColor(progreso),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Estado de completado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: completado ? Colors.green : Colors.orange,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Text(
                completado ? 'COMPLETADO' : 'EN PROGRESO',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Los métodos _buildModuloStat, _buildJuegoStat, _formatTiempo, _getProgressColor
  // permanecen igual que en tu código original
  Widget _buildModuloStat(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.black),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Bangers',
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildJuegoStat(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatTiempo(int segundos) {
    final horas = segundos ~/ 3600;
    final minutos = (segundos % 3600) ~/ 60;

    if (horas > 0) {
      return '${horas}h ${minutos}m';
    } else {
      return '${minutos}m';
    }
  }

  Color _getProgressColor(int porcentaje) {
    if (porcentaje < 30) return Colors.red;
    if (porcentaje < 70) return Colors.orange;
    return Colors.green;
  }
}
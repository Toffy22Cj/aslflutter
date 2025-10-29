// pages/progreso_page.dart
import 'package:flutter/material.dart';
import '../models/progreso_model.dart';
import '../services/progreso_service.dart';
import '../widgets/comic_button.dart';
import '../widgets/loader.dart';
import 'modulo_detail_page.dart';

class ProgresoPage extends StatefulWidget {
  final String userId;
  final String userName;

  const ProgresoPage({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  _ProgresoPageState createState() => _ProgresoPageState();
}

class _ProgresoPageState extends State<ProgresoPage> {
  ProgresoCompleto? _progreso;
  bool _isLoading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _cargarProgreso();
  }

  Future<void> _cargarProgreso() async {
    try {
      print('📊 [PROGRESO] Cargando progreso para usuario: ${widget.userId}');

      final data = await ProgresoService.obtenerProgresoCompleto();

      setState(() {
        _progreso = ProgresoCompleto.fromJson(data);
        _isLoading = false;
        _error = false;
      });

      print('✅ [PROGRESO] Progreso cargado exitosamente');
    } catch (e) {
      print('❌ [PROGRESO] Error cargando progreso: $e');
      setState(() {
        _isLoading = false;
        _error = true;
      });
    }
  }

  void _navigateToModuloDetail(String moduloId, String moduloNombre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModuloDetailPage(
          userId: widget.userId,
          moduloId: moduloId,
          moduloNombre: moduloNombre,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Progreso',
          style: TextStyle(
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
            ? const Center(child: Loader(show: true, message: 'Cargando progreso...'))
            : _error
            ? _buildErrorWidget()
            : _buildProgresoContent(),
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
              '¡Ups! Algo salió mal',
              style: TextStyle(
                fontFamily: 'Bangers',
                fontSize: 24,
                color: Color(0xFF8B1E1E),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'No pudimos cargar tu progreso. Intenta de nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ComicButton(
              text: 'Reintentar',
              onPressed: _cargarProgreso,
              backgroundColor: const Color(0xFFFFD322),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgresoContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Tarjeta de Estadísticas Globales
          _buildEstadisticasCard(),

          const SizedBox(height: 30),

          // Lista de Módulos
          _buildModulosCard(),

          const SizedBox(height: 20),

          // Botón de Actualizar
          ComicButton(
            text: 'Actualizar Progreso',
            onPressed: _cargarProgreso,
            backgroundColor: const Color(0xFFFFD322),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticasCard() {
    final stats = _progreso!.estadisticas;
    final resumen = _progreso!.resumen;

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
            'Estadísticas Globales',
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

          // Nivel y Rango
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4),
              border: Border.all(color: Colors.black, width: 4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Nivel', '${stats.nivelActual}', Icons.star),
                _buildStatItem('Rango', resumen.rango, Icons.emoji_events),
                _buildStatItem('Progreso', '${stats.progresoGlobal}%', Icons.trending_up),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Grid de Estadísticas
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard('Puntuación Total', '${stats.totalPuntuacion}', Icons.score, Colors.blue),
              _buildStatCard('Tiempo Jugado', '${_formatTiempo(stats.totalTiempoJugado)}', Icons.timer, Colors.green),
              _buildStatCard('Módulos Completados', '${stats.modulosCompletados}/${stats.totalModulos}', Icons.library_books, Colors.orange),
              _buildStatCard('Juegos Completados', '${stats.juegosCompletados}/${stats.totalJuegos}', Icons.videogame_asset, Colors.purple),
              _buildStatCard('Logros', '${stats.logrosDesbloqueados}', Icons.emoji_events, Colors.amber),
              _buildStatCard('Puntuación Promedio', '${stats.puntuacionPromedio}', Icons.assessment, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModulosCard() {
    final modulos = _progreso!.progresoModulos;

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
            'Progreso por Módulos',
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

          if (modulos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Aún no tienes progreso en ningún módulo. ¡Comienza a jugar!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ...modulos.map((modulo) => _buildModuloItem(modulo)).toList(),
        ],
      ),
    );
  }

  Widget _buildModuloItem(ProgresoModulo modulo) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToModuloDetail(modulo.moduloId, modulo.nombreModulo),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono del módulo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD322),
                    border: Border.all(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.library_books, size: 30, color: Colors.black),
                ),

                const SizedBox(width: 16),

                // Información del módulo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modulo.nombreModulo,
                        style: const TextStyle(
                          fontFamily: 'Bangers',
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${modulo.juegosCompletados}/${modulo.totalJuegos} juegos completados',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Barra de progreso
                      Stack(
                        children: [
                          Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                          ),
                          Container(
                            height: 20,
                            width: (modulo.progresoPorcentaje / 100) * (MediaQuery.of(context).size.width - 200),
                            decoration: BoxDecoration(
                              color: _getProgressColor(modulo.progresoPorcentaje),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            top: 1,
                            child: Text(
                              '${modulo.progresoPorcentaje}%',
                              style: const TextStyle(
                                fontSize: 12,
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

                const SizedBox(width: 16),

                // Puntuación
                Column(
                  children: [
                    const Icon(Icons.score, color: Colors.amber, size: 24),
                    Text(
                      '${modulo.puntuacionTotal}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.black),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Bangers',
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Bangers',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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
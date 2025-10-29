import 'package:flutter/material.dart';
import '../models/user.dart';
import 'profile_page.dart';
import 'progreso_page.dart'; // ✅ NUEVA IMPORTACIÓN


class MainPage extends StatelessWidget {
  final User user;

  const MainPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Página Principal',
          style: TextStyle(
            fontFamily: 'Bangers',
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFFFD322),
        elevation: 0,
        actions: [
          // ✅ BOTÓN DE PROGRESO EN EL APP BAR
          IconButton(
            icon: const Icon(Icons.analytics, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProgresoPage(
                    userId: user.springId.toString(),
                    userName: user.nombre,
                  ),
                ),
              );
            },
            tooltip: 'Ver mi progreso',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/FONDO1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
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
                const Text(
                  '¡Bienvenido!',
                  style: TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 36,
                    color: Color(0xFF8B1E1E),
                    shadows: [
                      Shadow(
                        offset: Offset(3, 3),
                        color: Colors.black,
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ AVATAR DEL USUARIO
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/perfil_por_defecto.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // ✅ BADGE DE TIPO DE USUARIO
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getUserTypeColor(user.tipo),
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getUserTypeBadge(user.tipo),
                          style: const TextStyle(
                            fontFamily: 'Bangers',
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  user.nombre,
                  style: const TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 28,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 20),

                _buildInfoRow('Tipo de usuario:', _getUserTypeDisplay(user.tipo)),
                _buildInfoRow('Email:', user.email),
                _buildInfoRow('Spring ID:', user.springId.toString()),
                if (user.mongoId.isNotEmpty)
                  _buildInfoRow('Mongo ID:', user.mongoId),

                const SizedBox(height: 30),

                // ✅ BOTONES DE ACCIÓN MEJORADOS
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Bangers',
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NUEVO: BOTONES DE ACCIÓN MEJORADOS
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // BOTÓN PRINCIPAL
        _buildMainButton(context),

        const SizedBox(height: 20),

        // BOTONES SECUNDARIOS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSecondaryButton(
              text: 'Mi Progreso',
              icon: Icons.analytics,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgresoPage(
                      userId: user.springId.toString(),
                      userName: user.nombre,
                    ),
                  ),
                );
              },
            ),
            _buildSecondaryButton(
              text: 'Mi Perfil',
              icon: Icons.person,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      userId: user.springId,
                      userToken: user.token,
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 15),

        // BOTÓN DE JUEGOS (PARA USUARIOS REGULARES)
        if (user.tipo == 'USUARIO')
          _buildSecondaryButton(
            text: 'Comenzar a Jugar',
            icon: Icons.videogame_asset,
            onPressed: () {
              _showComingSoon(context, 'Juegos');
            },
            backgroundColor: const Color(0xFF4CAF50),
          ),
      ],
    );
  }

  Widget _buildMainButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFD322),
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
          onTap: () {
            _redirectByUserType(context, user.tipo);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getMainButtonIcon(user.tipo),
                  color: Colors.black,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  _getMainButtonText(user.tipo),
                  style: const TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = const Color(0xFFFFD322),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ FUNCIONES AUXILIARES MEJORADAS
  void _redirectByUserType(BuildContext context, String tipo) {
    switch (tipo) {
      case 'ADMIN':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              userId: user.springId,
              userToken: user.token,
            ),
          ),
        );
        break;
      case 'ENTIDAD':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              userId: user.springId,
              userToken: user.token,
            ),
          ),
        );
        break;
      default:
      // Para usuarios regulares, ir al progreso directamente
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProgresoPage(
              userId: user.springId.toString(),
              userName: user.nombre,
            ),
          ),
        );
        break;
    }
  }

  String _getUserTypeDisplay(String tipo) {
    switch (tipo) {
      case 'ADMIN': return 'Administrador';
      case 'ENTIDAD': return 'Entidad';
      case 'USUARIO': return 'Usuario';
      default: return tipo;
    }
  }

  String _getUserTypeBadge(String tipo) {
    switch (tipo) {
      case 'ADMIN': return 'ADMIN';
      case 'ENTIDAD': return 'ENTIDAD';
      case 'USUARIO': return 'USER';
      default: return tipo;
    }
  }

  Color _getUserTypeColor(String tipo) {
    switch (tipo) {
      case 'ADMIN': return const Color(0xFFFF6B6B);
      case 'ENTIDAD': return const Color(0xFF4ECDC4);
      case 'USUARIO': return const Color(0xFFFFD322);
      default: return const Color(0xFFFFD322);
    }
  }

  IconData _getMainButtonIcon(String tipo) {
    switch (tipo) {
      case 'ADMIN': return Icons.admin_panel_settings;
      case 'ENTIDAD': return Icons.business;
      case 'USUARIO': return Icons.videogame_asset;
      default: return Icons.person;
    }
  }

  String _getMainButtonText(String tipo) {
    switch (tipo) {
      case 'ADMIN': return 'Panel de Control';
      case 'ENTIDAD': return 'Gestión';
      case 'USUARIO': return 'Comenzar a Jugar';
      default: return 'Continuar';
    }
  }

  void _showComingSoon(BuildContext context, String pageName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Próximamente',
          style: TextStyle(
            fontFamily: 'Bangers',
            fontSize: 24,
          ),
        ),
        content: Text(
          '$pageName estará disponible pronto.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Bangers',
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
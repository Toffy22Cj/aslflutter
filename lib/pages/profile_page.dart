import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../widgets/comic_button.dart';
import '../widgets/comic_text_field.dart';
import '../widgets/loader.dart';
import 'progreso_page.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  final String userToken;

  const ProfilePage({
    Key? key,
    required this.userId,
    required this.userToken,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late UserProfile _userProfile;
  bool _isLoading = true;
  bool _isSaving = false;

  // Controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();

  // Valores seleccionados
  String? _selectedSexo;
  String? _selectedTrastorno;
  String? _selectedNivel;

  // Opciones para dropdowns
  final List<String> _sexoOptions = ['HOMBRE', 'MUJER', 'OTRO'];
  final List<String> _trastornoOptions = ['DISLEXIA', 'DISCALCULIA', 'DISGRAFIA'];
  final List<String> _nivelOptions = ['BAJO', 'MEDIO', 'AVANZADO'];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      print('🔍 [PROFILE] Cargando perfil para usuario: ${widget.userId}');

      _userProfile = await ProfileService.getUserProfile(widget.userId);

      // Llenar los controladores con los datos del perfil
      _nombreController.text = _userProfile.nombre ?? '';
      _descripcionController.text = _userProfile.descripcion ?? '';
      _telefonoController.text = _userProfile.telefono ?? '';
      _ciudadController.text = _userProfile.ciudad ?? '';
      _selectedSexo = _userProfile.sexo;
      _selectedNivel = _userProfile.nivel;

      // Para trastornos, tomamos el primero si existe
      if (_userProfile.trastornos != null && _userProfile.trastornos!.isNotEmpty) {
        _selectedTrastorno = _userProfile.trastornos!.first;
      }

      setState(() {
        _isLoading = false;
      });

      print('✅ [PROFILE] Perfil cargado exitosamente');
    } catch (e) {
      print('❌ [PROFILE] Error cargando perfil: $e');
      _showError('Error al cargar el perfil: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Preparar datos para enviar
      final profileData = UserProfile(
        nombre: _nombreController.text.isNotEmpty ? _nombreController.text : null,
        descripcion: _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
        telefono: _telefonoController.text.isNotEmpty ? _telefonoController.text : null,
        ciudad: _ciudadController.text.isNotEmpty ? _ciudadController.text : null,
        sexo: _selectedSexo,
        nivel: _selectedNivel,
        trastornos: _selectedTrastorno != null ? [_selectedTrastorno!] : null,
      );

      final result = await ProfileService.updateUserProfile(
        widget.userId,
        profileData,
      );

      _showSuccess('¡Perfil actualizado correctamente!');
      print('✅ [PROFILE] Perfil guardado: $result');

    } catch (e) {
      print('❌ [PROFILE] Error guardando perfil: $e');
      _showError('Error al guardar el perfil: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    _nombreController.clear();
    _descripcionController.clear();
    _telefonoController.clear();
    _ciudadController.clear();
    setState(() {
      _selectedSexo = null;
      _selectedTrastorno = null;
      _selectedNivel = null;
    });
  }

  // ✅ NUEVO MÉTODO: Navegar a la página de progreso
  void _navigateToProgreso() {
    print('🎯 [PROFILE] Navegando a progreso para usuario: ${widget.userId}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgresoPage(
          userId: widget.userId.toString(),
          userName: _userProfile.nombre ?? 'Usuario',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: const Color(0xFFFFD322),
        ),
        body: const Center(
          child: Loader(show: true),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
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
        // ✅ BOTÓN DE PROGRESO EN APP BAR
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics, color: Colors.black),
            onPressed: _navigateToProgreso,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Sección de Perfil
                Container(
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
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Perfil',
                            style: TextStyle(
                              fontFamily: 'Bangers',
                              fontSize: 32,
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

                          // Foto de perfil
                          Stack(
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black, width: 5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(6, 6),
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
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD322),
                                    border: Border.all(color: Colors.black, width: 3),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(3, 3),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.edit, size: 24),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Nombre de usuario
                          ComicTextField(
                            hintText: 'Nombre de Usuario',
                            controller: _nombreController,
                            icon: Icons.person,
                          ),

                          const SizedBox(height: 10),

                          // Descripción
                          ComicTextField(
                            hintText: 'Descripción de Usuario',
                            controller: _descripcionController,
                            icon: Icons.description,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Formulario de Información
                Container(
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
                      const Text(
                        'Información del Usuario',
                        style: TextStyle(
                          fontFamily: 'Bangers',
                          fontSize: 24,
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

                      // Sexo
                      _buildDropdown(
                        label: 'Sexo:',
                        value: _selectedSexo,
                        items: _sexoOptions,
                        hint: 'Seleccione su sexo',
                        onChanged: (value) {
                          setState(() {
                            _selectedSexo = value;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      // Teléfono
                      ComicTextField(
                        hintText: 'Número de Teléfono',
                        controller: _telefonoController,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 15),

                      // Ciudad
                      ComicTextField(
                        hintText: 'Ciudad',
                        controller: _ciudadController,
                        icon: Icons.location_city,
                      ),

                      const SizedBox(height: 15),

                      // Trastorno
                      _buildDropdown(
                        label: 'Trastorno de Aprendizaje:',
                        value: _selectedTrastorno,
                        items: _trastornoOptions,
                        hint: 'Seleccione un trastorno',
                        onChanged: (value) {
                          setState(() {
                            _selectedTrastorno = value;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      // Nivel
                      _buildDropdown(
                        label: 'Nivel del Trastorno:',
                        value: _selectedNivel,
                        items: _nivelOptions,
                        hint: 'Seleccione el nivel',
                        onChanged: (value) {
                          setState(() {
                            _selectedNivel = value;
                          });
                        },
                      ),

                      const SizedBox(height: 30),

                      // Botones principales
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ComicButton(
                            text: 'Guardar',
                            onPressed: _isSaving
                                ? () {} // Función vacía cuando está cargando
                                : _saveProfile, // Función real cuando no está cargando
                            backgroundColor: _isSaving ? Colors.grey : const Color(0xFFFFD322),
                          ),
                          ComicButton(
                            text: 'Limpiar',
                            onPressed: _clearForm,
                            backgroundColor: const Color(0xFFFFD322),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // ✅ SECCIÓN DE OPCIONES ADICIONALES - MEJORADA Y VISIBLE
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E8),
                          border: Border.all(color: Colors.black, width: 4),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Opciones Adicionales',
                              style: TextStyle(
                                fontFamily: 'Bangers',
                                fontSize: 22,
                                color: Color(0xFF8B1E1E),
                                shadows: [
                                  Shadow(
                                    offset: Offset(1, 1),
                                    color: Colors.black,
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ✅ BOTÓN PRINCIPAL DE PROGRESO - GRANDE Y DESTACADO
                            Container(
                              width: double.infinity,
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
                                  onTap: _navigateToProgreso,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.analytics, color: Colors.black, size: 28),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'VER MI PROGRESO',
                                          style: TextStyle(
                                            fontFamily: 'Bangers',
                                            fontSize: 22,
                                            color: Colors.black,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ✅ BOTONES SECUNDARIOS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildActionButton(
                                  text: 'Mis Logros',
                                  icon: Icons.emoji_events,
                                  onPressed: () {
                                    _showComingSoon('Ver Logros');
                                  },
                                ),
                                _buildActionButton(
                                  text: 'Estadísticas',
                                  icon: Icons.bar_chart,
                                  onPressed: () {
                                    _showComingSoon('Estadísticas Detalladas');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Bangers',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Container(
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  hint,
                  style: const TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      _getDisplayText(item),
                      style: const TextStyle(
                        fontFamily: 'Bangers',
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ✅ BOTÓN DE ACCIÓN MEJORADO CON ICONO
  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFD322),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: Colors.black),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 14,
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

  String _getDisplayText(String value) {
    switch (value) {
      case 'HOMBRE': return 'Masculino';
      case 'MUJER': return 'Femenino';
      case 'OTRO': return 'Otro';
      case 'DISLEXIA': return 'Dislexia';
      case 'DISCALCULIA': return 'Discalculia';
      case 'DISGRAFIA': return 'Disgrafia';
      case 'BAJO': return 'Leve';
      case 'MEDIO': return 'Moderado';
      case 'AVANZADO': return 'Alto';
      default: return value;
    }
  }

  void _showComingSoon(String feature) {
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
          '$feature estará disponible pronto.',
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
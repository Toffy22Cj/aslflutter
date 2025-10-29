class UserProfile {
  final String? nombre;
  final String? descripcion;
  final String? telefono;
  final String? ciudad;
  final String? sexo;
  final List<String>? trastornos;
  final String? nivel;
  final String? fotoPerfil;

  UserProfile({
    this.nombre,
    this.descripcion,
    this.telefono,
    this.ciudad,
    this.sexo,
    this.trastornos,
    this.nivel,
    this.fotoPerfil,
  });

  Map<String, dynamic> toJson() {
    return {
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (telefono != null) 'telefono': telefono,
      if (ciudad != null) 'ciudad': ciudad,
      if (sexo != null) 'sexo': sexo,
      if (trastornos != null) 'trastornos': trastornos,
      if (nivel != null) 'nivel': nivel,
      if (fotoPerfil != null) 'fotoPerfil': fotoPerfil,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      telefono: json['telefono'],
      ciudad: json['ciudad'],
      sexo: json['sexo'],
      trastornos: json['trastornos'] != null
          ? List<String>.from(json['trastornos'])
          : null,
      nivel: json['nivel'],
      fotoPerfil: json['fotoPerfil'],
    );
  }
}
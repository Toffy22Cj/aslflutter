class User {
  final String mongoId;
  final int springId;
  final String nombre;
  final String email;
  final String tipo;
  final String token;

  User({
    required this.mongoId,
    required this.springId,
    required this.nombre,
    required this.email,
    required this.tipo,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'mongoId': mongoId,
      'springId': springId,
      'nombre': nombre,
      'email': email,
      'tipo': tipo,
      'token': token,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      mongoId: json['mongoId'] ?? '',
      springId: json['springId'] ?? 0,
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      tipo: json['tipo'] ?? '',
      token: json['token'] ?? '',
    );
  }
}
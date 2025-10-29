class LoginResponse {
  final String tipo;
  final int id;
  final String nombre;
  final String email;
  final String token;

  LoginResponse({
    required this.tipo,
    required this.id,
    required this.nombre,
    required this.email,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      tipo: json['tipo'] ?? '',
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
    );
  }
}
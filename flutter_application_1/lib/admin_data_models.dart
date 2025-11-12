// admin_data_models.dart

// Define la estructura de datos para un usuario administrador
class User {
  String id;       // ID del documento en Firestore
  String name;
  String email;
  String role;     // Debería ser 'Admin'
  String password; // La contraseña

  // Constructor de la clase
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.password,
  });
}
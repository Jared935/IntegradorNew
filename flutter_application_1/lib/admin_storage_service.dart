import 'package:cloud_firestore/cloud_firestore.dart';
// Asegúrate de que este archivo exista y tenga la clase User
import 'admin_data_models.dart' as admin_models;

class AdminStorageService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  // ====================================================================
  // STREAMS (LECTURA SOLO ADMINS)
  // ====================================================================
  static Stream<List<admin_models.User>> streamUsers() {
    return _db
        .collection(_usersCollection)
        .where('role', isEqualTo: 'Admin') // Filtro clave
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return admin_models.User(
          id: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          role: data['role'] ?? '',
          password: data['password'] ?? '',
        );
      }).toList();
    });
  }

  // ====================================================================
  // MÉTODOS DE MODIFICACIÓN (CON DEBUG)
  // ====================================================================

  // Añadir Admin
  static Future<void> addAdminUser(admin_models.User user) async {
    print("🟠 [ADMIN DEBUG] Intentando crear administrador: ${user.email}");
    try {
      await _db.collection(_usersCollection).add({
        'name': user.name,
        'email': user.email,
        'role': 'Admin', // Fuerza el rol
        'password': user.password,
      });
      print("🟢 [ADMIN DEBUG] ¡Éxito! Administrador creado.");
    } catch (e) {
      print("🔴 [ADMIN DEBUG] Error al crear administrador: $e");
      rethrow; // Pasa el error a la pantalla para que lo muestre
    }
  }

  // Borrar Usuario (General, pero usado aquí para admins)
  static Future<void> deleteUser(String userId) async {
    print("🟠 [ADMIN DEBUG] Intentando borrar usuario: $userId");
    try {
       await _db.collection(_usersCollection).doc(userId).delete();
       print("🟢 [ADMIN DEBUG] Usuario borrado.");
    } catch (e) {
       print("🔴 [ADMIN DEBUG] Error al borrar: $e");
    }
  }
}
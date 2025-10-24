// admin_app/admin_data_models.dart
// Renombramos las clases para evitar conflictos si las importas juntas
class AdminUser {
  String id; // Firestore ID
  String name;
  String email;
  String role;
  String password;
  AdminUser({required this.id, required this.name, required this.email, required this.role, required this.password});
}

class AdminSale {
  String id; // Firestore ID
  double amount;
  String itemId;
  // Puedes añadir un timestamp si lo necesitas
  // Timestamp? timestamp;
  AdminSale({required this.id, required this.amount, required this.itemId /*, this.timestamp*/ });
}

class AdminTicket {
  String id; // Firestore ID
  String subject;
  String status;
  String orderId;
  AdminTicket({required this.id, required this.subject, required this.status, required this.orderId});
}

class AdminProduct {
  String id; // Firestore ID
  String name;
  int stock;
  // Puedes añadir más campos si los necesitas (descripción, precio, etc.)
  AdminProduct({required this.id, required this.name, required this.stock});
}

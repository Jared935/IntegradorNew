// data_models.dart
class User {
  String id; // ID de Firestore
  String name;
  String email;
  String role;
  String password; // CAMPO AÑADIDO
  User({required this.id, required this.name, required this.email, required this.role, required this.password});
}

class Sale {
  String id; // ID de Firestore
  double amount;
  String itemId;
  Sale({required this.id, required this.amount, required this.itemId});
}

class Ticket {
  String id; // ID de Firestore
  String subject;
  String status;
  String orderId;
  Ticket({required this.id, required this.subject, required this.status, required this.orderId});
}

class Product {
  String id; // ID de Firestore
  String name;
  int stock;
  Product({required this.id, required this.name, required this.stock});
}
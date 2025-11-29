// lib/data_models.dart

// --- Modelos de Admin (puedes dejarlos si los usas) ---
class User {
  String id;
  String name;
  String email;
  String role;
  String password;
  User({required this.id, required this.name, required this.email, required this.role, required this.password});
}

class Sale {
  String id;
  double amount;
  String itemId;
  Sale({required this.id, required this.amount, required this.itemId});
}

class Ticket {
  String id;
  String subject;
  String status;
  String orderId;
  Ticket({required this.id, required this.subject, required this.status, required this.orderId}); 
}

// --- MODELO PRODUCT UNIFICADO ---
// Esta clase será usada tanto por el admin panel como por la app de cliente.
class Product {
  String id;
  String name;
  int stock;
  String category;
  
  // Campos adicionales que tu UI de cliente necesita
  String description;
  double price;
  bool available;
  String imageUrl; // Para el emoji o URL de imagen

  Product({
    required this.id,
    required this.name,
    required this.stock,
    required this.category,
    
    // Valores por defecto para que no fallen al leer de Firebase si el campo no existe
    this.description = 'Sin descripción.',
    this.price = 0.0,
    this.available = true,
    this.imageUrl = '📦', // Un emoji de caja como placeholder
  });
}
// storage_service.dart
import 'dart:convert';
import 'data_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageService {

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';
  static const String _salesCollection = 'sales';
  static const String _ticketsCollection = 'tickets';
  static const String _productsCollection = 'products';

  // ====================================================================
  // 1. GUARDAR DATOS (CREATE/UPDATE)
  // ====================================================================

  static Future<void> _saveAll<T>(String collectionName, List<T> items, Map<String, dynamic> Function(T) toMap) async {
    final collection = _db.collection(collectionName);

    final existingDocs = await collection.get();
    for (var doc in existingDocs.docs) {
      await doc.reference.delete();
    }

    for (var item in items) {
      final data = toMap(item);
      await collection.add(data);
    }
  }

  static Future<void> saveUsers(List<User> users) async {
    Map<String, dynamic> userToMap(User user) => {
      'name': user.name,
      'email': user.email,
      'role': user.role,
      // ESTA LÍNEA ES LA CLAVE: se asegura de guardar la contraseña
      'password': user.password,
    };
    await _saveAll<User>(_usersCollection, users, userToMap);
  }

  static Future<void> saveSales(List<Sale> sales) async {
     Map<String, dynamic> saleToMap(Sale sale) => {
      'amount': sale.amount,
      'itemId': sale.itemId,
    };
    await _saveAll<Sale>(_salesCollection, sales, saleToMap);
  }

  static Future<void> saveTickets(List<Ticket> tickets) async {
     Map<String, dynamic> ticketToMap(Ticket ticket) => {
      'subject': ticket.subject,
      'status': ticket.status,
      'orderId': ticket.orderId,
    };
    await _saveAll<Ticket>(_ticketsCollection, tickets, ticketToMap);
  }

  static Future<void> saveProducts(List<Product> products) async {
    Map<String, dynamic> productToMap(Product product) => {
      'name': product.name,
      'stock': product.stock,
    };
    await _saveAll<Product>(_productsCollection, products, productToMap);
  }


  // ====================================================================
  // 2. OBTENER STREAMS DE DATOS (LECTURA EN TIEMPO REAL)
  // ====================================================================

  static Stream<List<User>> streamUsers() {
    return _db.collection(_usersCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return User(
            id: doc.id,
            name: data['name'] as String,
            email: data['email'] as String,
            role: data['role'] as String,
            // ESTA LÍNEA ES LA CLAVE: se asegura de leer la contraseña
            password: data['password'] as String,
          );
      }).toList();
    });
  }

  static Stream<List<Sale>> streamSales() {
    return _db.collection(_salesCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Sale(
          id: doc.id,
          amount: (data['amount'] as num).toDouble(),
          itemId: data['itemId'] as String,
        );
      }).toList();
    });
  }

  static Stream<List<Ticket>> streamTickets() {
    return _db.collection(_ticketsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Ticket(
          id: doc.id,
          subject: data['subject'] as String,
          status: data['status'] as String,
          orderId: data['orderId'] as String,
        );
      }).toList();
    });
  }

  static Stream<List<Product>> streamProducts() {
    return _db.collection(_productsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data['name'] as String,
          stock: (data['stock'] as num).toInt(),
        );
      }).toList();
    });
  }
}
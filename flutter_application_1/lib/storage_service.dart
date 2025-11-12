// lib/storage_service.dart (o la ruta donde lo tengas)
import 'package:cloud_firestore/cloud_firestore.dart';
// Asegúrate de que esta importación apunte a tu archivo de modelos correcto
import 'data_models.dart'; // Ajusta la ruta si es necesario

class StorageService {
  // Instancia principal de Firestore
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Nombres de las colecciones en Firebase
  static const String _usersCollection = 'users';
  static const String _salesCollection = 'sales';
  static const String _ticketsCollection = 'tickets';
  static const String _productsCollection = 'products';

  // ====================================================================
  // MÉTODOS DE MODIFICACIÓN (AÑADIR/BORRAR/ACTUALIZAR)
  // ====================================================================

  // --- Usuarios ---
  static Future<void> addUser(User user) async {
    print("🟠 [STORAGE] Intentando guardar usuario: ${user.email}");
    try {
      await _db.collection(_usersCollection).add({
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'password': user.password, // Asegura que se guarde 'password' en minúsculas
      });
      print("🟢 [STORAGE] Usuario guardado con éxito.");
    } catch (e) {
      print("🔴 [STORAGE] Error al guardar usuario: $e");
      rethrow;
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
       await _db.collection(_usersCollection).doc(userId).delete();
       print("🟢 [STORAGE] Usuario borrado con éxito.");
    } catch (e) {
       print("🔴 [STORAGE] Error al borrar usuario: $e");
    }
  }

  // --- Ventas ---
  static Future<void> addSale(Sale sale) async {
    await _db.collection(_salesCollection).add({
      'amount': sale.amount,
      'itemId': sale.itemId,
      'timestamp': FieldValue.serverTimestamp(), // Guarda la fecha/hora
    });
  }

  static Future<void> deleteSale(String saleId) async {
    await _db.collection(_salesCollection).doc(saleId).delete();
  }
  
  // --- Productos ---
  static Future<void> addProduct(Product product) async {
    await _db.collection(_productsCollection).add({
      'name': product.name,
      'stock': product.stock,
    });
  }

  static Future<void> deleteProduct(String productId) async {
    await _db.collection(_productsCollection).doc(productId).delete();
  }

  // --- Tickets ---
  static Future<void> addTicket(Ticket ticket) async {
    await _db.collection(_ticketsCollection).add({
      'subject': ticket.subject,
      'status': ticket.status,
      'orderId': ticket.orderId,
    });
  }

  static Future<void> deleteTicket(String ticketId) async {
    await _db.collection(_ticketsCollection).doc(ticketId).delete();
  }

  static Future<void> updateTicketStatus(String ticketId, String newStatus) async {
    await _db.collection(_ticketsCollection).doc(ticketId).update({'status': newStatus});
  }


  // ====================================================================
  // STREAMS DE DATOS (LECTURA EN TIEMPO REAL)
  // ====================================================================

  static Stream<List<User>> streamUsers() {
    return _db.collection(_usersCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return User(
          id: doc.id,
          name: data['name'] ?? '',
      
          email: data['email'] ?? '',
          role: data['role'] ?? 'Cliente', // Asigna 'Cliente' si el rol no existe
          password: data['password'] ?? '', // Lee 'password' en minúsculas
        );
      }).toList();
    });
  }

  static Stream<List<Sale>> streamSales() {
    return _db.collection(_salesCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Sale(
          id: doc.id,
          amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
          itemId: data['itemId'] ?? '',
        );
      }).toList();
    });
  }

  static Stream<List<Ticket>> streamTickets() {
    return _db.collection(_ticketsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Ticket(
          id: doc.id,
          subject: data['subject'] ?? '',
          status: data['status'] ?? 'Abierto',
          orderId: data['orderId'] ?? '',
        );
      }).toList();
    });
  }

  static Stream<List<Product>> streamProducts() {
    return _db.collection(_productsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'] ?? '',
          stock: (data['stock'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    });
  }

  static Future<void> saveProducts(List<Product> storageProducts) async {}

  static Future<void> saveSales(List<Sale> storageSales) async {}

  static Future<void> saveTickets(List<Ticket> storageTickets) async {}

  static Future<void> saveUsers(List<User> storageUsers) async {}
}
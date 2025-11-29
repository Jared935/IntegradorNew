import 'package:cloud_firestore/cloud_firestore.dart';
import 'data_models.dart';

class StorageService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';
  static const String _salesCollection = 'sales';
  static const String _ticketsCollection = 'tickets';
  static const String _productsCollection = 'products';

  // --- MODIFICACIÓN CLAVE EN EL STREAM DE USUARIOS ---
  static Stream<List<User>> streamUsers() {
    return _db.collection(_usersCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        // LÓGICA DE COMPATIBILIDAD:
        // 1. Intenta leer 'password'
        // 2. Si no existe, intenta leer 'Contraseña'
        // 3. Si no existe, devuelve cadena vacía
        String password = data['password']?.toString() ?? data['Contraseña']?.toString() ?? '';

        return User(
          id: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          role: data['role'] ?? 'Cliente',
          password: password, // <--- Aquí usamos la variable compatible
        );
      }).toList();
    });
  }

  // --- MÉTODOS DE GUARDADO (Usaremos el estándar nuevo 'password') ---
  static Future<void> addUser(User user) async {
    await _db.collection(_usersCollection).add({
      'name': user.name,
      'email': user.email,
      'role': user.role,
      'password': user.password, // Los nuevos se guardan bien
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // ... (El resto de tus métodos: deleteUser, addSale, streamProducts, etc. siguen igual)
  
  static Future<void> deleteUser(String userId) async {
    await _db.collection(_usersCollection).doc(userId).delete();
  }

  // ... Mantén el resto de tus streams y métodos de productos/ventas aquí ...
  // (Si necesitas que te pegue el archivo COMPLETO con todo lo demás, dímelo)
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
          category: data['category'] ?? 'Sin categoría',
          description: data['description'] ?? 'Sin descripción.',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          available: data['available'] ?? false,
          imageUrl: data['imageUrl'] ?? '📦',
        );
      }).toList();
    });
  }
    // Stream de productos FILTRADOS POR CATEGORÍA (Actualizado)
  static Stream<List<Product>> streamProductsByCategory(String category) {
    return _db
        .collection(_productsCollection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'] ?? '',
          stock: (data['stock'] as num?)?.toInt() ?? 0,
          category: data['category'] ?? '',
          description: data['description'] ?? 'Sin descripción.',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          available: data['available'] ?? false,
          imageUrl: data['imageUrl'] ?? '📦',
        );
      }).toList();
    });
  }

  static Future<void> addProduct(Product product) async {
    try {
      await _db.collection(_productsCollection).add({
        'name': product.name,
        'stock': product.stock,
        'category': product.category,
        'description': product.description,
        'price': product.price,
        'available': product.available,
        'imageUrl': product.imageUrl,
      });
    } catch (e) {
       print("Error al guardar producto: $e");
    }
  }
    static Future<void> deleteProduct(String productId) async {
    await _db.collection(_productsCollection).doc(productId).delete();
  }

  static Future<void> saveProducts(List<Product> storageProducts) async {}

  static Future<void> saveSales(List<Sale> storageSales) async {}

  static Future<void> saveTickets(List<Ticket> storageTickets) async {}

}
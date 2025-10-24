import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductsProvider with ChangeNotifier {
  final List<Product> _products = [
    // DESAYUNOS
    Product(
      id: '1',
      name: 'Huevos Revueltos',
      description: 'Huevos revueltos con jamon, frijoles y pan tostado',
      price: 80.00,
      imageUrl: '🥚',
      category: 'Desayunos',
      available: true,
    ),
    Product(
      id: '2',
      name: 'Chilaquiles Verdes',
      description: 'Chilaquiles con pollo, crema y queso fresco',
      price: 75.00,
      imageUrl: '🍲',
      category: 'Desayunos',
      available: true,
    ),
    Product(
      id: '3',
      name: 'Omelette Espinacas',
      description: 'Omelette con espinacas, champiñones y queso',
      price: 70.00,
      imageUrl: '🍳',
      category: 'Desayunos',
      available: true,
    ),
    Product(
      id: '4',
      name: 'Hot Cakes',
      description: 'Tres hot cakes con mantequilla y miel',
      price: 60.00,
      imageUrl: '🥞',
      category: 'Desayunos',
      available: false,
    ),

    // ALMUERZOS
    Product(
      id: '5',
      name: 'Sandwich Club',
      description: 'Sandwich de pollo, tocino, aguacate y mayonesa',
      price: 65.00,
      imageUrl: '🥪',
      category: 'Almuerzos',
      available: true,
    ),
    Product(
      id: '6',
      name: 'Ensalada César',
      description: 'Ensalada con pollo, crutones y aderezo cesar',
      price: 55.00,
      imageUrl: '🥗',
      category: 'Almuerzos',
      available: true,
    ),
    Product(
      id: '7',
      name: 'Quesadillas',
      description: 'Tres quesadillas de queso con guacamole',
      price: 45.00,
      imageUrl: '🌯',
      category: 'Almuerzos',
      available: true,
    ),

    // COMIDAS
    Product(
      id: '8',
      name: 'Pasta Alfredo',
      description: 'Pasta con salsa cremosa de pollo y champiñones',
      price: 95.00,
      imageUrl: '🍝',
      category: 'Comidas',
      available: true,
    ),
    Product(
      id: '9',
      name: 'Pechuga a la Plancha',
      description: 'Pechuga de pollo con verduras al vapor',
      price: 85.00,
      imageUrl: '🍗',
      category: 'Comidas',
      available: true,
    ),
    Product(
      id: '10',
      name: 'Hamburguesa Clásica',
      description: 'Hamburguesa con carne, queso, lechuga y tomate',
      price: 75.00,
      imageUrl: '🍔',
      category: 'Comidas',
      available: false,
    ),

    // BEBIDAS
    Product(
      id: '11',
      name: 'Cafe Americano',
      description: 'Cafe negro tradicional',
      price: 25.00,
      imageUrl: '☕',
      category: 'Bebidas',
      available: true,
    ),
    Product(
      id: '12',
      name: 'Capuchino',
      description: 'Cafe con leche espumosa y canela',
      price: 35.00,
      imageUrl: '☕',
      category: 'Bebidas',
      available: true,
    ),
    Product(
      id: '13',
      name: 'Chocolate Caliente',
      description: 'Chocolate caliente cremoso con malvaviscos',
      price: 30.00,
      imageUrl: '🍫',
      category: 'Bebidas',
      available: true,
    ),
    Product(
      id: '14',
      name: 'Jugo de Naranja',
      description: 'Jugo de naranja natural recien exprimido',
      price: 20.00,
      imageUrl: '🍊',
      category: 'Bebidas',
      available: true,
    ),

    // POSTRES
    Product(
      id: '15',
      name: 'Pay de Queso',
      description: 'Delicioso pay de queso estilo Nueva York',
      price: 45.00,
      imageUrl: '🍰',
      category: 'Postres',
      available: true,
    ),
    Product(
      id: '16',
      name: 'Flan Napolitano',
      description: 'Flan casero con caramelo',
      price: 35.00,
      imageUrl: '🍮',
      category: 'Postres',
      available: true,
    ),
    Product(
      id: '17',
      name: 'Galletas de Chocolate',
      description: 'Galletas con chispas de chocolate negro',
      price: 25.00,
      imageUrl: '🍪',
      category: 'Postres',
      available: true,
    ),
  ];

  List<Product> get products => List.unmodifiable(_products);

  List<Product> get availableProducts =>
      _products.where((product) => product.available).toList();

  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  List<String> get categories {
    return _products.map((product) => product.category).toSet().toList();
  }

  Product getProductById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return availableProducts;

    return _products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) &&
              product.available,
        )
        .toList();
  }
}

import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.fold(0, (sum, item) => sum + item.total);

  // se agregar producto al carrito
  void addProduct(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      // incrementar cantidad si ya existe
      _items[index].increment();
    } else {
      // sino agrega nuevo item
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  // remueve el producto del carrito
  void removeProduct(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // incrementa cantidad
  void incrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].increment();
      notifyListeners();
    }
  }

  // quita cantidad
  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].decrement();
      if (_items[index].quantity == 0) {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // vacia el carrito
  void clear() {
    _items.clear();
    notifyListeners();
  }

  // verifica si un producto esta en el carrito
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  //  cantidad de un producto especifico
  int getProductQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse:
          () => CartItem(
            product: Product(
              id: '',
              name: '',
              description: '',
              price: 0,
              imageUrl: '',
              category: '',
              available: true,
            ),
            quantity: 0,
          ),
    );
    return item.quantity;
  }
}

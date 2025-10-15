// products_screen.dart
import 'package:flutter/material.dart';
import 'storage_service.dart'; 
import 'data_models.dart' as data_models; 

class Product {
  String name;
  int stock;
  Product(this.name, this.stock);
}

class ProductsDataService {
  static final List<Product> _products = [];

  static int get totalStockCount {
    return _products.fold(0, (sum, product) => sum + product.stock);
  }
  
  static final Stream<List<Product>> productStream = StorageService.streamProducts().map((loadedProducts) {
    _products.clear();
    final screenProducts = loadedProducts.map((p) => Product(p.name, p.stock)).toList();
    _products.addAll(screenProducts);
    return screenProducts;
  });

  static Future<void> initialize() async {}
  
  static Future<void> save() async {
    final storageProducts = _products.map((p) => data_models.Product(
      id: '', 
      name: p.name,
      stock: p.stock,
    )).toList();
    await StorageService.saveProducts(storageProducts);
  }
}


class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {

  void _deleteProduct(int index) {
    ProductsDataService._products.removeAt(index);
    ProductsDataService.save();
  }

  void _addProduct() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Añadir Nuevo Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Producto'),
              ),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock Inicial'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              onPressed: () {
                final String name = nameController.text;
                final int? stock = int.tryParse(stockController.text);

                if (name.isNotEmpty && stock != null && stock >= 0) {
                  ProductsDataService._products.add(Product(name, stock));
                  ProductsDataService.save(); 
                  Navigator.of(context).pop();
                } else {
                  print("Datos inválidos"); 
                }
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder<List<Product>>(
        stream: ProductsDataService.productStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
          }
          final liveProducts = snapshot.data ?? [];
          
          if (liveProducts.isEmpty) {
            return const Center(child: Text('No hay productos registrados.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: liveProducts.length,
            itemBuilder: (context, index) {
              final product = liveProducts[index];
              
              final bool isLowStock = product.stock < 100;
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.inventory_2, color: Colors.indigo),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ID: #00${index + 1}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isLowStock ? Colors.orange.shade100 : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'Stock: ${product.stock}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isLowStock ? Colors.orange.shade900 : Colors.green.shade900,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteProduct(index); 
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        tooltip: 'Añadir Producto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
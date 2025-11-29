import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'data_models.dart' as data_models;

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {

  void _deleteProduct(String productId) {
    StorageService.deleteProduct(productId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado')),
    );
  }

  void _addProduct() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController stockController = TextEditingController();
    // NUEVO: Controlador para categoría
    // Si quieres una lista desplegable, podemos cambiarlo después.
    // Por ahora, lo ponemos fijo o por defecto.
    
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              onPressed: () {
                final String name = nameController.text.trim();
                final int? stock = int.tryParse(stockController.text);

                if (name.isNotEmpty && stock != null && stock >= 0) {
                  // 1. Crear objeto
                  final newProduct = data_models.Product(
                    id: '',
                    name: name,
                    stock: stock,
                    category: 'General', // Valor por defecto o agrega un input
                    // Añade los otros campos si tu modelo los requiere (price, description...)
                    price: 0.0,
                    description: '',
                  );

                  // 2. Guardar en Firebase
                  StorageService.addProduct(newProduct);
                  
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Producto $name añadido')),
                  );
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
        backgroundColor: Colors.indigo, // Ajusta a tu color preferido
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<data_models.Product>>(
        stream: StorageService.streamProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
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
              final bool isLowStock = product.stock < 10; // Umbral de alerta
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.inventory_2, color: Colors.indigo),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Stock: ${product.stock}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLowStock)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text("BAJO", style: TextStyle(color: Colors.orange.shade900, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product.id),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
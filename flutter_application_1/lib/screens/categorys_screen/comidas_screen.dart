import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models.dart';
import 'package:flutter_application_1/storage_service.dart';

class ComidasScreen extends StatelessWidget {
  const ComidasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comidas'),
        backgroundColor: Colors.brown,
      ),
      body: StreamBuilder<List<Product>>(
        // 1. Filtra por "Comida"
        stream: StorageService.streamProductsByCategory('Comida'),
        
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar productos: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No hay comidas disponibles por el momento.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.restaurant_menu, color: Colors.blue),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Stock disponible: ${product.stock}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                    onPressed: () {
                      // Lógica para añadir al carrito
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
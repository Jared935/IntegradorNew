// lib/screens/categorys_screen/desayunos_screes.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models.dart'; // Importa tus modelos
import 'package:flutter_application_1/storage_service.dart'; // Importa tu servicio

class DesayunosScreen extends StatelessWidget {
  const DesayunosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desayunos'),
        backgroundColor: Colors.brown, // O el color que prefieras
      ),
      body: StreamBuilder<List<Product>>(
        // 1. Llama a la nueva función de stream filtrando por "Desayuno"
        stream: StorageService.streamProductsByCategory('Desayuno'),
        
        builder: (context, snapshot) {
          // 2. Maneja los diferentes estados del stream
          
          // Estado de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Estado de error
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar productos: ${snapshot.error}'));
          }
          
          // Estado sin datos (lista vacía)
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No hay desayunos disponibles por el momento.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          
          // 3. Estado con datos: Muestra la lista
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              
              // Esta es la tarjeta que muestra cada producto.
              // Puedes personalizarla como quieras.
              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.breakfast_dining, color: Colors.orange),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Stock disponible: ${product.stock}'),
                  // (Aquí podrías poner el precio: Text('\$${product.price}'))
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                    onPressed: () {
                      // Lógica para añadir al carrito
                      // (Probablemente llamarías a tu CartProvider aquí)
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
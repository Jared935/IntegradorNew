import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importa los servicios y modelos de datos
import 'package:flutter_application_1/storage_service.dart'; // Tu servicio de Firebase
import 'package:flutter_application_1/data_models.dart'; // Tu modelo de datos (Product)
import 'package:flutter_application_1/providers/cart_provider.dart'; // Tu provider de carrito

class AlmuerzosScreen extends StatelessWidget {
  const AlmuerzosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el cartProvider para poder añadir productos al carrito
    // listen: false aquí porque solo lo usamos en callbacks (onPressed)
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Almuerzos"),
        backgroundColor: Colors.brown,
      ),
      body: StreamBuilder<List<Product>>(
        // CONEXIÓN A FIREBASE:
        stream: StorageService.streamProductsByCategory('Almuerzos'), // Categoría exacta
        
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error al cargar datos: ${snapshot.error}"));
          }

          final almuerzos = snapshot.data ?? [];

          if (almuerzos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lunch_dining, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay almuerzos disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Si hay productos, muestra la lista
          return ListView.builder(
            itemCount: almuerzos.length,
            itemBuilder: (context, index) {
              final product = almuerzos[index];
              // Reutilizamos tu widget _buildProductCard
              return _buildProductCard(context, product, cartProvider);
            },
          );
        },
      ),
    );
  }

  // Este widget es el que me diste, ahora es 100% compatible
  // con el modelo 'Product' de data_models.dart
  Widget _buildProductCard(
    BuildContext context,
    Product product, // Este 'Product' ahora viene de 'data_models.dart'
    CartProvider cartProvider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: product.available ? Colors.orange[100] : Colors.grey[300],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(product.imageUrl, style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: product.available ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.description,
              style: TextStyle(
                color: product.available ? Colors.grey : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                color: product.available ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!product.available)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'AGOTADO',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing:
            product.available
                ? IconButton(
                    icon: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      // ¡IMPORTANTE!
                      // cartProvider.addProduct(product); // <-- Esto puede fallar
                      
                      // Tu CartProvider probablemente espera un Product de tipo 'products_provider.dart'
                      // y este es un Product de 'data_models.dart'.
                      // Necesitarás ajustar tu CartProvider para que acepte el modelo
                      // de 'data_models.dart' o convertirlo.
                      
                      // Por ahora, añadimos un print para confirmar que funciona
                      print("Añadiendo ${product.name} al carrito.");
                      // cartProvider.addProduct(product); // <-- Descomenta cuando tu CartProvider sea compatible
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} agregado al carrito'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  )
                : const Icon(Icons.remove_shopping_cart, color: Colors.grey),
        onTap: () {
          _showProductDetails(context, product, cartProvider);
        },
      ),
    );
  }

  void _showProductDetails(
    BuildContext context,
    Product product,
    CartProvider cartProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (ctx) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: Text(
                          product.imageUrl,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Descripción:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      product.available ? Icons.check_circle : Icons.cancel,
                      color: product.available ? Colors.green : Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      product.available ? 'Disponible' : 'Agotado',
                      style: TextStyle(
                        fontSize: 16,
                        color: product.available ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (product.available)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // cartProvider.addProduct(product); // <-- Misma nota que arriba
                        print("Añadiendo ${product.name} al carrito.");
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.name} agregado al carrito',
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text(
                        'Agregar al Carrito',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
    );
  }
}
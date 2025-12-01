import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'data_models.dart' as data_models;

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {

  void _deleteSale(String saleId) {
    StorageService.deleteSale(saleId);
  }

  void _addSale() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController itemIdController = TextEditingController(); 

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registrar Nueva Venta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: itemIdController,
                decoration: const InputDecoration(labelText: 'ID del Artículo'),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Monto Total (\$)', prefixText: '\$'),
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
                final String itemId = itemIdController.text.trim();
                final double? amount = double.tryParse(amountController.text);

                if (itemId.isNotEmpty && amount != null && amount > 0) {
                  // 1. Crear objeto
                  final newSale = data_models.Sale(
                    id: '', 
                    amount: amount, 
                    itemId: itemId
                  );
                  
                  // 2. Guardar en Firebase
                  StorageService.addSale(newSale);
                  
                  Navigator.of(context).pop();
                } 
              },
              child: const Text('Registrar'),
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
        title: const Text('Gestión de Ventas Diarias'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<data_models.Sale>>(
        stream: StorageService.streamSales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final liveSales = snapshot.data ?? [];
          
          if (liveSales.isEmpty) {
            return const Center(child: Text('No hay ventas registradas.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: liveSales.length,
            itemBuilder: (context, index) {
              final sale = liveSales[index];
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.shopping_cart, color: Colors.blue),
                  title: Text(
                    'Venta #${sale.id.substring(0, 6)}...', // ID corto
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Artículo: ${sale.itemId}'), 
                  
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${sale.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSale(sale.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSale,
        label: const Text('Registrar Venta'),
        icon: const Icon(Icons.add_shopping_cart),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
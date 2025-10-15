// sales_screen.dart
import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'data_models.dart' as data_models;

class Sale {
  String id;
  double amount;
  String itemId; 
  Sale(this.id, this.amount, this.itemId);
}

class SalesDataService {
  static final List<Sale> _sales = []; 
  
  static List<Sale> get saleList => _sales;
  static double get totalSalesAmount {
    return _sales.fold(0.0, (sum, sale) => sum + sale.amount);
  }

  static final Stream<List<Sale>> saleStream = StorageService.streamSales().map((loadedSales) {
    _sales.clear();
    final screenSales = loadedSales.map((s) => Sale(s.id, s.amount, s.itemId)).toList();
    _sales.addAll(screenSales);
    return screenSales;
  });

  static Future<void> initialize() async {} 
  
  static Future<void> save() async {
    final storageSales = _sales.map((s) => data_models.Sale(id: s.id, amount: s.amount, itemId: s.itemId)).toList();
    await StorageService.saveSales(storageSales);
  }
}

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState(); 
}

class _SalesScreenState extends State<SalesScreen> {

  void _deleteSale(int index) {
    final deletedSale = SalesDataService._sales.removeAt(index);
    
    SalesDataService.save(); 

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Venta ${deletedSale.id} eliminada.'),
        action: SnackBarAction(
          label: 'DESHACER',
          onPressed: () {
            SalesDataService._sales.insert(index, deletedSale);
            SalesDataService.save();
          },
        ),
      ),
    );
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
                keyboardType: TextInputType.number,
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
                final String itemId = itemIdController.text;
                final double? amount = double.tryParse(amountController.text);

                if (itemId.isNotEmpty && amount != null && amount > 0) {
                  String newId = 'V-202500${SalesDataService._sales.length + 1}';
                  SalesDataService._sales.add(Sale(newId, amount, itemId)); 
                  SalesDataService.save();
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
      ),
      body: StreamBuilder<List<Sale>>(
        stream: SalesDataService.saleStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
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
                    'Venta #${sale.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Artículo ID: ${sale.itemId}'), 
                  
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${sale.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteSale(index); 
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSale,
        label: const Text('Registrar Venta'),
        icon: const Icon(Icons.add_shopping_cart),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
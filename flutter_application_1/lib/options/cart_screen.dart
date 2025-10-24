import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    if (cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Carrito de Compras"),
          backgroundColor: Colors.brown,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              const Text(
                "Tu carrito está vacío",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Agrega algunos productos deliciosos",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.shopping_bag),
                label: const Text("Explorar Menú"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrito de Compras"),
        backgroundColor: Colors.brown,
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                _showClearCartDialog(context, cart);
              },
              tooltip: 'Vaciar carrito',
            ),
        ],
      ),
      body: Column(
        children: [
          // Header con resumen
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.orange[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${cart.itemCount} ${cart.itemCount == 1 ? 'producto' : 'productos'}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      "Total: \$${cart.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "\$${cart.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de productos
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return _buildCartItem(context, item, cart, index);
              },
            ),
          ),

          // Footer con acciones
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Resumen de precios
                _buildPriceSummary(cart),
                const SizedBox(height: 16),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text("Seguir Comprando"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showOrderConfirmation(context, cart);
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text("Pagar Ahora"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    CartProvider cart,
    int index,
  ) {
    return Dismissible(
      key: Key(item.product.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteDialog(context, item.product.name);
      },
      onDismissed: (_) => cart.removeProduct(item.product.id),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                item.product.imageUrl,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          title: Text(
            item.product.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "\$${item.product.price.toStringAsFixed(2)} c/u",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón disminuir
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () => cart.decrementQuantity(item.product.id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),

                  // Cantidad
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Botón aumentar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => cart.incrementQuantity(item.product.id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "\$${item.total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSummary(CartProvider cart) {
    final subtotal = cart.totalAmount;
    const taxRate = 0.16; // 16% de IVA
    final tax = subtotal * taxRate;
    final total = subtotal + tax;

    return Column(
      children: [
        _buildPriceRow("Subtotal", subtotal),
        _buildPriceRow("IVA (16%)", tax),
        const Divider(),
        _buildPriceRow("Total", total, isTotal: true),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.brown : Colors.grey,
            ),
          ),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteDialog(
    BuildContext context,
    String productName,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text("Eliminar Producto"),
                content: Text(
                  "¿Estás seguro de que quieres eliminar $productName del carrito?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text("Cancelar"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text("Eliminar"),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showClearCartDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Vaciar Carrito"),
            content: const Text(
              "¿Estás seguro de que quieres vaciar todo el carrito?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  cart.clear();
                  Navigator.of(ctx).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Vaciar Todo"),
              ),
            ],
          ),
    );
  }

  void _showOrderConfirmation(BuildContext context, CartProvider cart) {
    final total = cart.totalAmount * 1.16; // Incluye IVA

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.payment, color: Colors.orange),
                SizedBox(width: 8),
                Text("Confirmar Pedido"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen del pedido:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('• ${cart.itemCount} productos'),
                Text('• Total: \$${total.toStringAsFixed(2)} (IVA incluido)'),
                const SizedBox(height: 16),
                const Text(
                  '¿Cómo deseas pagar?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildPaymentOption(
                  ctx,
                  cart,
                  'transferencia',
                  'Transferencia Bancaria',
                  'Paga por transferencia y muestra el comprobante',
                  Icons.account_balance,
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildPaymentOption(
                  ctx,
                  cart,
                  'presencial',
                  'Pago Presencial',
                  'Paga cuando recojas tu pedido en la cafetería',
                  Icons.store,
                  Colors.blue,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancelar"),
              ),
            ],
          ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    CartProvider cart,
    String method,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).pop();
          _processOrder(context, cart, method);
        },
      ),
    );
  }

  void _processOrder(
    BuildContext context,
    CartProvider cart,
    String paymentMethod,
  ) {
    final total = cart.totalAmount * 1.16;
    final message =
        paymentMethod == 'transferencia'
            ? '✅ Pedido confirmado!\n\nRealiza la transferencia a:\n• Banco: BBVA\n• Cuenta: 1234 5678 9012\n• CLABE: 012 180 123456789012\n• Beneficiario: WolfCoffee\n\nMonto: \$${total.toStringAsFixed(2)}\n\nMuestra el comprobante al recoger tu pedido.'
            : '✅ Pedido confirmado!\n\nTu pedido estará listo en aproximadamente 15-20 minutos.\n\nTotal a pagar: \$${total.toStringAsFixed(2)}\n\nPaga al recoger en la cafetería.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text("¡Pedido Confirmado!"),
              ],
            ),
            content: SingleChildScrollView(child: Text(message)),
            actions: [
              TextButton(
                onPressed: () {
                  cart.clear();
                  Navigator.of(ctx).popUntil((route) => route.isFirst);
                },
                child: const Text("Aceptar"),
              ),
            ],
          ),
    );
  }
}

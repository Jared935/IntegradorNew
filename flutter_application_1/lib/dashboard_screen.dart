import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'storage_service.dart';
import 'data_models.dart' as data_models;
import 'widgets/info_card.dart'; // Asegúrate de tener este widget

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Administrativo'),
        automaticallyImplyLeading: !isLargeScreen,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: isLargeScreen ? null : const SidebarMenu(),
      body: Row(
        children: [
          if (isLargeScreen) const SidebarMenu(),
          const Expanded(
            child: MainContent(),
          ),
        ],
      ),
    );
  }
}

// --- MENÚ LATERAL (FUNCIONAL) ---
class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text('Menú Admin', style: TextStyle(color: Colors.white, fontSize: 24)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
            },
          ),
          
          // --- BOTONES DE GESTIÓN ---
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Ventas'),
            onTap: () {
              if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              Navigator.pushNamed(context, '/admin_sales'); // Navega a Ventas
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Productos'),
            onTap: () {
              if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              Navigator.pushNamed(context, '/admin_products'); // Navega a Productos
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Tickets'),
            onTap: () {
              if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              Navigator.pushNamed(context, '/admin_tickets'); // Navega a Tickets
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Usuarios'),
            onTap: () {
              if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              Navigator.pushNamed(context, '/admin_users'); // Navega a Usuarios
            },
          ),
          
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
            child: Text('Ajustes', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ),

          const ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configuración'),
          ),
          
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              // Navega al login de CLIENTES (o donde prefieras) y borra historial
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/customer_login', 
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- CONTENIDO PRINCIPAL (CLICKEABLE) ---
class MainContent extends StatelessWidget {
  const MainContent({super.key});

  List<BarChartGroupData> _buildBarGroups(List<data_models.Sale> salesData) {
    final recentSales = salesData.length > 4 ? salesData.sublist(salesData.length - 4) : salesData;
    return List.generate(recentSales.length, (i) {
      final sale = recentSales[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: sale.amount / 100,
            color: Colors.blue.shade300,
            width: 20,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del Sistema',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Grid de Tarjetas
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1100 ? 4 : 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            shrinkWrap: true,
            childAspectRatio: 1.5,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // 1. Tarjeta Usuarios
              StreamBuilder<List<data_models.User>>(
                stream: StorageService.streamUsers(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/admin_users'),
                    child: InfoCard(title: 'Usuarios Registrados', value: count.toString(), icon: Icons.person_add, color: Colors.green),
                  );
                },
              ),
              // 2. Tarjeta Ventas
              StreamBuilder<List<data_models.Sale>>(
                stream: StorageService.streamSales(),
                builder: (context, snapshot) {
                  final sales = snapshot.data ?? [];
                  final total = sales.fold(0.0, (sum, sale) => sum + sale.amount);
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/admin_sales'),
                    child: InfoCard(title: 'Ventas Diarias', value: '\$${total.toStringAsFixed(2)}', icon: Icons.monetization_on, color: Colors.blue),
                  );
                },
              ),
              // 3. Tarjeta Tickets
              StreamBuilder<List<data_models.Ticket>>(
                stream: StorageService.streamTickets(),
                builder: (context, snapshot) {
                  final tickets = snapshot.data ?? [];
                  final count = tickets.where((t) => t.status != 'Cerrado').length;
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/admin_tickets'),
                    child: InfoCard(title: 'Tickets Pendientes', value: count.toString(), icon: Icons.warning, color: Colors.orange),
                  );
                },
              ),
              // 4. Tarjeta Productos
              StreamBuilder<List<data_models.Product>>(
                stream: StorageService.streamProducts(),
                builder: (context, snapshot) {
                  final products = snapshot.data ?? [];
                  final count = products.fold(0, (sum, p) => sum + p.stock);
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/admin_products'),
                    child: InfoCard(title: 'Productos en Stock', value: count.toString(), icon: Icons.inventory, color: Colors.red),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          const Text('Gráfico de Ventas Recientes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          
          Container(
            height: 300,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
            child: StreamBuilder<List<data_models.Sale>>(
              stream: StorageService.streamSales(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final sales = snapshot.data ?? [];
                // Evitar división por cero o max=0
                final maxAmount = sales.isEmpty ? 10.0 : sales.map((s) => s.amount).fold(0.0, (a, b) => a > b ? a : b);
                final maxY = (maxAmount / 100).ceilToDouble() * 1.2;
                final safeMaxY = maxY > 0 ? maxY : 10.0;

                return BarChart(
                  BarChartData(
                    maxY: safeMaxY,
                    alignment: BarChartAlignment.spaceAround,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) => Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('Venta ${value.toInt() + 1}', style: const TextStyle(fontSize: 10))))),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text(value == 0 ? '\$0' : '\$${(value * 100).toInt()}', style: const TextStyle(fontSize: 10)))),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    barGroups: _buildBarGroups(sales),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
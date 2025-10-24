// dashboard_screen.dart
import 'package:flutter/material.dart';
// Importamos la librería de gráficos
import 'package:fl_chart/fl_chart.dart'; 

import 'products_screen.dart'; // Contiene ProductsDataService.totalStockCount
import 'sales_screen.dart';    
import 'tickets_screen.dart';  
import 'users_screen.dart';    
import 'widgets/info_card.dart';
import 'admin_login.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _userCount = 0; 
  double _salesAmount = 0.0; 
  int _pendingTickets = 0; 
  // VARIABLE: Para almacenar el stock total
  int _totalStock = 0; 

  @override
  void initState() {
    super.initState();
    _updateAllCounts();
  }
  
  void _updateAllCounts() {
    if (!mounted) return; 

    setState(() {
      _userCount = UsersDataService.userCount;
      _salesAmount = SalesDataService.totalSalesAmount;
      _pendingTickets = TicketsDataService.pendingTicketsCount; 
      // CLAVE: Obtener el stock total dinámico (donde marcaba el error)
      _totalStock = ProductsDataService.totalStockCount; 
    });
  }

  void _navigateTo(BuildContext context, Widget screen) async {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    if (!isLargeScreen) {
      Navigator.pop(context);
    }
    
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    
    _updateAllCounts();
  }
  
  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false, 
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Administrativo'),
        automaticallyImplyLeading: !isLargeScreen, 
      ),
      drawer: isLargeScreen ? null : SidebarMenu(navigateTo: _navigateTo, logout: _logout),
      body: Row(
        children: [
          if (isLargeScreen) SidebarMenu(navigateTo: _navigateTo, logout: _logout),
          Expanded(
            child: MainContent(
              userCount: _userCount, 
              salesAmount: _salesAmount, 
              pendingTickets: _pendingTickets,
              salesData: SalesDataService.saleList, 
              totalStock: _totalStock, 
              navigateTo: _navigateTo,
            ),
          ),
        ],
      ),
    );
  }
}

// Simple fallback LoginScreen widget in case the imported admin_login.dart
// doesn't define LoginScreen. This prevents the compile error.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(child: Text('Login screen placeholder')),
    );
  }
}

// SidebarMenu (Sin cambios)
class SidebarMenu extends StatelessWidget {
  final Function(BuildContext, Widget) navigateTo;
  final Function(BuildContext) logout; 
  
  const SidebarMenu({super.key, required this.navigateTo, required this.logout});

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
            child: Text('Menú Admin', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              if (MediaQuery.of(context).size.width <= 600) {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Ventas'),
            onTap: () => navigateTo(context, const SalesScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Productos'),
            onTap: () => navigateTo(context, const ProductsScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Tickets'),
            onTap: () => navigateTo(context, const TicketsScreen()),
          ),
          ListTile( 
            leading: const Icon(Icons.people),
            title: const Text('Usuarios'),
            onTap: () => navigateTo(context, const UsersScreen()),
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
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () => logout(context), 
          ),
        ],
      ),
    );
  }
}

// MainContent (Sin cambios, ya que recibe la variable)
class MainContent extends StatelessWidget {
  final int userCount;
  final double salesAmount;
  final int pendingTickets;
  final List<Sale> salesData; 
  final Function(BuildContext, Widget) navigateTo;
  final int totalStock;
  
  const MainContent({
    super.key, 
    required this.userCount, 
    required this.salesAmount, 
    required this.pendingTickets,
    required this.salesData, 
    required this.navigateTo,
    required this.totalStock
  });

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
  
  // FUNCIÓN PARA GENERAR LOS DATOS DE LA GRÁFICA DE BARRAS (Sin cambios)
  List<BarChartGroupData> _buildBarGroups() {
    final recentSales = salesData.reversed.take(4).toList();
    
    return List.generate(recentSales.length, (i) {
      final sale = recentSales[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: sale.amount / 100, 
            color: Colors.blue.shade300,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxAmount = salesData.map((s) => s.amount).fold(0.0, (a, b) => a > b ? a : b);
    final maxChartValue = (maxAmount / 100).ceilToDouble() * 1.2; 

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
            crossAxisCount: MediaQuery.of(context).size.width ~/ 300,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              GestureDetector(
                onTap: () => navigateTo(context, const UsersScreen()),
                child: InfoCard(
                  title: 'Usuarios Registrados', 
                  value: userCount.toString(), 
                  icon: Icons.person_add, 
                  color: Colors.green
                ),
              ),
              GestureDetector(
                onTap: () => navigateTo(context, const SalesScreen()),
                child: InfoCard(
                  title: 'Ventas Diarias', 
                  value: _formatCurrency(salesAmount), 
                  icon: Icons.monetization_on, 
                  color: Colors.blue
                ),
              ),
              GestureDetector(
                onTap: () => navigateTo(context, const TicketsScreen()),
                child: InfoCard(
                    title: 'Tickets Pendientes', 
                    value: pendingTickets.toString(), 
                    icon: Icons.warning, 
                    color: Colors.orange,
                ),
              ),
              GestureDetector(
                onTap: () => navigateTo(context, const ProductsScreen()),
                child: InfoCard(
                  title: 'Productos en Stock',
                  value: totalStock.toString(), 
                  icon: Icons.inventory,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            'Gráfico de Ventas Recientes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          
          Container(
            height: 300,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: BarChart(
              BarChartData(
                maxY: maxChartValue > 0 ? maxChartValue : 5,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Venta ${value.toInt() + 1}', style: const TextStyle(fontSize: 10)));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('\$0');
                        return Text('\$${(value * 100).toInt()}', style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                barGroups: _buildBarGroups(), 
              ),
            ),
          ),
        ],
      ),
    );
  }
}
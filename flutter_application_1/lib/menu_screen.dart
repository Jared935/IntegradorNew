// menu_screen.dart (de WolfCoffe)
import 'package:flutter/material.dart';
import '../widgets/category_tile.dart';
import '../widgets/cart_badge.dart';

// Importa la pantalla del Dashboard del Admin App
// Asegúrate de que la ruta sea correcta según tu estructura de carpetas
import 'dashboard_screen.dart'; // ¡Ajusta esta ruta!

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       // ... (AppBar y Body no cambian) ...
      backgroundColor: Colors.orange[50],
      appBar: AppBar( /* ... tu AppBar ... */ ),
      drawer: _buildDrawer(context), // El drawer ahora tendrá la opción Admin
      body: _buildBody(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header del drawer (sin cambios)
          Container( /* ... Tu header ... */),

          // Opciones del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, Icons.home, 'Inicio', () => Navigator.pop(context)),
                _buildDrawerItem(context, Icons.search, 'Buscar Productos', () { Navigator.pop(context); Navigator.pushNamed(context, '/search'); }),
                _buildDrawerItem(context, Icons.shopping_cart, 'Mi Carrito', () { Navigator.pop(context); Navigator.pushNamed(context, '/cart'); }),
                _buildDrawerItem(context, Icons.person, 'Mi Perfil', () { Navigator.pop(context); Navigator.pushNamed(context, '/profile'); }),
                _buildDrawerItem(context, Icons.settings, 'Ajustes', () { Navigator.pop(context); Navigator.pushNamed(context, '/settings'); }),
                const Divider(),
                _buildDrawerItem(context, Icons.history, 'Historial de Pedidos', () { Navigator.pop(context); _showComingSoon(context); }),
                _buildDrawerItem(context, Icons.favorite, 'Favoritos', () { Navigator.pop(context); _showComingSoon(context); }),
                const Divider(),

                // --- BOTÓN PARA IR AL PANEL ADMIN ---
                _buildDrawerItem(
                  context,
                  Icons.admin_panel_settings, // Ícono de admin
                  'Panel Admin',
                  () {
                    Navigator.pop(context); // Cierra el drawer
                    // Navega a la pantalla DashboardScreen del Admin App
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    );
                  },
                  color: Colors.blueGrey, // Color distintivo (opcional)
                ),
                // --- FIN DEL BOTÓN ADMIN ---

                const Divider(),
                _buildDrawerItem(context, Icons.logout, 'Cerrar Sesión', () { Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); }, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- El resto de tus métodos _buildDrawerItem, _buildBody, _showComingSoon no cambian ---
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap, { Color? color, }) { /* ... */ return ListTile(leading: Icon(icon, color: color ?? Colors.brown), title: Text(title, style: TextStyle(color: color ?? Colors.black87)), onTap: onTap,); }
  Widget _buildBody() { /* ... */ return Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.brown, Colors.orange],), borderRadius: BorderRadius.circular(16), boxShadow: [ BoxShadow(color: Colors.brown.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4),),],), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Text('¡Bienvenido a WolfCoffee! ☕', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold,),), SizedBox(height: 8), Text('Disfruta de nuestros deliciosos productos recién preparados', style: TextStyle(color: Colors.white70, fontSize: 14),),],),), const SizedBox(height: 24), const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('Nuestro Menú', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown,),),), const SizedBox(height: 16), Expanded(child: ListView(children: const [ CategoryTile(title: "Desayunos", route: '/desayunos'), CategoryTile(title: "Almuerzos", route: '/almuerzos'), CategoryTile(title: "Comidas", route: '/comidas'), CategoryTile(title: "Bebidas", route: '/bebidas'), CategoryTile(title: "Postres", route: '/postres'),],),),],),); }
  void _showComingSoon(BuildContext context) { /* ... */ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Próximamente! Esta función estará disponible pronto.'), backgroundColor: Colors.orange, duration: Duration(seconds: 2),),); }
}
import 'package:flutter/material.dart';
import '../widgets/category_tile.dart';
import '../widgets/cart_badge.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Row(
          children: [
            Icon(Icons.local_cafe, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              "WolfCoffee",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
            tooltip: 'Buscar productos',
          ),
          CartBadge(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header del drawer
          Container(
            width: double.infinity,
            height: 180,
            decoration: const BoxDecoration(
              color: Colors.brown,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.brown, Colors.orange],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.local_cafe, size: 50, color: Colors.brown),
                ),
                const SizedBox(height: 16),
                const Text(
                  'WolfCoffee',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bienvenido/a',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Opciones del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  Icons.home,
                  'Inicio',
                  () => Navigator.pop(context),
                ),
                _buildDrawerItem(context, Icons.search, 'Buscar Productos', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/search');
                }),
                _buildDrawerItem(
                  context,
                  Icons.shopping_cart,
                  'Mi Carrito',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/cart');
                  },
                ),
                _buildDrawerItem(context, Icons.person, 'Mi Perfil', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                }),
                _buildDrawerItem(context, Icons.settings, 'Ajustes', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                }),
                const Divider(),
                _buildDrawerItem(
                  context,
                  Icons.history,
                  'Historial de Pedidos',
                  () {
                    Navigator.pop(context);
                    _showComingSoon(context);
                  },
                ),
                _buildDrawerItem(context, Icons.favorite, 'Favoritos', () {
                  Navigator.pop(context);
                  _showComingSoon(context);
                }),
                const Divider(),
                _buildDrawerItem(context, Icons.logout, 'Cerrar Sesión', () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.brown),
      title: Text(title, style: TextStyle(color: color ?? Colors.black87)),
      onTap: onTap,
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de bienvenida
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.brown, Colors.orange],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Bienvenido a WolfCoffee! ☕',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Disfruta de nuestros deliciosos productos recién preparados',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Título de categorías
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Nuestro Menú',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lista de categorías
          Expanded(
            child: ListView(
              children: const [
                CategoryTile(title: "Desayunos", route: '/desayunos'),
                CategoryTile(title: "Almuerzos", route: '/almuerzos'),
                CategoryTile(title: "Comidas", route: '/comidas'),
                CategoryTile(title: "Bebidas", route: '/bebidas'),
                CategoryTile(title: "Postres", route: '/postres'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Próximamente! Esta función estará disponible pronto.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

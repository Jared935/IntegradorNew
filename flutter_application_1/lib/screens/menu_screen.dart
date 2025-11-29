import 'package:flutter/material.dart';
// Asegúrate de que estos widgets existan en tu proyecto.
// Si no los tienes, avísame y te paso el código de ellos también.
import '../widgets/category_tile.dart'; 
import '../widgets/cart_badge.dart'; 

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50], // Fondo suave
      
      // --- BARRA SUPERIOR (APPBAR) ---
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.local_cafe, color: Colors.orange), // Icono pequeño
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
        // Botón del menú (hamburguesa)
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        // Iconos de la derecha (Buscar y Carrito)
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'Buscar productos',
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          CartBadge( // Widget personalizado del carrito con contador
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
          const SizedBox(width: 10),
        ],
      ),

      // --- MENÚ LATERAL (DRAWER) ---
      drawer: _buildDrawer(context),

      // --- CUERPO DE LA PANTALLA ---
      body: _buildBody(context),
    );
  }

  // Función para construir el menú lateral
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // 1. Encabezado con degradado
          Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(
              color: Colors.brown,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5D4037), Colors.orange], // Degradado Café -> Naranja
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.local_cafe, size: 50, color: Colors.brown),
                ),
                SizedBox(height: 15),
                Text(
                  'WolfCoffee',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Bienvenido/a',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // 2. Lista de Opciones
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 10),
                _buildDrawerItem(
                  icon: Icons.home,
                  text: 'Inicio',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.search,
                  text: 'Buscar Productos',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/search');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.shopping_cart,
                  text: 'Mi Carrito',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/cart');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person,
                  text: 'Mi Perfil',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  text: 'Ajustes',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                
                const Divider(), // Línea divisoria
                
                _buildDrawerItem(
                  icon: Icons.history,
                  text: 'Historial de Pedidos',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigator.pushNamed(context, '/history');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.favorite,
                  text: 'Favoritos',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigator.pushNamed(context, '/favorites');
                  },
                ),
                
                const Divider(), // Línea divisoria

                // --- BOTÓN CERRAR SESIÓN ---
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.red),
                  title: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    // Cierra el drawer
                    Navigator.pop(context);
                    
                    // Navega al login y BORRA el historial para que no puedan volver atrás
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/customer_login', 
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para los items del menú
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown[700]),
      title: Text(
        text,
        style: TextStyle(color: Colors.brown[900], fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  // Función para construir el cuerpo de la página
  Widget _buildBody(BuildContext context) {
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
                colors: [Color(0xFF5D4037), Color(0xFF8D6E63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, Café Lover! ☕',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '¿Qué se te antoja hoy? Tenemos productos recién preparados.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 25),
          
          // Título de secciones
          const Text(
            'Categorías',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4E342E),
            ),
          ),
          const SizedBox(height: 15),

          // Lista de Categorías
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
}
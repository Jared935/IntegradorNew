import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Firebase ---
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Asegúrate de que este archivo exista en lib/

// --- Providers (WolfCoffe Cliente) ---
import 'package:flutter_application_1/providers/products_provider.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';

// --- Pantallas Cliente (WolfCoffe) ---
import 'package:flutter_application_1/screens/login_screen.dart'; // CustomerLoginScreen
import 'package:flutter_application_1/screens/register_screen.dart';
import 'package:flutter_application_1/screens/menu_screen.dart'; // MainMenuScreen
import 'package:flutter_application_1/options/cart_screen.dart';
import 'package:flutter_application_1/screens/search_screen.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/screens/settings_screen.dart';

// --- Categorías Cliente ---
import 'package:flutter_application_1/screens/categorys_screen/desayunos_screes.dart';
import 'package:flutter_application_1/screens/categorys_screen/almuerzos_screen.dart';
import 'package:flutter_application_1/screens/categorys_screen/comidas_screen.dart';
import 'package:flutter_application_1/screens/categorys_screen/bebidas_screen.dart';
import 'package:flutter_application_1/screens/categorys_screen/postres_screen.dart';

// --- Pantallas Admin (Panel) ---
import 'package:flutter_application_1/admin_login.dart'; // AdminLoginScreen
import 'package:flutter_application_1/dashboard_screen.dart'; // DashboardScreen

// ============================================================================
// PUNTO DE ENTRADA PRINCIPAL
// ============================================================================
void main() async {
  // 1. Asegura la inicialización del motor de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa Firebase con la configuración de la plataforma actual
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Arranca la aplicación combinada
  runApp(const CombinedApp());
}

class CombinedApp extends StatelessWidget {
  const CombinedApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos MultiProvider para inyectar los estados globales de la app de cliente
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'WolfCoffe & Admin Panel',
        debugShowCheckedModeBanner: false, // Quita la etiqueta DEBUG

        // --- Tema Global ---
        theme: ThemeData(
          primarySwatch: Colors.brown,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.orange[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.brown,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),

        // --- Pantalla Inicial ---
        // La app arranca por defecto en el login de clientes
        home: const CustomerLoginScreen(),

        // --- Mapa de Rutas ---
        routes: {
          // -> Rutas de Cliente
          '/customer_login': (context) => const CustomerLoginScreen(),
          '/register': (context) => const CustomerRegisterScreen(),
          '/menu': (context) => const MainMenuScreen(),
          '/cart': (context) => const CartScreen(),
          '/search': (context) => const SearchScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/settings': (context) => const SettingsScreen(),

          // -> Rutas de Categorías
          '/desayunos': (context) => const DesayunosScreen(),
          '/almuerzos': (context) => const AlmuerzosScreen(),
          '/comidas': (context) => const ComidasScreen(),
          '/bebidas': (context) => const BebidasScreen(),
          '/postres': (context) => const PostresScreen(),

          // -> Rutas de Admin
          '/admin_login': (context) => const AdminLoginScreen(),
          '/admin_dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}
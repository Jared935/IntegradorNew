import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
// Asumiendo que firebase_options.dart está en la raíz de lib o del proyecto
import 'firebase_options.dart';

// Providers de la app de cliente (WolfCoffe)
import 'package:flutter_application_1/providers/products_provider.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';

// Pantalla de inicio (Login del Cliente)
import 'package:flutter_application_1/screens/login_screen.dart';

// --- Importa TODAS las pantallas que usas en las rutas ---

// Pantallas Cliente (WolfCoffe)
import 'package:flutter_application_1/screens/menu_screen.dart';
import 'package:flutter_application_1/screens/register_screen.dart';
import 'package:flutter_application_1/options/cart_screen.dart';
import 'package:flutter_application_1/screens/search_screen.dart';
import 'package:flutter_application_1/screens/profile_screen.dart'; // Renombrado a CustomerProfileScreen
import 'package:flutter_application_1/screens/settings_screen.dart';
import 'package:flutter_application_1/screens/categorys_screen/desayunos_screes.dart';
import 'package:flutter_application_1/screens/categorys_screen/almuerzos_screen.dart';
import 'package:flutter_application_1/screens/categorys_screen/comidas_screen.dart';
import 'package:flutter_application_1/screens/categorys_screen/bebidas_screen.dart';
import 'package:flutter_application_1/screens/categorys_screen/postres_screen.dart';

// Pantallas Admin
import 'package:flutter_application_1/admin_login.dart';
import 'package:flutter_application_1/dashboard_screen.dart';
// Importa otras pantallas admin si necesitas navegar directamente a ellas
// import 'package:flutter_application_1/admin_app/users_screen.dart'; // Renombrado a AdminUsersScreen?
// import 'package:flutter_application_1/admin_app/products_screen.dart'; // Renombrado a AdminProductsScreen?

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase para el panel de admin
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CombinedApp());
}

class CombinedApp extends StatelessWidget {
  const CombinedApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configura los Providers para WolfCoffe
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'WolfCoffe & Admin Panel',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.brown,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.orange[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.brown,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        // La pantalla inicial es el Login del Cliente
        home: const CustomerLoginScreen(), // Usa la clase renombrada

        // Define las rutas nombradas para la navegación
        routes: {
          // Rutas Cliente
          '/customer_login': (context) => const CustomerLoginScreen(), // Ruta para el login cliente
          '/register': (context) => const RegisterScreen(),
          '/menu': (context) => const MainMenuScreen(),
          '/cart': (context) => const CartScreen(),
          '/search': (context) => const SearchScreen(),
          '/profile': (context) => const ProfileScreen(), // Usa la clase renombrada
          '/settings': (context) => const SettingsScreen(),
          '/desayunos': (context) => const DesayunosScreen(),
          '/almuerzos': (context) => const AlmuerzosScreen(),
          '/comidas': (context) => const ComidasScreen(),
          '/bebidas': (context) => const BebidasScreen(),
          '/postres': (context) => const PostresScreen(),

          // Rutas Admin
          '/admin_login': (context) => const AdminLoginScreen(), // Ruta para el login admin
          '/admin_dashboard': (context) => const DashboardScreen(),
          // Puedes añadir más rutas admin aquí si las necesitas
          // '/admin_users': (context) => const AdminUsersScreen(),
        },
      ),
    );
  }
}


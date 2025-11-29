import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// --- Providers ---
import 'package:flutter_application_1/providers/products_provider.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';

// --- Pantallas Cliente ---
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/register_screen.dart';
import 'package:flutter_application_1/screens/menu_screen.dart';
import 'package:flutter_application_1/options/cart_screen.dart';
import 'package:flutter_application_1/screens/search_screen.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/screens/settings_screen.dart';

// --- Categorías ---
import 'package:flutter_application_1/screens/categorys_screen/desayunos_screes.dart';
import 'package:flutter_application_1/screens/categorys_screen/almuerzos_screen.dart';
import 'package:flutter_application_1/screens/categorys_screen/comidas_screen.dart';
import 'package:flutter_application_1/screens/categorys_screen/bebidas_screen.dart';
import 'package:flutter_application_1/screens/categorys_screen/postres_screen.dart';

// --- Pantallas Admin ---
import 'package:flutter_application_1/admin_login.dart';
import 'package:flutter_application_1/dashboard_screen.dart';
// ASEGÚRATE de importar tus pantallas de gestión administrativa aquí:
import 'package:flutter_application_1/users_screen.dart';
import 'package:flutter_application_1/sales_screen.dart'; 
import 'package:flutter_application_1/products_screen.dart';
import 'package:flutter_application_1/tickets_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CombinedApp());
}

class CombinedApp extends StatelessWidget {
  const CombinedApp({super.key});

  @override
  Widget build(BuildContext context) {
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
            elevation: 4,
          ),
        ),
        
        home: const CustomerLoginScreen(),

        routes: {
          // --- Cliente ---
          '/customer_login': (context) => const CustomerLoginScreen(),
          '/register': (context) => const CustomerRegisterScreen(),
          '/menu': (context) => const MainMenuScreen(),
          '/cart': (context) => const CartScreen(),
          '/search': (context) => const SearchScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/settings': (context) => const SettingsScreen(),
          
          // --- Categorías ---
          '/desayunos': (context) => const DesayunosScreen(),
          '/almuerzos': (context) => const AlmuerzosScreen(),
          '/comidas': (context) => const ComidasScreen(),
          '/bebidas': (context) => const BebidasScreen(),
          '/postres': (context) => const PostresScreen(),

          // --- Admin ---
          '/admin_login': (context) => const AdminLoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          
          // --- NUEVAS RUTAS DE GESTIÓN ADMIN ---
          '/admin_users': (context) => const UsersScreen(),
          '/admin_products': (context) => const ProductsScreen(),
          '/admin_sales': (context) => const SalesScreen(),
          '/admin_tickets': (context) => const TicketsScreen(),
        },
      ),
    );
  }
}
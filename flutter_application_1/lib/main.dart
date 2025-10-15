// main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Importa el Core de Firebase para la inicialización
import 'package:firebase_core/firebase_core.dart';

// Importa el archivo de configuración generado por FlutterFire
import 'firebase_options.dart'; 

// Importa la pantalla de inicio de sesión, que será la primera en mostrarse
import 'login_screen.dart'; 


// La función main ahora es 'async' para poder esperar a que Firebase se inicialice
void main() async {
  // 1. Asegura que los componentes de Flutter estén listos antes de usar plugins
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 2. 💥 CONEXIÓN A FIREBASE 💥
  // Esta línea es la más importante: conecta tu app con tu proyecto de Firebase
  // usando la configuración del archivo 'firebase_options.dart'.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 

  // 3. Inicia la aplicación de Flutter
  runApp(const AdminApp());
}

// El widget principal de tu aplicación
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título de la aplicación que se ve en la multitarea del sistema operativo
      title: 'Panel Administrativo Flutter',

      // Oculta la cinta de "Debug" en la esquina superior derecha
      debugShowCheckedModeBanner: false,

      // Define el tema visual de la aplicación
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
      ),

      // La primera pantalla que se mostrará al abrir la app
      home: const LoginScreen(), 
    );
  }
}
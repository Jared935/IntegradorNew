import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String category = ModalRoute.of(context)?.settings.arguments as String? ?? "Categoría";

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.brown,
      ),
      body: Center(
        child: Text("Aquí van los alimentos de $category", style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
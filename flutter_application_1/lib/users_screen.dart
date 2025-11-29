import 'package:flutter/material.dart';
// Asegúrate de que estas importaciones apunten a tus archivos correctos
import 'storage_service.dart';
import 'data_models.dart' as data_models;

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {

  // Función auxiliar para colores de roles
  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin': return Colors.green;
      case 'Editor': return Colors.blue;
      case 'Cliente': return Colors.indigo;
      default: return Colors.grey;
    }
  }
  
  // Función para borrar usuario de la base de datos
  void _deleteUser(String userId) {
    StorageService.deleteUser(userId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario eliminado')),
    );
  }
  
  // Función para mostrar el diálogo y añadir usuario
  void _addUser() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String selectedRole = 'Cliente'; // Valor por defecto

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Añadir Nuevo Usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre Completo'),
                ),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                ),
                const SizedBox(height: 15),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setStateDropdown) {
                    return DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: <String>['Admin', 'Editor', 'Cliente']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setStateDropdown(() {
                            selectedRole = newValue;
                          });
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
                  // 1. Crear el objeto usuario
                  final newUser = data_models.User(
                    id: '', // Firestore pone el ID
                    name: name,
                    email: email,
                    role: selectedRole,
                    password: password,
                  );

                  // 2. Guardar en Firebase usando StorageService
                  StorageService.addUser(newUser); 
                  
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Usuario $name añadido exitosamente')),
                  );
                } else {
                  // Validación simple
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor completa todos los campos')),
                  );
                }
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios Registrados'),
        backgroundColor: Colors.green, // Color verde como en tu imagen
        foregroundColor: Colors.white,
      ),
      // Usamos StreamBuilder para escuchar la base de datos en tiempo real
      body: StreamBuilder<List<data_models.User>>(
        stream: StorageService.streamUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
          }
          
          final liveUsers = snapshot.data ?? [];
          
          if (liveUsers.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: liveUsers.length,
            itemBuilder: (context, index) {
              final user = liveUsers[index];
              final Color roleColor = _getRoleColor(user.role);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.green),
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      // Opcional: Mostrar la contraseña (no recomendado en producción)
                      Text(user.password, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                    ],
                  ),
                  
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          user.role,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: roleColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Diálogo de confirmación antes de borrar
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("¿Eliminar Usuario?"),
                              content: Text("Vas a eliminar a ${user.name}. Esta acción no se puede deshacer."),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _deleteUser(user.id); // Llama a borrar con el ID real
                                  }, 
                                  child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addUser,
        label: const Text('Añadir Usuario'),
        icon: const Icon(Icons.person_add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
// users_screen.dart
import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'data_models.dart' as data_models;

class User {
  String name;
  String email;
  String role;
  String password; // CAMPO AÑADIDO
  User(this.name, this.email, this.role, this.password);
}

class UsersDataService {
  static final List<User> _users = [];

  static List<User> get userList => _users;
  static int get userCount => _users.length;

  static final Stream<List<User>> userStream = StorageService.streamUsers().map((loadedUsers) {
    _users.clear();
    // MODIFICADO para incluir la contraseña
    final screenUsers = loadedUsers.map((u) => User(u.name, u.email, u.role, u.password)).toList();
    _users.addAll(screenUsers);
    return screenUsers;
  });

  static Future<void> initialize() async {}

  static Future<void> save() async {
    final storageUsers = _users.map((u) => data_models.User(
      id: '',
      name: u.name,
      email: u.email,
      role: u.role,
      password: u.password, // MODIFICADO para guardar la contraseña real
    )).toList();
    await StorageService.saveUsers(storageUsers);
  }

  // MODIFICADO para aceptar la contraseña
  static void registerUser(String name, String email, String role, String password) {
    _users.add(User(name, email, role, password));
    save();
  }
}

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin': return Colors.green;
      case 'Editor': return Colors.blue;
      case 'Cliente': return Colors.indigo;
      default: return Colors.grey;
    }
  }

  void _deleteUser(int index) {
    UsersDataService._users.removeAt(index);
    UsersDataService.save();
  }

  void _addUser() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController(); // CONTROLADOR AÑADIDO
    String selectedRole = 'Cliente';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Añadir Nuevo Usuario'),
          content: Column(
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
              // CAMPO DE CONTRASEÑA AÑADIDO
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
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text;
                final email = emailController.text;
                final password = passwordController.text; // VALOR OBTENIDO

                // VALIDACIÓN MODIFICADA
                if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
                  // LLAMADA A FUNCIÓN MODIFICADA
                  UsersDataService.registerUser(name, email, selectedRole, password);
                  Navigator.of(context).pop();
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: Todos los campos son obligatorios.'))
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
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<User>>(
        stream: UsersDataService.userStream,
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

              return Dismissible(
                key: Key(user.email),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.red,
                  child: const Icon(Icons.delete_forever, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _deleteUser(index);
                },

                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.green),
                    title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(user.email),

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
                            _deleteUser(index);
                          },
                        ),
                      ],
                    ),
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
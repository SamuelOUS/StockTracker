import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/components/user_tile.dart';
import 'package:my_app/models/user_model.dart';
import 'package:my_app/providers/user_provider.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _controller = TextEditingController();
  String _searchValue = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserProvider>(context, listen: false);
      if (provider.users.isEmpty) {
        provider.fetchUsers();
      }
    });
  }

  List<UserModel> get _filteredUsers {
    final users = Provider.of<UserProvider>(context).users;
    if (_searchValue.isEmpty) return users;
    final query = _searchValue.toLowerCase();
    return users.where((user) {
      return user.fullName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _editUser(UserModel user) async {
    final fullNameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await Provider.of<UserProvider>(context, listen: false)
            .updateUser(user, fullNameController.text, emailController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario actualizado correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar usuario: $e')),
        );
      }
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: Text("¿Deseas eliminar a ${user.fullName}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Eliminar")),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Provider.of<UserProvider>(context, listen: false)
            .deleteUser(user.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario eliminado")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<UserProvider>(context).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- BOTÓN ARRIBA A LA IZQUIERDA ---
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.menu), // puedes cambiarlo por otro ícono
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hola 👋')),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // --- TÍTULOS CENTRADOS ---
              const Center(
                child: Text(
                  "Discover",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  "Take a look at any stocks",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 24),

              // --- BARRA DE BÚSQUEDA ---
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xF3F3F3),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (value) => setState(() => _searchValue = value),
                ),
              ),

              const SizedBox(height: 60),

              // --- TÍTULO DE SECCIÓN ---
              const Center(
                child: Text(
                  "Trending Stocks",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- LISTA DE USUARIOS ---
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredUsers.isEmpty
                        ? const Center(
                            child: Text("No se encontraron usuarios"),
                          )
                        : ListView.builder(
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return UserTile(
                                user: user,
                                onEdit: () => _editUser(user),
                                onDelete: () => _deleteUser(user),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

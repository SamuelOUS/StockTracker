// lib/screens/user_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/components/user_tile.dart';
import 'package:my_app/models/user_model.dart';
import 'package:my_app/providers/user_provider.dart';
import 'package:my_app/screens/user_search_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final ScrollController _scrollController = ScrollController();
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<UserProvider>(context, listen: false);

    // Cargar usuarios si la lista está vacía
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.users.isEmpty) {
        provider.fetchUsers(limit: _pageSize, skip: 0);
      }
    });

    // Scroll infinito
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        if (!provider.isLoading) {
          provider.fetchUsers(limit: _pageSize, skip: provider.users.length);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _editUser(BuildContext context, UserModel user) async {
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

  Future<void> _deleteUser(BuildContext context, UserModel user) async {
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
    final provider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Usuarios"),
        
      ),
      body: provider.isLoading && provider.users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: provider.users.length,
              itemBuilder: (context, index) {
                final user = provider.users[index];
                return UserTile(
                  user: user,
                  onEdit: () => _editUser(context, user),
                  onDelete: () => _deleteUser(context, user),
                );
              },
            ),
    );
  }
}

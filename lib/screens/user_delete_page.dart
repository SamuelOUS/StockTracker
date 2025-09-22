// lib/screens/user_delete_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/user_provider.dart';
import 'package:my_app/models/user_model.dart';

class UserDeletePage extends StatefulWidget {
  const UserDeletePage({super.key});

  @override
  State<UserDeletePage> createState() => _UserDeletePageState();
}

class _UserDeletePageState extends State<UserDeletePage> {
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
    final users = provider.users;
    final isLoading = provider.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text("Eliminar Usuario")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text("No hay usuarios"))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: user.imageProfile != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(user.imageProfile!),
                            )
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(user.fullName),
                      subtitle: Text(user.email),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(context, user),
                      ),
                    );
                  },
                ),
    );
  }
}

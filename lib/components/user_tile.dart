import 'package:flutter/material.dart';
import 'package:my_app/models/user_model.dart';

class UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UserTile({
    super.key,
    required this.user,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: user.imageProfile != null && user.imageProfile!.isNotEmpty
              ? NetworkImage(user.imageProfile!)
              : null,
          child: (user.imageProfile == null || user.imageProfile!.isEmpty)
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(user.fullName),
        subtitle: Text(user.email),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.person, size: 16),
              const SizedBox(width: 8),
              Text('ID: ${user.id}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onEdit != null)
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Editar'),
                ),
              if (onDelete != null)
                TextButton(
                  onPressed: onDelete,
                  child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

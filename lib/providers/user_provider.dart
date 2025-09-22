import 'package:flutter/material.dart';
import 'package:my_app/models/user_model.dart';
import 'package:my_app/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repo = UserRepository();

  List<UserModel> _users = [];
  bool _isLoading = false;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;

  
  Future<void> fetchUsers({int limit = 100, int skip = 0}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _repo.fetchPage(limit: limit, skip: skip);
      if (skip == 0) {
        _users = res.users;
      } else {
        _users.addAll(res.users);
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> createUser(String fullName, String email) async {
    final names = fullName.split(' ');
    final firstName = names.isNotEmpty ? names.first : '';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    try {
      final newUser = await _repo.createUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      _users.add(UserModel(
        id: newUser.id,
        fullName: fullName,
        email: email,
        imageProfile: newUser.imageProfile,
      ));
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  void addUser(UserModel user) {
    _users.add(user);
    notifyListeners();
  }

  Future<void> updateUser(UserModel user, String fullName, String email) async {
    final names = fullName.split(' ');
    final firstName = names.isNotEmpty ? names.first : '';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    try {
      await _repo.updateUser(
        user.id,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = UserModel(
          id: user.id,
          fullName: fullName,
          email: email,
          imageProfile: user.imageProfile,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  /// Eliminar usuario
  Future<void> deleteUser(int id) async {
    try {
      await _repo.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }
}

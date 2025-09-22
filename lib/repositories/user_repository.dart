import 'dart:convert';
import 'package:my_app/models/user_model.dart';
import 'package:my_app/models/user_page_response.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  static const String baseUrl = "https://dummyjson.com/users";

  
  Future<UserPageResponse> fetchPage({required int limit, required int skip}) async {
    final uri = Uri.parse('$baseUrl?limit=$limit&skip=$skip');
    final response = await http.get(uri);
    print(uri);
    print(response.reasonPhrase);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode} ${response.reasonPhrase}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    List usersJson = data['users'] as List? ?? [];

    List<UserModel> users = usersJson
        .map((user) => UserModel.fromJson(user as Map<String, dynamic>))
        .toList();

    return UserPageResponse(
      users: users,
      total: (data['total'] as num?)?.toInt() ?? 0,
      limit: (data['limit'] as num?)?.toInt() ?? 0,
      skip: (data['skip'] as num?)?.toInt() ?? 0,
    );
  }

  
  Future<UserModel> createUser({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final uri = Uri.parse(baseUrl);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear usuario');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }


  Future<void> updateUser(int id,
      {required String firstName,
      required String lastName,
      required String email}) async {
    final uri = Uri.parse('$baseUrl/$id');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el usuario');
    }
  }

 
  Future<void> deleteUser(int id) async {
    final uri = Uri.parse('$baseUrl/$id');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el usuario');
    }
  }
}

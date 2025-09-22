import 'package:my_app/models/user_model.dart';

class UserPageResponse {

  final List<UserModel> users;
  final int total; 
  final int limit;
  final int skip; 


  UserPageResponse({
    required this.users,
    required this.total,
    required this.limit,
    required this.skip,
  });
}

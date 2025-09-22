class UserModel{
  final int id;
  final String fullName;
  final String email;
  final String? imageProfile;
  

  UserModel({
    required this.id,
    required this.fullName, 
    required this.email,
    this.imageProfile,
    
  });


factory UserModel.fromJson(Map<String, dynamic> data) {
  final firsName = data['firstName']?.toString() ?? '';
  final lastName = data['lastName']?.toString() ?? '';
  return UserModel(id : data['id'] as int,
  fullName: [firsName, lastName].where((value) => value.isNotEmpty).join(""),
  email: data['email']?.toString() ?? '-',
  imageProfile: data['image']?.toString(),
  
  );
  

}}

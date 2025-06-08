class UserModel {
  final String uid;
  String firstName;
  String lastName;
  String email;
  String password;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}

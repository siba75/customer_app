class SigninModel {
  final String email;
  final String password;

  SigninModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

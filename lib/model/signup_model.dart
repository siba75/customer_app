class SignupModel {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final String nationalId;

  SignupModel({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.nationalId,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'nationalId': nationalId,
      };
} 
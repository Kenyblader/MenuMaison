class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});
}

class RegisterRequest {
  final String email;
  final String password;
  final String? name;

  RegisterRequest({required this.email, required this.password, this.name});
}

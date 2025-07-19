class Admin {
  final String id;
  final String firstName;
  final String lastName;
  final String login;
  final String password; // Parol odatda backendda shifrlangan bo‘ladi, UI da ko‘rsatish tavsiya etilmaydi

  Admin({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.login,
    required this.password,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      login: json['login'] ?? '',
      password: json['password'] ?? '',
    );
  }
}

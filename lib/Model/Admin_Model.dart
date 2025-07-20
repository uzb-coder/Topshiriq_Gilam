class Admin {
  final String id;
  final String firstName;
  final String lastName;
  final String login;
  final String password;

  Admin({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.login,
    required this.password,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['_id'].toString(), // <-- shu yerda o'zgartirish kerak bo'lishi mumkin
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      login: json['username'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'username': login,
    'password': password,

  };
}

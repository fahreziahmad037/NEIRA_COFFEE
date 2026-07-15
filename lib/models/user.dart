class User {
  final int? id;
  final String nama;
  final String username;
  final String password;
  final String role;

  User({
    this.id,
    required this.nama,
    required this.username,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'username': username,
      'password': password,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nama: map['nama'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
    );
  }
}

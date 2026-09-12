class User {
  final String id, username, role;
  const User({required this.id, required this.username, required this.role});
  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['userId'] ?? j['id'],
    username: j['username'],
    role: j['role'],
  );
}

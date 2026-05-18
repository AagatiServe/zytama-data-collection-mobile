class UserEntity {
  final String email;
  final String name;
  final String token;
  final String agentCode;

  const UserEntity({
    required this.email,
    required this.name,
    required this.token,
    this.agentCode = '',
  });
}

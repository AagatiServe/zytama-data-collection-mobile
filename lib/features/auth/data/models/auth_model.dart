class AuthModel {
  final String token;
  final String refreshToken;
  final String email;
  final String name;
  final String agentCode;
  final String id;

  const AuthModel({
    required this.token,
    required this.refreshToken,
    required this.email,
    required this.name,
    required this.agentCode,
    required this.id,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json, {required String email}) {
    final data = json['data'] as Map<String, dynamic>;
    return AuthModel(
      token: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      email: email,
      name: data['display_name'] as String,
      agentCode: data['agent_code'] as String,
      id: data['id'] as String,
    );
  }
}

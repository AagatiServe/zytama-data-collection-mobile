import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_model.dart';

const _deviceIdKey = 'device_id';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final SharedPreferences prefs;

  AuthRemoteDataSourceImpl(this.apiClient, this.prefs);

  String _getOrCreateDeviceId() {
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null) return existing;
    final rand = math.Random.secure();
    final hex = List.generate(8, (_) => rand.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final id = 'android_$hex';
    prefs.setString(_deviceIdKey, id);
    return id;
  }

  @override
  Future<AuthModel> login(String email, String password) async {
    try {
      final response = await apiClient.post(
        ApiConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
          'device_id': _getOrCreateDeviceId(),
          'app_version': '1.2.0',
          'client_app': 'data_collection',
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(body['message'] ?? 'Login failed');
      }
      return AuthModel.fromJson(body, email: email);
    } on DioException catch (e) {
      final body = e.response?.data;
      final msg = (body is Map ? body['message'] : null) ??
          e.message ??
          'Login failed';
      throw Exception(msg);
    }
  }
}

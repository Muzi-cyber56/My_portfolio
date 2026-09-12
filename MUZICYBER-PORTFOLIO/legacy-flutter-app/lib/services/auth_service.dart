import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static final instance = AuthService();
  final _storage = const FlutterSecureStorage();
  User? user;
  Future<bool> restore() async {
    try {
      ApiService.instance.token = await _storage.read(key: 'sentinel_token');
      if (ApiService.instance.token == null) return false;
      user = User.fromJson(
        await ApiService.instance.request('GET', '/api/users/me'),
      );
      ApiService.instance.expired.value = false;
      return true;
    } catch (_) {
      ApiService.instance.token = null;
      return false;
    }
  }

  Future<void> authenticate(
    String username,
    String password,
    bool register,
  ) async {
    final result = await ApiService.instance.request(
      'POST',
      '/api/auth/${register ? 'register' : 'login'}',
      {'username': username, 'password': password},
    );
    await _storage.write(key: 'sentinel_token', value: result['token']);
    ApiService.instance.token = result['token'];
    user = User.fromJson(result);
    ApiService.instance.expired.value = false;
  }

  Future<void> logout() async {
    ApiService.instance.token = null;
    user = null;
    await _storage.delete(key: 'sentinel_token');
  }
}

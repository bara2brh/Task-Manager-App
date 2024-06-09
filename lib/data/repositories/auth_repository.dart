import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  AuthRepository(this._apiService, this._prefs);

  Future<User> login(String username, String password) async {
    final response = await _apiService.post('/auth/login', {
      'username': username,
      'password': password,
      'expiresInMins': 30,
    });

    return User.fromJson(response);
  }

  Future<void> saveSession(String token) async {
    await _prefs.setString('token', token);
  }

  Future<String?> getSession() async {
    return _prefs.getString('token');
  }

  Future<void> clearSession() async {
    await _prefs.remove('token');
  }

}

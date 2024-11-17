import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'access_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'access_token');
  }
}
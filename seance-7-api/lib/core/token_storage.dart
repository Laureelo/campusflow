import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStorage {
  Future<String?> read();

  Future<void> write(String token);

  Future<void> delete();
}

class SecureTokenStorage implements TokenStorage {
  static const _key = 'auth_token';

  final FlutterSecureStorage _storage;

  const SecureTokenStorage([this._storage = const FlutterSecureStorage()]);

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> delete() => _storage.delete(key: _key);
}

class MemoryTokenStorage implements TokenStorage {
  String? _token;

  MemoryTokenStorage([this._token]);

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> delete() async => _token = null;
}

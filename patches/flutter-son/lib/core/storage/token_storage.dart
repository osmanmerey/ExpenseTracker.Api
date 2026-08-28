// lib/core/storage/token_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _emailKey = 'auth_email';
  static const _roleKey = 'auth_role'; // YENİ EKLENDİ

  final FlutterSecureStorage _storage;

  String? _token;
  String? _userId;
  String? _email;
  String? _role; // YENİ EKLENDİ

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> init() async {
    _token = await _storage.read(key: _tokenKey);
    _userId = await _storage.read(key: _userIdKey);
    _email = await _storage.read(key: _emailKey);
    _role = await _storage.read(key: _roleKey); // YENİ EKLENDİ
  }

  String? get token => _token;
  String? get userId => _userId;
  String? get email => _email;
  String? get role => _role; // YENİ EKLENDİ

  Future<void> saveSession({
    required String token,
    required String userId,
    String? email,
    String? role, // YENİ EKLENDİ
  }) async {
    _token = token;
    _userId = userId;
    _email = email?.trim().isEmpty == true ? null : email?.trim();
    final trimmedRole = role?.trim();
    _role = (trimmedRole == null || trimmedRole.isEmpty)
        ? null
        : trimmedRole.toLowerCase();

    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId);

    if (_email != null) {
      await _storage.write(key: _emailKey, value: _email);
    } else {
      await _storage.delete(key: _emailKey);
    }

    // YENİ EKLENDİ
    if (_role != null) {
      await _storage.write(key: _roleKey, value: _role);
    } else {
      await _storage.delete(key: _roleKey);
    }
  }

  Future<void> clear() async {
    _token = null;
    _userId = null;
    _email = null;
    _role = null; // YENİ EKLENDİ
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _roleKey); // YENİ EKLENDİ
  }
}
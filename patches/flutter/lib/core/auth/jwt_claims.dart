import 'dart:convert';

/// Reads role claims from a compact JWT without verifying the signature.
/// Used only to hydrate the local session when the login JSON omits `user.role`.
abstract final class JwtClaims {
  static const _roleKeys = <String>[
    'role',
    'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
  ];

  static String? role(String? token) {
    if (token == null || token.isEmpty) return null;
    final parts = token.split('.');
    if (parts.length < 2) return null;

    try {
      final json = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payload = jsonDecode(json);
      if (payload is! Map) return null;

      for (final key in _roleKeys) {
        final value = payload[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
        if (value is List && value.isNotEmpty) {
          final first = value.first;
          if (first is String && first.trim().isNotEmpty) return first.trim();
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}

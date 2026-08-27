import 'dart:convert';

import 'package:expense_tracker/core/auth/jwt_claims.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String tokenWithPayload(Map<String, dynamic> payload) {
    final encoded = base64Url.encode(utf8.encode(jsonEncode(payload)));
    return 'header.$encoded.sig';
  }

  test('reads short role claim', () {
    expect(JwtClaims.role(tokenWithPayload({'role': 'admin'})), 'admin');
  });

  test('reads .NET long role claim', () {
    expect(
      JwtClaims.role(tokenWithPayload({
        'http://schemas.microsoft.com/ws/2008/06/identity/claims/role': 'ADMIN',
      })),
      'ADMIN',
    );
  });

  test('returns null for garbage', () {
    expect(JwtClaims.role('not-a-jwt'), isNull);
    expect(JwtClaims.role(null), isNull);
  });
}

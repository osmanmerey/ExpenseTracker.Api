import 'package:expense_tracker/core/auth/user_roles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isAdmin is case-insensitive', () {
    expect(UserRoles.isAdmin('admin'), isTrue);
    expect(UserRoles.isAdmin('ADMIN'), isTrue);
    expect(UserRoles.isAdmin('user'), isFalse);
    expect(UserRoles.isAdmin(null), isFalse);
  });
}

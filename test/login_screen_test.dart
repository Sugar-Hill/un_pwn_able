
import 'package:flutter_test/flutter_test.dart';
import 'package:un_pwn_able/screens/login_screen.dart';

void main() {
  test('Check for empty password field', () {
    var result = PasswordFieldValidator.validatePassword('');
    expect(result, 'Please provide a password');
  });
  test('Check for filled password field', () {
    var result = PasswordFieldValidator.validatePassword('4_}4YjU>9!sNz');
    expect(result, null);
  });
}
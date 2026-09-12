import 'package:flutter_test/flutter_test.dart';
import 'package:osint_platform/utils/validators.dart';

void main() {
  test('Whitespace titles and short passwords are rejected', () {
    expect(Validators.title('  '), isNotNull);
    expect(Validators.title('Incident review'), isNull);
    expect(Validators.password('short'), isNotNull);
    expect(Validators.password('long-passphrase-123'), isNull);
  });
}

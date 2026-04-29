import 'package:flutter_test/flutter_test.dart';
import 'package:agenda_escolar_adventista/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('retorna error si el correo está vacío', () {
      expect(Validators.email(''), 'El correo es obligatorio');
      expect(Validators.email(null), 'El correo es obligatorio');
    });

    test('retorna error si el correo no es válido', () {
      expect(Validators.email('invalid'), 'Ingresa un correo válido');
      expect(Validators.email('test@'), 'Ingresa un correo válido');
    });

    test('retorna null si el correo es válido', () {
      expect(Validators.email('test@example.com'), null);
    });
  });

  group('Validators.password', () {
    test('rechaza contraseñas cortas', () {
      expect(Validators.password('abc'), 'Mínimo 8 caracteres');
    });

    test('exige mayúscula', () {
      expect(Validators.password('abcdefgh1'), 'Debe incluir al menos una mayúscula');
    });

    test('exige número', () {
      expect(Validators.password('Abcdefgh'), 'Debe incluir al menos un número');
    });

    test('acepta contraseña válida', () {
      expect(Validators.password('Abcdefg1'), null);
    });
  });
}

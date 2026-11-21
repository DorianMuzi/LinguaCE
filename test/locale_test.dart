import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_ce/i18n/locale_controller.dart';

/// Tant que l'utilisateur n'a pas choisi de langue, l'app suit le téléphone.
void main() {
  test('la langue du téléphone si l\'app la parle', () {
    expect(LocaleController.fromDevice(['fr']), 'FR');
    expect(LocaleController.fromDevice(['ru']), 'RU');
    expect(LocaleController.fromDevice(['en']), 'EN');
    expect(LocaleController.fromDevice(['ce']), 'CE');
  });

  test('la première langue parlée, dans l\'ordre de préférence', () {
    expect(LocaleController.fromDevice(['de', 'ru', 'en']), 'RU');
    expect(LocaleController.fromDevice(['tr', 'fr']), 'FR');
  });

  test('sinon l\'anglais', () {
    expect(LocaleController.fromDevice(['de']), 'EN');
    expect(LocaleController.fromDevice(<String>[]), 'EN');
  });
}

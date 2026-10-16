import 'package:flutter_test/flutter_test.dart';

import 'package:sandbox/features/menu/data/mappers/menu_entry_mapper.dart';
import 'package:sandbox/features/menu/data/models/menu_entry_model.dart';

void main() {
  test('maps a menu data model to a domain entity', () {
    const model = MenuEntryModel(id: 'home', titleKey: 'menu.home');

    final entity = model.toEntity();

    expect(entity.id, 'home');
    expect(entity.titleKey, 'menu.home');
  });
}

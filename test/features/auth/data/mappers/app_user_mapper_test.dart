import 'package:flutter_test/flutter_test.dart';

import 'package:sandbox/features/auth/data/mappers/app_user_mapper.dart';
import 'package:sandbox/features/auth/data/models/app_user_model.dart';

void main() {
  test('maps an auth data model to a domain entity', () {
    const model = AppUserModel(username: 'Alex', type: 'member');

    final entity = model.toEntity();

    expect(entity.username, 'Alex');
    expect(entity.type.name, 'member');
  });
}

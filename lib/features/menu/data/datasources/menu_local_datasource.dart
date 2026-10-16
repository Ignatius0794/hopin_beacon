import 'package:injectable/injectable.dart';

import 'package:sandbox/features/menu/data/models/menu_entry_model.dart';

@injectable
class MenuLocalDataSource {
  Future<List<MenuEntryModel>> getEntries() async => const [
        MenuEntryModel(id: 'home', titleKey: 'menu.home'),
        MenuEntryModel(id: 'profile', titleKey: 'menu.profile'),
        MenuEntryModel(id: 'settings', titleKey: 'menu.settings'),
      ];
}

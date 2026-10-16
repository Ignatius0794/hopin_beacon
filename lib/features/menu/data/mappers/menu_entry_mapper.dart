import 'package:sandbox/features/menu/data/models/menu_entry_model.dart';
import 'package:sandbox/features/menu/domain/entities/menu_entry.dart';

extension MenuEntryMapper on MenuEntryModel {
  MenuEntry toEntity() => MenuEntry(id: id, titleKey: titleKey);
}

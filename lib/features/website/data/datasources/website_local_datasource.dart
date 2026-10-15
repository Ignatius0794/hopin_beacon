import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class WebsiteLocalDataSource {
  WebsiteLocalDataSource(this._preferences);
  final SharedPreferences _preferences;
  static const addressKey = 'saved_website_url';
  static const previousAddressKey = 'previous_website_url';
  static const menuTipSeenKey = 'website_menu_tip_acknowledged_v2';

  bool hasSeenMenuTip() => _preferences.getBool(menuTipSeenKey) ?? false;

  Future<void> markMenuTipSeen() async {
    if (!await _preferences.setBool(menuTipSeenKey, true)) {
      throw StateError('Could not save menu tip preference');
    }
  }

  String? readAddress() => _preferences.getString(addressKey);

  String? readPreviousAddress() => _preferences.getString(previousAddressKey);

  Future<void> savePreviousAddress(String address) async {
    if (!await _preferences.setString(previousAddressKey, address)) {
      throw StateError('Could not persist previous website address');
    }
  }

  Future<void> clearPreviousAddress() async {
    if (!await _preferences.remove(previousAddressKey)) {
      throw StateError('Could not clear previous website address');
    }
  }

  Future<void> clearAddress() async {
    if (!await _preferences.remove(addressKey)) {
      throw StateError('Could not clear website address');
    }
    await _preferences.remove(previousAddressKey);
  }

  Future<void> saveAddress(String address) async {
    if (!await _preferences.setString(addressKey, address)) {
      throw StateError('Could not persist website address');
    }
  }
}

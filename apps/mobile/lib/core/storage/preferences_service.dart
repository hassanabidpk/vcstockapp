import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

class PreferencesService {
  static const _selectedPortfolioKey = 'selected_portfolio_id';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  String? getSelectedPortfolioId() {
    return _prefs.getString(_selectedPortfolioKey);
  }

  Future<void> setSelectedPortfolioId(String id) async {
    await _prefs.setString(_selectedPortfolioKey, id);
  }
}

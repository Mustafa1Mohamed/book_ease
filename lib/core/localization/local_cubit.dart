import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  final SharedPreferences _preferences;

  static const String _languageKey = 'app_language';

  LocaleCubit(this._preferences)
    : super(Locale(_preferences.getString(_languageKey) ?? 'en'));

  Future<void> changeLanguage(String languageCode) async {
    if (state.languageCode == languageCode) return;

    await _preferences.setString(_languageKey, languageCode);

    emit(Locale(languageCode));
  }

  Future<void> toggleLanguage() async {
    final newLanguage = state.languageCode == 'en' ? 'ar' : 'en';
    await changeLanguage(newLanguage);
  }
}

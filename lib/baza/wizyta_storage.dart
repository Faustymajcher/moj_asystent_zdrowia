import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modele/wizyta.dart';

class WizytaStorage {
  Future saveWizyty(List<Wizyta> wizyty) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> encoded = wizyty
        .map((w) => jsonEncode(w.toMap()))
        .toList();

    await prefs.setStringList('wizyty', encoded);
  }

  Future<List<Wizyta>> loadWizyty() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> data = prefs.getStringList('wizyty') ?? [];

    return data.map((e) => Wizyta.fromMap(jsonDecode(e))).toList();
  }

  Future clearWizyty() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wizyty');
  }
}

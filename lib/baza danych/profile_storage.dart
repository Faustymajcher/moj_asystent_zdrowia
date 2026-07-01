import 'package:shared_preferences/shared_preferences.dart';

class ProfileStorage {
  Future<void> saveProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', data['name']);
    await prefs.setString('age', data['age']);
    await prefs.setString('height', data['height']);
    await prefs.setString('weight', data['weight']);
    await prefs.setString('blood', data['blood']);
  }

  Future<Map<String, String>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "name": prefs.getString('name') ?? '',
      "age": prefs.getString('age') ?? '',
      "height": prefs.getString('height') ?? '',
      "weight": prefs.getString('weight') ?? '',
      "blood": prefs.getString('blood') ?? '',
    };
  }

  Future<double> loadWaterGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('waterGoal') ?? 0.0;
  }

  Future<void> saveWaterGoal(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('waterGoal', value);
  }
}
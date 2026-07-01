import 'package:flutter/material.dart';
import 'package:moj_asystent_zdrowia/baza danych/profile_storage.dart';
import 'package:moj_asystent_zdrowia/modele/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = ProfileStorage();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final bloodController = TextEditingController();

  double waterResult = 0.0;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data = await storage.loadProfile();
    final water = await storage.loadWaterGoal();

    setState(() {
      nameController.text = data['name']!;
      ageController.text = data['age']!;
      heightController.text = data['height']!;
      weightController.text = data['weight']!;
      bloodController.text = data['blood']!;
      waterResult = water;
    });
  }

  Future<void> saveProfile() async {
    await storage.saveProfile({
      'name': nameController.text,
      'age': ageController.text,
      'height': heightController.text,
      'weight': weightController.text,
      'blood': bloodController.text,
    });

    final double? weight = double.tryParse(weightController.text);
    final int? age = int.tryParse(ageController.text);

    double water = 0.0;

    if (weight != null && age != null) {
      water = calculateWaterIntake(
        weight: weight,
        age: age,
      );
    }

    await storage.saveWaterGoal(water);

    setState(() {
      waterResult = water;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dane zapisane! 💧 Cel: ${water.toStringAsFixed(2)} L'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil użytkownika"),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Imię")),
              TextField(controller: ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Wiek")),
              TextField(controller: heightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Wzrost")),
              TextField(controller: weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Waga")),
              TextField(controller: bloodController, decoration: const InputDecoration(labelText: "Grupa krwi")),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: saveProfile,
                child: const Text("Zapisz profil i oblicz wodę"),
              ),

              const SizedBox(height: 20),

              Text(
                "💧 Dzienne zapotrzebowanie: ${waterResult.toStringAsFixed(2)} L",
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double calculateWaterIntake({required double weight, required int age}) {
  // Prosty wzór: waga * 0.035 litra
  return weight * 0.035;
}
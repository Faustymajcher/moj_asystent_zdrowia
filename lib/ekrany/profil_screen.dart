import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:moj_asystent_zdrowia/baza/profile_storage.dart';
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
  String bmiResult = "-";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    bloodController.dispose();
    super.dispose();
  }

  double calculateWaterIntake({required double weight, required int age}) {
    double base = weight * 0.033;

    if (age >= 31 && age <= 55) {
      base *= 0.95;
    } else if (age > 55) {
      base *= 0.9;
    }

    return base;
  }

  Future<void> loadProfile() async {
    final data = await storage.loadProfile();
    final water = await storage.loadWaterGoal();

    setState(() {
      nameController.text = data['name'] ?? '';
      ageController.text = data['age'] ?? '';
      heightController.text = data['height'] ?? '';
      weightController.text = data['weight'] ?? '';
      bloodController.text = data['blood'] ?? '';
      waterResult = water;

      // Oblicz BMI przy ładowaniu profilu, jeśli dane istnieją
      final double? w = double.tryParse(weightController.text);
      final double? h = double.tryParse(heightController.text);
      if (w != null && h != null && h > 0) {
        bmiResult = calculateBMI(weight: w, height: h).toStringAsFixed(1);
      }
    });
  }

  double calculateBMI({required double weight, required double height}) {
    final h = height / 100;
    return weight / (h * h);
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
    final double? height = double.tryParse(heightController.text);

    double water = 0.0;
    String calculatedBmi = "-";

    if (weight != null && age != null) {
      water = calculateWaterIntake(weight: weight, age: age);
    }

    if (weight != null && height != null && height > 0) {
      calculatedBmi = calculateBMI(
        weight: weight,
        height: height,
      ).toStringAsFixed(1);
    }

    await storage.saveWaterGoal(water);

    // Aktualizujemy stan UI dla obu wartości jednocześnie
    setState(() {
      waterResult = water;
      bmiResult = calculatedBmi;
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
        backgroundColor: const Color(0xFFE91E63),
        centerTitle: true,
        title: const Text(
          "Mój Asystent Zdrowia",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Imię",
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller:
                            bloodController, // Podpięto controller do pola (płeć/grupa krwi)
                        decoration: const InputDecoration(
                          hintText: "Kobieta",
                          border: InputBorder.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text("PŁEĆ"),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "21",
                          border: InputBorder.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text("WIEK"),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          hintText: "13.09.2004",
                          border: InputBorder.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text("DATA URODZENIA"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Wzrost",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Waga",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: Colors.pink,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  child: Text("Zapisz", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(blurRadius: 8, color: Colors.black12),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dzienne zapotrzebowanie wody",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "${waterResult.toStringAsFixed(2)} L",
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "BMI",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(bmiResult, style: const TextStyle(fontSize: 26)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

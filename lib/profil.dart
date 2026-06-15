import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("👤 Imię: Anna", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("🎂 Wiek: 25", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("📏 Wzrost: 170 cm", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("⚖️ Waga: 60 kg", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("🩸 Grupa krwi: A+ (opcjonalnie)", style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
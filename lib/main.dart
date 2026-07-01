import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moj_asystent_zdrowia/ekrany/wizyty.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'ekrany/profil_screen.dart';
import 'ekrany/woda.dart';
import 'ekrany/historia.dart';
import 'ekrany/leki.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mój Asystent Zdrowia',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFE91E63),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 252, 253),
        fontFamily: 'Segoe UI',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 2;

  List<Map<String, dynamic>> medicines = [];

  @override
  void initState() {
    super.initState();
    loadMedicines();
  }

  Future<void> loadMedicines() async {
    final prefs = await SharedPreferences.getInstance();

    final String? savedData = prefs.getString('medicines');

    if (savedData != null) {
      final List decoded = jsonDecode(savedData);

      setState(() {
        medicines = decoded
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      });
    } else {
      medicines = [
        {"name": "Ibuprofen 200 mg", "hour": "18:00", "taken": false},
        {"name": "Witamina D", "hour": "20:00", "taken": false},
      ];

      await saveMedicines();
    }
  }

  Future<void> saveMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('medicines', jsonEncode(medicines));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ProfilePage(),
      const WaterPage(),
      MedicinesPage(medicines: medicines, saveMedicines: saveMedicines),
      WizytyPage(),
      const HistoryPage(),
    ];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: "Profil",
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            label: "Woda",
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            label: "Leki",
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: "Wizyty",
          ),
          NavigationDestination(icon: Icon(Icons.history), label: "Historia"),
        ],
      ),
    );
  }
}

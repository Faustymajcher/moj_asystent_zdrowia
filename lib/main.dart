import 'profil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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

    final String? savedData =
        prefs.getString('medicines');

    if (savedData != null) {
      final List decoded =
          jsonDecode(savedData);

      setState(() {
        medicines = decoded
            .map(
              (item) =>
                  Map<String, dynamic>.from(item),
            )
            .toList();
      });
    } else {
      medicines = [
        {
          "name": "Ibuprofen 200 mg",
          "hour": "18:00",
          "taken": false,
        },
        {
          "name": "Witamina D",
          "hour": "20:00",
          "taken": false,
        },
      ];

      await saveMedicines();
    }
  }

  Future<void> saveMedicines() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      'medicines',
      jsonEncode(medicines),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ProfilePage(),
      const WaterPage(),
      MedicinesPage(
        medicines: medicines,
        saveMedicines: saveMedicines,
      ),
      const VisitsPage(),
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
          NavigationDestination(
            icon: Icon(Icons.history),
            label: "Historia",
          ),
        ],
      ),
    );
  }
}

class MedicinesPage extends StatefulWidget {
  final List<Map<String, dynamic>> medicines;
  final Future<void> Function() saveMedicines;

  const MedicinesPage({
    super.key,
    required this.medicines,
    required this.saveMedicines,
  });

  @override
  State<MedicinesPage> createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {

  void addMedicine() {
    TextEditingController nameController = TextEditingController();
    TextEditingController hourController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dodaj lek"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nazwa leku",
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );

                if (picked != null) {
                  selectedTime = picked;

                  hourController.text =
                      "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                }
              },
              child: const Text("Wybierz godzinę"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Anuluj"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.medicines.add({
                  "name": nameController.text,
                  "hour": hourController.text,
                  "taken": false,
                });
              });
              widget.saveMedicines();
              Navigator.pop(context);
            },
            child: const Text("Dodaj"),
          ),
        ],
      ),
    );
  }
  void editMedicine(Map<String, dynamic> medicine) {
  TextEditingController nameController =
      TextEditingController(text: medicine["name"]);

  TextEditingController hourController =
      TextEditingController(text: medicine["hour"]);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edytuj lek"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Nazwa leku",
            ),
          ),

          TextField(
            controller: hourController,
            decoration: const InputDecoration(
              labelText: "Godzina",
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Anuluj"),
        ),

        ElevatedButton(
          onPressed: () {
            setState(() {
              medicine["name"] = nameController.text;
              medicine["hour"] = hourController.text;
            });
            widget.saveMedicines();
            Navigator.pop(context);
          },
          child: const Text("Zapisz"),
        ),
      ],
    ),
  );
}
  

  String getMedicineStatus(Map<String, dynamic> medicine) {
    if (medicine["taken"] == true) {
      return "Przyjęto";
    }

    final now = TimeOfDay.now();

    final parts = medicine["hour"].split(":");
    final medicineHour = int.parse(parts[0]);
    final medicineMinute = int.parse(parts[1]);

    final currentMinutes = now.hour * 60 + now.minute;
    final medicineMinutes = medicineHour * 60 + medicineMinute;

    if (currentMinutes >= medicineMinutes) {
      return "Do przyjęcia";
    }

    return "Oczekuje";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F8),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Moje leki",
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1,
            ),
          ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: widget.medicines.length,
          itemBuilder: (context, index) {
            final medicine = widget.medicines[index];
            final status = getMedicineStatus(medicine);

            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: medicineCard(
                icon: Icons.medication,
                name: medicine["name"],
                hour: medicine["hour"],
                color: status == "Przyjęto"
                    ? Colors.green
                    : status == "Do przyjęcia"
                        ? Colors.red
                        : Colors.orange,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addMedicine,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget medicineCard({
    required IconData icon,
    required String name,
    required String hour,
    required Color color,
  }) {
    final medicine = widget.medicines.firstWhere(
      (m) => m["name"] == name && m["hour"] == hour,
    );

    final status = getMedicineStatus(medicine);

    return Card(
      elevation: 8,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "🕒 $hour",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    status == "Przyjęto"
                        ? "✅ Przyjęto"
                        : status == "Do przyjęcia"
                            ? "🔴 Do przyjęcia"
                            : "🟡 Oczekuje",
                    style: GoogleFonts.poppins(
                      color: status == "Przyjęto"
                          ? Colors.green
                          : status == "Do przyjęcia"
                              ? Colors.red
                              : Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Column(
  children: [
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      onPressed: medicine["taken"]
          ? null
          : () {
              setState(() {
                medicine["taken"] = true;
              });
              widget.saveMedicines();
            },
      child: Text(
        medicine["taken"]
            ? "Przyjęto"
            : "Potwierdź",
      ),
    ),

    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(
            Icons.edit,
            color: Colors.blue,
          ),
          onPressed: () {
            editMedicine(medicine);
          },
        ),

        IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () {
            setState(() {
              widget.medicines.remove(medicine);
            });
            widget.saveMedicines();
          },
        ),
      ],
    ),
  ],
),
          ],
        ),
      ),
    );
  }
}
class WaterPage extends StatelessWidget {
  const WaterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Nawodnienie",
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}

class VisitsPage extends StatelessWidget {
  const VisitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Wizyty",
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Historia",
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}


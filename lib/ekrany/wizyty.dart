import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../modele/wizyta.dart';
import '../baza/baza_danych.dart';

class WizytyPage extends StatefulWidget {
  const WizytyPage({super.key});

  @override
  State<WizytyPage> createState() => _WizytyPageState();
}

class _WizytyPageState extends State<WizytyPage> {
  List<Wizyta> wizyty = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    wizyty = await BazaDanych.instance.pobierzWizyty();
    setState(() {});
  }

  String format(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  void addVisit() {
    final lekarz = TextEditingController();
    final miejsce = TextEditingController();
    final notatki = TextEditingController();
    DateTime? data;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Dodaj wizytę"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: lekarz,
                  decoration: const InputDecoration(labelText: "Lekarz"),
                ),
                TextField(
                  controller: miejsce,
                  decoration: const InputDecoration(labelText: "Miejsce"),
                ),
                TextField(
                  controller: notatki,
                  decoration: const InputDecoration(labelText: "Notatki"),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now(),
                    );

                    if (picked != null) {
                      setStateDialog(() => data = picked);
                    }
                  },
                  child: const Text("Wybierz datę"),
                ),

                Text(data == null ? "Brak daty" : format(data!)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Anuluj"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (data == null) return;

                  await BazaDanych.instance.dodajWizyte(
                    Wizyta(
                      data: data!,
                      lekarz: lekarz.text,
                      miejsce: miejsce.text,
                      notatki: notatki.text,
                    ),
                  );

                  Navigator.pop(context);
                  load();
                },
                child: const Text("Dodaj"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Wizyty",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE91E63),
        onPressed: addVisit,
        child: const Icon(Icons.add),
      ),

      body: wizyty.isEmpty
          ? const Center(child: Text("Brak wizyt"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wizyty.length,
              itemBuilder: (context, i) {
                final w = wizyty[i];

                return Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      w.lekarz,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${w.miejsce}\n${format(w.data)}\n${w.notatki}",
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        if (w.id != null) {
                          await BazaDanych.instance.usunWizyte(w.id!);
                          load();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

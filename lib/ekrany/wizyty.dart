import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../modele/wizyta.dart';
import '../baza/wizyta_storage.dart';

class WizytyPage extends StatefulWidget {
  const WizytyPage({super.key});

  @override
  State<WizytyPage> createState() => _WizytyPageState();
}

class _WizytyPageState extends State<WizytyPage> {
  final storage = WizytaStorage();

  List<Wizyta> wizyty = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    wizyty = await storage.loadWizyty();
    setState(() {});
  }

  Future save() async {
    await storage.saveWizyty(wizyty);
  }

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

                Text(
                  data == null ? "Brak daty" : data.toString().split(" ")[0],
                ),
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

                  setState(() {
                    wizyty.add(
                      Wizyta(
                        id: DateTime.now().millisecondsSinceEpoch,
                        lekarz: lekarz.text,
                        miejsce: miejsce.text,
                        data: data!,
                        notatki: notatki.text,
                      ),
                    );
                  });

                  await save();
                  Navigator.pop(context);
                },
                child: const Text("Dodaj"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future delete(int id) async {
    wizyty.removeWhere((w) => w.id == id);
    await save();
    setState(() {});
  }

  String format(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        title: Text(
          "Moje wizyty",
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

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    elevation: 10,
                    shadowColor: Colors.pink.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TOP ROW
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFE91E63),
                                child: const Icon(
                                  Icons.medical_services,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  w.lekarz,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => delete(w.id!),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          /// MIEJSCE
                          Row(
                            children: [
                              const Icon(
                                Icons.local_hospital,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                w.miejsce,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// DATA (chip)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Color(0xFFE91E63),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  format(w.data),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFE91E63),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// NOTATKI
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.notes,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  w.notatki.isEmpty
                                      ? "Brak notatek"
                                      : w.notatki,
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

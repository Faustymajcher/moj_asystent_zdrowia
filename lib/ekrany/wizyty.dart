import 'package:flutter/material.dart';
import '../modele/wizyta.dart';
import '../baza/baza_danych.dart';

class WizytyPage extends StatefulWidget {
  const WizytyPage({super.key});

  @override
  State<WizytyPage> createState() => _WizytyPageState();
}

class _WizytyPageState extends State<WizytyPage> {
  final lekarzCtrl = TextEditingController();
  final miejsceCtrl = TextEditingController();
  final notatkiCtrl = TextEditingController();

  DateTime? data;
  List<Wizyta> wizyty = [];

  @override
  void initState() {
    super.initState();
    odswiez();
  }

  Future<void> odswiez() async {
    final lista = await BazaDanych.instance.pobierzWizyty();
    setState(() => wizyty = lista);
  }

  Future<void> wybierzDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => data = picked);
    }
  }

  Future<void> dodaj() async {
    if (data == null || lekarzCtrl.text.isEmpty || miejsceCtrl.text.isEmpty)
      return;

    final w = Wizyta(
      data: data!,
      lekarz: lekarzCtrl.text,
      miejsce: miejsceCtrl.text,
      notatki: notatkiCtrl.text,
    );

    await BazaDanych.instance.dodajWizyte(w);

    lekarzCtrl.clear();
    miejsceCtrl.clear();
    notatkiCtrl.clear();
    data = null;

    odswiez();
  }

  Future<void> usun(int id) async {
    await BazaDanych.instance.usunWizyte(id);
    odswiez();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Wizyty lekarskie"),
        centerTitle: true,
        elevation: 0,
      ),

      body: Column(
        children: [
          // 🟣 FORMULARZ (KARTA)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: lekarzCtrl,
                      decoration: const InputDecoration(
                        labelText: "Lekarz",
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: miejsceCtrl,
                      decoration: const InputDecoration(
                        labelText: "Miejsce",
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: notatkiCtrl,
                      decoration: const InputDecoration(
                        labelText: "Notatki",
                        prefixIcon: Icon(Icons.note),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.blue.shade700),

                        const SizedBox(width: 8),

                        Text(
                          data == null
                              ? "Wybierz datę"
                              : "${data!.year}-${data!.month.toString().padLeft(2, '0')}-${data!.day.toString().padLeft(2, '0')}",
                          style: const TextStyle(fontSize: 16),
                        ),

                        const Spacer(),

                        ElevatedButton(
                          onPressed: wybierzDate,
                          child: const Text("Data"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: dodaj,
                        icon: const Icon(Icons.add),
                        label: const Text("Dodaj wizytę"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 5),

          // 🔵 LISTA
          Expanded(
            child: wizyty.isEmpty
                ? const Center(
                    child: Text(
                      "Brak wizyt",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: wizyty.length,
                    itemBuilder: (context, index) {
                      final w = wizyty[index];

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),

                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(
                              Icons.medical_services,
                              color: Colors.blue,
                            ),
                          ),

                          title: Text(
                            w.lekarz,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              "${w.miejsce}\n${w.data.toString().split(' ')[0]}\n${w.notatki}",
                            ),
                          ),

                          isThreeLine: true,

                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              if (w.id != null) usun(w.id!);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

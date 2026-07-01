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

  DateTime? wybranaData;
  List<Wizyta> wizyty = [];

  @override
  void initState() {
    super.initState();
    zaladujWizyty();
  }

  Future<void> zaladujWizyty() async {
    final dane = await BazaDanych.instance.pobierzWizyty();
    setState(() {
      wizyty = dane;
    });
  }

  Future<void> wybierzDate() async {
    final data = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (data != null) {
      setState(() {
        wybranaData = data;
      });
    }
  }

  Future<void> dodajWizyte() async {
    if (wybranaData == null) return;

    final wizyta = Wizyta(
      data: wybranaData!,
      lekarz: lekarzCtrl.text,
      miejsce: miejsceCtrl.text,
      notatki: notatkiCtrl.text,
    );

    await BazaDanych.instance.dodajWizyte(wizyta);

    lekarzCtrl.clear();
    miejsceCtrl.clear();
    notatkiCtrl.clear();
    wybranaData = null;

    zaladujWizyty();
  }

  Future<void> usun(int id) async {
    await BazaDanych.instance.usunWizyte(id);
    zaladujWizyty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wizyty lekarskie")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: lekarzCtrl,
                  decoration: const InputDecoration(labelText: "Lekarz"),
                ),
                TextField(
                  controller: miejsceCtrl,
                  decoration: const InputDecoration(labelText: "Miejsce"),
                ),
                TextField(
                  controller: notatkiCtrl,
                  decoration: const InputDecoration(labelText: "Notatki"),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Text(
                      wybranaData == null
                          ? "Nie wybrano daty"
                          : wybranaData!.toString().split(" ")[0],
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: wybierzDate,
                      child: const Text("Wybierz datę"),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: dodajWizyte,
                  child: const Text("Dodaj wizytę"),
                ),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: ListView.builder(
              itemCount: wizyty.length,
              itemBuilder: (context, index) {
                final w = wizyty[index];

                return Card(
                  child: ListTile(
                    title: Text(w.lekarz),
                    subtitle: Text(
                      "${w.miejsce}\n${w.data.toString().split(' ')[0]}\n${w.notatki}",
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        if (w.id != null) {
                          usun(w.id!);
                        }
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

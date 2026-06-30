import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../modele/wizyta.dart';
import '../baza danych/baza_danych.dart';

class Wizyty extends StatefulWidget {
  const Wizyty({super.key});

  @override
  State<Wizyty> createState() {
    return _WizytyState();
  }
}

class _WizytyState extends State<Wizyty> {
  DateTime _wybranyDzien = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final TextEditingController _lekarzController = TextEditingController();
  final TextEditingController _miejsceController = TextEditingController();
  final TextEditingController _notatkiController = TextEditingController();

  List<Wizyta> _wizyty = [];
  @override
  Widget build(BuildContext context) {
    int myIndex = 4;
    return Scaffold(
      appBar: AppBar(title: const Text("Wizyty lekarskie")),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _dodajWizyte();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2035, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_wybranyDzien, day);
          },
          onDaySelected: (selectedDay, focusedDay) async {
            _wybranyDzien = selectedDay;
            _focusedDay = focusedDay;

            _wizyty = await BazaDanych.instance.pobierzWizytyZDnia(selectedDay);

            setState(() {});
          },
        ),

        const SizedBox(height: 10),

        Expanded(
          child: _wizyty.isEmpty
              ? const Center(child: Text("Brak wizyt tego dnia"))
              : ListView.builder(
                  itemCount: _wizyty.length,
                  itemBuilder: (context, index) {
                    final w = _wizyty[index];

                    return Card(
                      child: ListTile(
                        title: Text(w.lekarz),
                        subtitle: Text("${w.miejsce}\n${w.notatki}"),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await BazaDanych.instance.usunWizyte(w.id!);

                            _wizyty = await BazaDanych.instance
                                .pobierzWizytyZDnia(_wybranyDzien);

                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _dodajWizyte() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Dodaj wizytę"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _lekarzController,
                decoration: const InputDecoration(labelText: "Lekarz"),
              ),
              TextField(
                controller: _miejsceController,
                decoration: const InputDecoration(labelText: "Miejsce"),
              ),
              TextField(
                controller: _notatkiController,
                decoration: const InputDecoration(labelText: "Notatki"),
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
                final wizyta = Wizyta(
                  data: _wybranyDzien,
                  lekarz: _lekarzController.text,
                  miejsce: _miejsceController.text,
                  notatki: _notatkiController.text,
                );

                await BazaDanych.instance.dodajWizyte(wizyta);

                _lekarzController.clear();
                _miejsceController.clear();
                _notatkiController.clear();

                _wizyty = await BazaDanych.instance.pobierzWizytyZDnia(
                  _wybranyDzien,
                );

                setState(() {});

                Navigator.pop(context);
              },
              child: const Text("Zapisz"),
            ),
          ],
        );
      },
    );
  }
}

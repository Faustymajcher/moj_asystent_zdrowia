import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../baza/baza_danych.dart';
import '../modele/woda_wpis.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  int _waterTarget = 2000;
  double _weight = 70.0;
  List<WodaWpis> _todayDrinks = [];

  String get _todayDate {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  int get _drunkWater {
    int total = 0;
    for (var drink in _todayDrinks) {
      total += drink.ilosc;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _loadSettingsAndData();
  }

  Future<void> _loadSettingsAndData() async {
    final prefs = await SharedPreferences.getInstance();

    // Waga i cel zostają w SharedPreferences (to ustawienia)
    setState(() {
      _weight = prefs.getDouble('user_weight') ?? 70.0;
      _waterTarget = (_weight * 35).round();
    });

    _refreshDrinks();
  }

  Future<void> _refreshDrinks() async {
    final wpisy = await BazaDanych.instance.pobierzWpisyWodyZDnia(_todayDate);
    setState(() {
      _todayDrinks = wpisy;
    });
  }

  Future<void> _addWater(int amount) async {
    DateTime now = DateTime.now();
    String godzina =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final wpis = WodaWpis(data: _todayDate, godzina: godzina, ilosc: amount);

    await BazaDanych.instance.dodajWpisWody(wpis);
    _refreshDrinks();
  }

  Future<void> _removeDrink(int id) async {
    await BazaDanych.instance.usunWpisWody(id);
    _refreshDrinks();
  }

  void _showCustomWaterDialog() {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Dodaj inną ilość",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Ilość wody",
            suffixText: "ml",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anuluj", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63), // Kolor aplikacji
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              int? amount = int.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                _addWater(amount);
              }
              Navigator.pop(context);
            },
            child: const Text("Dodaj"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = _waterTarget > 0 ? _drunkWater / _waterTarget : 0.0;
    if (progress > 1.0) progress = 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F8), // Tło aplikacji
      appBar: AppBar(
        title: Text(
          "Nawodnienie",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 32),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 15,
                    backgroundColor: const Color(0xFFE91E63).withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFE91E63),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "$_drunkWater ml",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Cel: $_waterTarget ml",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addWater(250),
                  icon: const Icon(Icons.local_drink),
                  label: const Text("250 ml"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _addWater(500),
                  icon: const Icon(Icons.water_drop),
                  label: const Text("500 ml"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC2185B), // Ciemniejszy róż
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: _showCustomWaterDialog,
              icon: const Icon(Icons.add, color: Color(0xFFE91E63)),
              label: const Text(
                "Dodaj inną ilość",
                style: TextStyle(
                  color: Color(0xFFE91E63),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const Divider(height: 30, thickness: 1.5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Dzisiejsze wpisy:",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _todayDrinks.isEmpty
                  ? Center(
                      child: Text(
                        "Jeszcze nic dzisiaj nie wypiłeś/aś.",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _todayDrinks.length,
                      itemBuilder: (context, index) {
                        final drink = _todayDrinks[index];
                        return Card(
                          elevation: 2,
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(
                                0xFFE91E63,
                              ).withOpacity(0.15),
                              child: const Icon(
                                Icons.water_drop,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                            title: Text(
                              "${drink.ilosc} ml",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text("Dodano o: ${drink.godzina}"),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _removeDrink(drink.id!),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
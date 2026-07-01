import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../baza/baza_danych.dart';
import '../modele/wizyta.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Trzy zmienne na dane z różnych tabel
  Future<List<Map<String, dynamic>>>? _historiaWody;
  Future<List<Map<String, dynamic>>>? _historiaLekow;
  Future<List<Wizyta>>? _historiaWizyt;

  @override
  void initState() {
    super.initState();
    _pobierzWszystkieDane();
  }

  void _pobierzWszystkieDane() {
    setState(() {
      _historiaWody = BazaDanych.instance.pobierzHistorieWody();
      //_historiaLekow = BazaDanych.instance.pobierzHistorieLekow();
      _historiaWizyt = BazaDanych.instance.pobierzWizyty(); // Pobiera listę wszystkich wizyt
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Ile mamy zakładek w menu
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF5F8),
        appBar: AppBar(
          title: Text("Moja Historia", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 24)),
          centerTitle: true,
          backgroundColor: const Color(0xFFE91E63),
          foregroundColor: Colors.white,
          elevation: 0,
          // Pasek zakładek
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.water_drop), text: "Woda"),
              Tab(icon: Icon(Icons.medication), text: "Leki"),
              Tab(icon: Icon(Icons.calendar_month), text: "Wizyty"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _budujZkladkeWody(),
            _budujZkladkeLekow(),
            _budujZkladkeWizyt(),
          ],
        ),
      ),
    );
  }

  Widget _budujZkladkeWody() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _historiaWody,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Brak zapisanej historii wody."));

        final historia = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historia.length,
          itemBuilder: (context, index) {
            final wiersz = historia[index];
            return Card(
              elevation: 3,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF4FC3F7), 
                  child: Icon(Icons.water_drop, color: Colors.white)
                ),
                title: Text("Data: ${wiersz['data']}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                trailing: Text("${wiersz['suma']} ml", style: GoogleFonts.poppins(fontSize: 18, color: const Color(0xFF0288D1), fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _budujZkladkeLekow() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _historiaLekow,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Brak zapisanej historii leków."));

        final historia = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historia.length,
          itemBuilder: (context, index) {
            final wiersz = historia[index];
            return Card(
              elevation: 3,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE91E63), 
                  child: Icon(Icons.medication, color: Colors.white)
                ),
                title: Text(wiersz['nazwa'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text("Przyjęto: ${wiersz['data']} o godz. ${wiersz['godzina']}"),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            );
          },
        );
      },
    );
  }

  Widget _budujZkladkeWizyt() {
    return FutureBuilder<List<Wizyta>>(
      future: _historiaWizyt,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Brak zapisanych wizyt."));

        final historia = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historia.length,
          itemBuilder: (context, index) {
            final w = historia[index];
            String formatDaty = "${w.data.year}-${w.data.month.toString().padLeft(2, '0')}-${w.data.day.toString().padLeft(2, '0')}";
            
            return Card(
              elevation: 3,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF009688), 
                  child: Icon(Icons.medical_services, color: Colors.white)
                ),
                title: Text(w.lekarz, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text("Data: $formatDaty\nMiejsce: ${w.miejsce}"),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
import 'baza_danych.dart';

class WodaStorage {
  static final WodaStorage instance = WodaStorage._init();
  WodaStorage._init();

  Future<int> dodajWode(int iloscMl) async {
    final db = await BazaDanych.instance.database;
    
    DateTime now = DateTime.now();
    String dzisiaj = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    String godzina = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    return await db.insert('woda_wpisy', {
      'data': dzisiaj,
      'godzina': godzina,
      'ilosc': iloscMl,
    });
  }

  Future<int> pobierzDzisiejszaWode() async {
    final db = await BazaDanych.instance.database;
    
    DateTime now = DateTime.now();
    String dzisiaj = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final result = await db.rawQuery(
        'SELECT SUM(ilosc) as suma FROM woda_wpisy WHERE data = ?',
        [dzisiaj]);

    if (result.isNotEmpty && result.first['suma'] != null) {
      return (result.first['suma'] as num).toInt();
    }
    return 0;
  }

  Future<void> wyczyscDzisiejszaWode() async {
    final db = await BazaDanych.instance.database;
    
    DateTime now = DateTime.now();
    String dzisiaj = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    await db.delete('woda_wpisy', where: 'data = ?', whereArgs: [dzisiaj]);
  }

  Future<List<Map<String, dynamic>>> pobierzHistorieWody() async {
    final db = await BazaDanych.instance.database;
    return await db.rawQuery(
        'SELECT data, SUM(ilosc) as suma FROM woda_wpisy GROUP BY data ORDER BY data DESC');
  }

  Future<void> aktualizujWodeZDanegoDnia(String data, int nowaSuma) async {
    final db = await BazaDanych.instance.database;
    
    await db.delete('woda_wpisy', where: 'data = ?', whereArgs: [data]);
    
    await db.insert('woda_wpisy', {
      'data': data,
      'godzina': '00:00',
      'ilosc': nowaSuma,
    });
  }
}
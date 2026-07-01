import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'modele/wizyta.dart';

class BazaDanych {
  static final BazaDanych instance = BazaDanych._init();

  static Database? _database;

  BazaDanych._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('wizyty.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wizyty(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT NOT NULL,
        lekarz TEXT NOT NULL,
        miejsce TEXT NOT NULL,
        notatki TEXT
      )
    ''');
  }

  Future<int> dodajWizyte(Wizyta wizyta) async {
    final db = await instance.database;

    return await db.insert(
      'wizyty',
      wizyta.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Wizyta>> pobierzWizyty() async {
    final db = await instance.database;

    final result = await db.query('wizyty', orderBy: 'data ASC');

    return result.map((e) => Wizyta.fromMap(e)).toList();
  }

  Future<List<Wizyta>> pobierzWizytyZDnia(DateTime data) async {
    final db = await instance.database;

    final wszystkie = await db.query('wizyty');

    return wszystkie
        .map((e) => Wizyta.fromMap(e))
        .where(
          (w) =>
              w.data.year == data.year &&
              w.data.month == data.month &&
              w.data.day == data.day,
        )
        .toList();
  }

  Future<int> aktualizujWizyte(Wizyta wizyta) async {
    final db = await instance.database;

    return await db.update(
      'wizyty',
      wizyta.toMap(),
      where: 'id = ?',
      whereArgs: [wizyta.id],
    );
  }

  Future<int> usunWizyte(int id) async {
    final db = await instance.database;

    return await db.delete('wizyty', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

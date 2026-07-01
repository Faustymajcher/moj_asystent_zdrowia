import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modele/wizyta.dart';

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

  Future<int> dodajWizyte(Wizyta w) async {
    final db = await database;
    return await db.insert('wizyty', w.toMap());
  }

  Future<List<Wizyta>> pobierzWizyty() async {
    final db = await database;
    final result = await db.query('wizyty', orderBy: 'data DESC');
    return result.map((e) => Wizyta.fromMap(e)).toList();
  }

  Future<int> aktualizujWizyte(Wizyta w) async {
    final db = await database;
    return await db.update(
      'wizyty',
      w.toMap(),
      where: 'id = ?',
      whereArgs: [w.id],
    );
  }

  Future<int> usunWizyte(int id) async {
    final db = await database;
    return await db.delete('wizyty', where: 'id = ?', whereArgs: [id]);
  }
}

class Wizyta {
  int? id;
  DateTime data;
  String lekarz;
  String miejsce;
  String notatki;

  Wizyta({
    this.id,
    required this.data,
    required this.lekarz,
    required this.miejsce,
    required this.notatki,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data.toIso8601String(),
      'lekarz': lekarz,
      'miejsce': miejsce,
      'notatki': notatki,
    };
  }

  factory Wizyta.fromMap(Map<String, dynamic> map) {
    return Wizyta(
      id: map['id'],
      data: DateTime.parse(map['data']),
      lekarz: map['lekarz'],
      miejsce: map['miejsce'],
      notatki: map['notatki'],
    );
  }
}

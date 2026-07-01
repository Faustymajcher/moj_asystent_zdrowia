class WodaWpis {
  final int? id;
  final String data;
  final String godzina;
  final int ilosc;

  WodaWpis({
    this.id,
    required this.data,
    required this.godzina,
    required this.ilosc,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data,
      'godzina': godzina,
      'ilosc': ilosc,
    };
  }

  factory WodaWpis.fromMap(Map<String, dynamic> map) {
    return WodaWpis(
      id: map['id'],
      data: map['data'],
      godzina: map['godzina'],
      ilosc: map['ilosc'],
    );
  }
}
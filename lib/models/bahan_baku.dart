class BahanBaku {
  final int? id;
  final String kodeBahan;
  final String namaBahan;
  final String satuan;
  final double stokAwal;
  final double stokMinimum;
  final double hargaBeli;

  BahanBaku({
    this.id,
    required this.kodeBahan,
    required this.namaBahan,
    required this.satuan,
    required this.stokAwal,
    required this.stokMinimum,
    required this.hargaBeli,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kodeBahan': kodeBahan,
      'namaBahan': namaBahan,
      'satuan': satuan,
      'stokAwal': stokAwal,
      'stokMinimum': stokMinimum,
      'hargaBeli': hargaBeli,
    };
  }

  factory BahanBaku.fromMap(Map<String, dynamic> map) {
    return BahanBaku(
      id: map['id'],
      kodeBahan: map['kodeBahan'],
      namaBahan: map['namaBahan'],
      satuan: map['satuan'],
      stokAwal: map['stokAwal'],
      stokMinimum: map['stokMinimum'],
      hargaBeli: map['hargaBeli'],
    );
  }

  double get stokTersedia => stokAwal;
  bool get stokMenipis => stokAwal <= stokMinimum;
}

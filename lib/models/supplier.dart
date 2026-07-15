class Supplier {
  final int? id;
  final String kodeSupplier;
  final String namaSupplier;
  final String alamat;
  final String nomorKontak;

  Supplier({
    this.id,
    required this.kodeSupplier,
    required this.namaSupplier,
    required this.alamat,
    required this.nomorKontak,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kodeSupplier': kodeSupplier,
      'namaSupplier': namaSupplier,
      'alamat': alamat,
      'nomorKontak': nomorKontak,
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      kodeSupplier: map['kodeSupplier'],
      namaSupplier: map['namaSupplier'],
      alamat: map['alamat'],
      nomorKontak: map['nomorKontak'],
    );
  }
}

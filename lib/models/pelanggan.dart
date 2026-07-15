class Pelanggan {
  final int? id;
  final String nama;
  final String nomorKontak;
  final String? riwayatPembelian;

  Pelanggan({
    this.id,
    required this.nama,
    required this.nomorKontak,
    this.riwayatPembelian,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'nomorKontak': nomorKontak,
      'riwayatPembelian': riwayatPembelian,
    };
  }

  factory Pelanggan.fromMap(Map<String, dynamic> map) {
    return Pelanggan(
      id: map['id'],
      nama: map['nama'],
      nomorKontak: map['nomorKontak'],
      riwayatPembelian: map['riwayatPembelian'],
    );
  }
}

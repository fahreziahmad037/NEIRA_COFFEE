class ProdukMenu {
  final int? id;
  final String kodeMenu;
  final String namaMenu;
  final double hargaJual;
  final bool tersedia;

  ProdukMenu({
    this.id,
    required this.kodeMenu,
    required this.namaMenu,
    required this.hargaJual,
    this.tersedia = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kodeMenu': kodeMenu,
      'namaMenu': namaMenu,
      'hargaJual': hargaJual,
      'tersedia': tersedia ? 1 : 0,
    };
  }

  factory ProdukMenu.fromMap(Map<String, dynamic> map) {
    return ProdukMenu(
      id: map['id'],
      kodeMenu: map['kodeMenu'],
      namaMenu: map['namaMenu'],
      hargaJual: map['hargaJual'],
      tersedia: map['tersedia'] == 1,
    );
  }
}

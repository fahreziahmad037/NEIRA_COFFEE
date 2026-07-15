import 'package:NEIRA_COFFEE/models/produk_menu.dart';

class TransaksiPenjualan {
  final int? id;
  final DateTime tanggal;
  final ProdukMenu menu;
  final int jumlah;
  final double harga;
  final double totalTransaksi;

  TransaksiPenjualan({
    this.id,
    required this.tanggal,
    required this.menu,
    required this.jumlah,
    required this.harga,
    required this.totalTransaksi,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal.toIso8601String(),
      'menuId': menu.id,
      'jumlah': jumlah,
      'harga': harga,
      'totalTransaksi': totalTransaksi,
    };
  }

  factory TransaksiPenjualan.fromMap(
    Map<String, dynamic> map,
    ProdukMenu menu,
  ) {
    return TransaksiPenjualan(
      id: map['id'],
      tanggal: DateTime.parse(map['tanggal']),
      menu: menu,
      jumlah: map['jumlah'],
      harga: map['harga'],
      totalTransaksi: map['totalTransaksi'],
    );
  }
}

import 'package:NEIRA_COFFEE/models/supplier.dart';

class TransaksiPembelian {
  final int? id;
  final DateTime tanggal;
  final Supplier supplier;
  final String namaBahan;
  final double jumlah;
  final double harga;
  final double total;

  TransaksiPembelian({
    this.id,
    required this.tanggal,
    required this.supplier,
    required this.namaBahan,
    required this.jumlah,
    required this.harga,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal.toIso8601String(),
      'supplierId': supplier.id,
      'namaBahan': namaBahan,
      'jumlah': jumlah,
      'harga': harga,
      'total': total,
    };
  }

  factory TransaksiPembelian.fromMap(
    Map<String, dynamic> map,
    Supplier supplier,
  ) {
    return TransaksiPembelian(
      id: map['id'],
      tanggal: DateTime.parse(map['tanggal']),
      supplier: supplier,
      namaBahan: map['namaBahan'],
      jumlah: map['jumlah'],
      harga: map['harga'],
      total: map['total'],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:NEIRA_COFFEE/models/bahan_baku.dart';
import 'package:NEIRA_COFFEE/models/supplier.dart';
import 'package:NEIRA_COFFEE/models/produk_menu.dart';
import 'package:NEIRA_COFFEE/models/transaksi_pembelian.dart';
import 'package:NEIRA_COFFEE/models/transaksi_penjualan.dart';
import 'package:NEIRA_COFFEE/database/database_helper.dart';

class DataProvider extends ChangeNotifier {
  List<BahanBaku> _bahanBaku = [];
  List<Supplier> _suppliers = [];
  List<ProdukMenu> _produkMenu = [];
  List<Map<String, dynamic>> _transaksiPembelian = [];
  List<Map<String, dynamic>> _transaksiPenjualan = [];
  Map<String, dynamic> _laporanKeuangan = {};
  Map<String, dynamic> _laporanStok = {};

  List<BahanBaku> get bahanBaku => _bahanBaku;
  List<Supplier> get suppliers => _suppliers;
  List<ProdukMenu> get produkMenu => _produkMenu;
  List<Map<String, dynamic>> get transaksiPembelian => _transaksiPembelian;
  List<Map<String, dynamic>> get transaksiPenjualan => _transaksiPenjualan;
  Map<String, dynamic> get laporanKeuangan => _laporanKeuangan;
  Map<String, dynamic> get laporanStok => _laporanStok;

  Future<void> loadBahanBaku() async {
    _bahanBaku = await DatabaseHelper().getAllBahanBaku();
    notifyListeners();
  }

  Future<void> loadSuppliers() async {
    _suppliers = await DatabaseHelper().getAllSupplier();
    notifyListeners();
  }

  Future<void> loadProdukMenu() async {
    _produkMenu = await DatabaseHelper().getAllProdukMenu();
    notifyListeners();
  }

  Future<void> loadTransaksiPembelian() async {
    _transaksiPembelian = await DatabaseHelper()
        .getTransaksiPembelianWithSupplier();
    notifyListeners();
  }

  Future<void> loadTransaksiPenjualan() async {
    _transaksiPenjualan = await DatabaseHelper()
        .getTransaksiPenjualanWithMenu();
    notifyListeners();
  }

  Future<void> loadLaporanKeuangan(DateTime start, DateTime end) async {
    _laporanKeuangan = await DatabaseHelper().getLaporanKeuangan(start, end);
    notifyListeners();
  }

  Future<void> loadLaporanStok() async {
    _laporanStok = await DatabaseHelper().getLaporanStok();
    notifyListeners();
  }

  Future<void> addBahanBaku(BahanBaku bahan) async {
    await DatabaseHelper().insertBahanBaku(bahan);
    await loadBahanBaku();
  }

  Future<void> updateBahanBaku(BahanBaku bahan) async {
    await DatabaseHelper().updateBahanBaku(bahan);
    await loadBahanBaku();
  }

  Future<void> deleteBahanBaku(int id) async {
    await DatabaseHelper().deleteBahanBaku(id);
    await loadBahanBaku();
  }

  Future<void> addSupplier(Supplier supplier) async {
    await DatabaseHelper().insertSupplier(supplier);
    await loadSuppliers();
  }

  Future<void> addTransaksiPenjualan(TransaksiPenjualan transaksi) async {
    await DatabaseHelper().insertTransaksiPenjualan(transaksi);
    await loadTransaksiPenjualan();
    await loadBahanBaku();
  }

  Future<void> addTransaksiPembelian(TransaksiPembelian transaksi) async {
    await DatabaseHelper().insertTransaksiPembelian(transaksi);
    await loadTransaksiPembelian();

    final bahan = _bahanBaku.firstWhere(
      (b) => b.namaBahan == transaksi.namaBahan,
      orElse: () => BahanBaku(
        kodeBahan: 'BB${_bahanBaku.length + 1}',
        namaBahan: transaksi.namaBahan,
        satuan: 'kg',
        stokAwal: 0,
        stokMinimum: 0,
        hargaBeli: transaksi.harga,
      ),
    );

    final updatedBahan = BahanBaku(
      id: bahan.id,
      kodeBahan: bahan.kodeBahan,
      namaBahan: bahan.namaBahan,
      satuan: bahan.satuan,
      stokAwal: bahan.stokAwal + transaksi.jumlah,
      stokMinimum: bahan.stokMinimum,
      hargaBeli: bahan.hargaBeli,
    );

    await DatabaseHelper().updateBahanBaku(updatedBahan);
    await loadBahanBaku();
  }

  void loadAllData() async {
    await loadBahanBaku();
    await loadSuppliers();
    await loadProdukMenu();
    await loadTransaksiPembelian();
    await loadTransaksiPenjualan();
    await loadLaporanStok();

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    await loadLaporanKeuangan(start, now);
  }
}

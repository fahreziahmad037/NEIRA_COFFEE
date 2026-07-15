import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:NEIRA_COFFEE/models/user.dart';
import 'package:NEIRA_COFFEE/models/bahan_baku.dart';
import 'package:NEIRA_COFFEE/models/supplier.dart';
import 'package:NEIRA_COFFEE/models/produk_menu.dart';
import 'package:NEIRA_COFFEE/models/transaksi_pembelian.dart';
import 'package:NEIRA_COFFEE/models/transaksi_penjualan.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'neira_coffee.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // Tabel Bahan Baku
    await db.execute('''
      CREATE TABLE bahan_baku (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kodeBahan TEXT NOT NULL UNIQUE,
        namaBahan TEXT NOT NULL,
        satuan TEXT NOT NULL,
        stokAwal REAL NOT NULL,
        stokMinimum REAL NOT NULL,
        hargaBeli REAL NOT NULL
      )
    ''');

    // Tabel Supplier
    await db.execute('''
      CREATE TABLE supplier (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kodeSupplier TEXT NOT NULL UNIQUE,
        namaSupplier TEXT NOT NULL,
        alamat TEXT NOT NULL,
        nomorKontak TEXT NOT NULL
      )
    ''');

    // Tabel Produk Menu
    await db.execute('''
      CREATE TABLE produk_menu (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kodeMenu TEXT NOT NULL UNIQUE,
        namaMenu TEXT NOT NULL,
        hargaJual REAL NOT NULL,
        tersedia INTEGER NOT NULL
      )
    ''');

    // Tabel Transaksi Pembelian
    await db.execute('''
      CREATE TABLE transaksi_pembelian (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NOT NULL,
        supplierId INTEGER NOT NULL,
        namaBahan TEXT NOT NULL,
        jumlah REAL NOT NULL,
        harga REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (supplierId) REFERENCES supplier (id)
      )
    ''');

    // Tabel Transaksi Penjualan
    await db.execute('''
      CREATE TABLE transaksi_penjualan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NOT NULL,
        menuId INTEGER NOT NULL,
        jumlah INTEGER NOT NULL,
        harga REAL NOT NULL,
        totalTransaksi REAL NOT NULL,
        FOREIGN KEY (menuId) REFERENCES produk_menu (id)
      )
    ''');

    // Insert data dummy
    await _insertDummyData(db);
  }

  Future<void> _insertDummyData(Database db) async {
    // Insert Users
    await db.insert('users', {
      'nama': 'Miser Ropa',
      'username': 'owner',
      'password': 'owner123',
      'role': 'Owner',
    });
    await db.insert('users', {
      'nama': 'Salzabila Risky',
      'username': 'admin',
      'password': 'admin123',
      'role': 'Admin',
    });
    await db.insert('users', {
      'nama': 'Ahmad Rifai',
      'username': 'gudang',
      'password': 'gudang123',
      'role': 'Gudang',
    });
    await db.insert('users', {
      'nama': 'Tasya Sapturi',
      'username': 'kasir',
      'password': 'kasir123',
      'role': 'Kasir',
    });

    // Insert Suppliers
    await db.insert('supplier', {
      'kodeSupplier': 'SUP001',
      'namaSupplier': 'PT Kopi Nusantara',
      'alamat': 'Jl. Kopi No. 123, Jakarta',
      'nomorKontak': '08123456789',
    });
    await db.insert('supplier', {
      'kodeSupplier': 'SUP002',
      'namaSupplier': 'CV Susu Segar',
      'alamat': 'Jl. Susu No. 45, Bandung',
      'nomorKontak': '08198765432',
    });

    // Insert Bahan Baku
    await db.insert('bahan_baku', {
      'kodeBahan': 'BB001',
      'namaBahan': 'Biji Kopi Arabika',
      'satuan': 'kg',
      'stokAwal': 50,
      'stokMinimum': 10,
      'hargaBeli': 150000,
    });
    await db.insert('bahan_baku', {
      'kodeBahan': 'BB002',
      'namaBahan': 'Susu UHT',
      'satuan': 'liter',
      'stokAwal': 30,
      'stokMinimum': 5,
      'hargaBeli': 25000,
    });

    // Insert Produk Menu
    await db.insert('produk_menu', {
      'kodeMenu': 'PM001',
      'namaMenu': 'Espresso',
      'hargaJual': 25000,
      'tersedia': 1,
    });
    await db.insert('produk_menu', {
      'kodeMenu': 'PM002',
      'namaMenu': 'Cappuccino',
      'hargaJual': 35000,
      'tersedia': 1,
    });
    await db.insert('produk_menu', {
      'kodeMenu': 'PM003',
      'namaMenu': 'Latte',
      'hargaJual': 30000,
      'tersedia': 1,
    });

    // Insert Transaksi Penjualan
    await db.insert('transaksi_penjualan', {
      'tanggal': DateTime.now().toIso8601String(),
      'menuId': 1,
      'jumlah': 5,
      'harga': 25000,
      'totalTransaksi': 125000,
    });
  }

  // User CRUD
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> login(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Bahan Baku CRUD
  Future<List<BahanBaku>> getAllBahanBaku() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bahan_baku');
    return maps.map((map) => BahanBaku.fromMap(map)).toList();
  }

  Future<int> insertBahanBaku(BahanBaku bahanBaku) async {
    final db = await database;
    return await db.insert('bahan_baku', bahanBaku.toMap());
  }

  Future<int> updateBahanBaku(BahanBaku bahanBaku) async {
    final db = await database;
    return await db.update(
      'bahan_baku',
      bahanBaku.toMap(),
      where: 'id = ?',
      whereArgs: [bahanBaku.id],
    );
  }

  Future<int> deleteBahanBaku(int id) async {
    final db = await database;
    return await db.delete('bahan_baku', where: 'id = ?', whereArgs: [id]);
  }

  Future<BahanBaku?> getBahanBakuById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bahan_baku',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return BahanBaku.fromMap(maps.first);
    }
    return null;
  }

  // Supplier CRUD
  Future<List<Supplier>> getAllSupplier() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('supplier');
    return maps.map((map) => Supplier.fromMap(map)).toList();
  }

  Future<int> insertSupplier(Supplier supplier) async {
    final db = await database;
    return await db.insert('supplier', supplier.toMap());
  }

  Future<Supplier?> getSupplierById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'supplier',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Supplier.fromMap(maps.first);
    }
    return null;
  }

  // Produk Menu CRUD
  Future<List<ProdukMenu>> getAllProdukMenu() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('produk_menu');
    return maps.map((map) => ProdukMenu.fromMap(map)).toList();
  }

  Future<ProdukMenu?> getProdukMenuById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produk_menu',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ProdukMenu.fromMap(maps.first);
    }
    return null;
  }

  // Transaksi Pembelian
  Future<int> insertTransaksiPembelian(TransaksiPembelian transaksi) async {
    final db = await database;
    return await db.insert('transaksi_pembelian', transaksi.toMap());
  }

  Future<List<Map<String, dynamic>>> getTransaksiPembelianWithSupplier() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT tp.*, s.namaSupplier 
      FROM transaksi_pembelian tp
      JOIN supplier s ON tp.supplierId = s.id
      ORDER BY tp.tanggal DESC
    ''');
  }

  // Transaksi Penjualan
  Future<int> insertTransaksiPenjualan(TransaksiPenjualan transaksi) async {
    final db = await database;
    return await db.insert('transaksi_penjualan', transaksi.toMap());
  }

  Future<List<Map<String, dynamic>>> getTransaksiPenjualanWithMenu() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT tp.*, pm.namaMenu 
      FROM transaksi_penjualan tp
      JOIN produk_menu pm ON tp.menuId = pm.id
      ORDER BY tp.tanggal DESC
    ''');
  }

  // Laporan
  Future<Map<String, dynamic>> getLaporanKeuangan(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;

    final penjualanResult = await db.rawQuery(
      '''
      SELECT SUM(totalTransaksi) as totalPenjualan
      FROM transaksi_penjualan
      WHERE tanggal BETWEEN ? AND ?
    ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    double totalPenjualan =
        penjualanResult.first['totalPenjualan'] as double? ?? 0.0;

    final pembelianResult = await db.rawQuery(
      '''
      SELECT SUM(total) as totalPembelian
      FROM transaksi_pembelian
      WHERE tanggal BETWEEN ? AND ?
    ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    double totalPembelian =
        pembelianResult.first['totalPembelian'] as double? ?? 0.0;

    final jumlahPenjualan = await db.rawQuery(
      '''
      SELECT COUNT(*) as jumlah
      FROM transaksi_penjualan
      WHERE tanggal BETWEEN ? AND ?
    ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    int totalTransaksi = jumlahPenjualan.first['jumlah'] as int? ?? 0;

    return {
      'totalPenjualan': totalPenjualan,
      'totalPembelian': totalPembelian,
      'labaKotor': totalPenjualan - totalPembelian,
      'totalTransaksi': totalTransaksi,
    };
  }

  Future<Map<String, dynamic>> getLaporanStok() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalBahan,
        SUM(CASE WHEN stokAwal <= stokMinimum THEN 1 ELSE 0 END) as stokMenipis,
        SUM(stokAwal) as totalStok
      FROM bahan_baku
    ''');

    return {
      'totalBahan': result.first['totalBahan'] as int? ?? 0,
      'stokMenipis': result.first['stokMenipis'] as int? ?? 0,
      'totalStok': result.first['totalStok'] as double? ?? 0.0,
    };
  }
}

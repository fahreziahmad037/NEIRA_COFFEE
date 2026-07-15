import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NEIRA_COFFEE/providers/data_provider.dart';
import 'package:NEIRA_COFFEE/models/transaksi_pembelian.dart';
import 'package:NEIRA_COFFEE/widgets/custom_textfield.dart';

class PembelianScreen extends StatefulWidget {
  const PembelianScreen({super.key});

  @override
  State<PembelianScreen> createState() => _PembelianScreenState();
}

class _PembelianScreenState extends State<PembelianScreen> {
  final TextEditingController _namaBahanController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  int? _selectedSupplierId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false)
          .loadTransaksiPembelian();
      Provider.of<DataProvider>(context, listen: false).loadSuppliers();
    });
  }

  @override
  void dispose() {
    _namaBahanController.dispose();
    _jumlahController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  void _showAddPembelianDialog() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Pembelian'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedSupplierId,
                decoration: const InputDecoration(
                  labelText: 'Supplier',
                  border: OutlineInputBorder(),
                ),
                items: dataProvider.suppliers.map((supplier) {
                  return DropdownMenuItem<int>(
                    value: supplier.id,
                    child: Text(supplier.namaSupplier),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSupplierId = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _namaBahanController,
                label: 'Nama Bahan',
                hintText: 'Masukkan nama bahan',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _jumlahController,
                label: 'Jumlah',
                hintText: 'Masukkan jumlah',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _hargaController,
                label: 'Harga Satuan',
                hintText: 'Masukkan harga satuan',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearFields();
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _savePembelian(dataProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6F4E37),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePembelian(DataProvider dataProvider) async {
    if (_selectedSupplierId == null ||
        _namaBahanController.text.isEmpty ||
        _jumlahController.text.isEmpty ||
        _hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    try {
      final supplier = dataProvider.suppliers.firstWhere(
        (s) => s.id == _selectedSupplierId,
      );

      final jumlah = double.parse(_jumlahController.text);
      final harga = double.parse(_hargaController.text);
      final total = jumlah * harga;

      final transaksi = TransaksiPembelian(
        tanggal: DateTime.now(),
        supplier: supplier,
        namaBahan: _namaBahanController.text,
        jumlah: jumlah,
        harga: harga,
        total: total,
      );

      await dataProvider.addTransaksiPembelian(transaksi);

      _clearFields();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Pembelian berhasil dicatat'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearFields() {
    _namaBahanController.clear();
    _jumlahController.clear();
    _hargaController.clear();
    setState(() {
      _selectedSupplierId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pembelian Bahan Baku'),
            backgroundColor: const Color(0xFF6F4E37),
            foregroundColor: Colors.white,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddPembelianDialog,
            child: const Icon(Icons.add),
            backgroundColor: const Color(0xFF6F4E37),
          ),
          body: data.transaksiPembelian.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada transaksi pembelian',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tekan tombol + untuk mencatat pembelian',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.transaksiPembelian.length,
                  itemBuilder: (context, index) {
                    final item = data.transaksiPembelian[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF6F4E37),
                          child: const Icon(
                            Icons.shopping_basket,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          item['namaBahan'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Supplier: ${item['namaSupplier'] ?? '-'}'),
                            Text('Jumlah: ${item['jumlah']}'),
                            Text(
                                'Harga: Rp ${(item['harga'] ?? 0).toStringAsFixed(0)}'),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Rp ${(item['total'] ?? 0).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6F4E37),
                              ),
                            ),
                            Text(
                              item['tanggal'] != null
                                  ? DateTime.parse(item['tanggal'])
                                      .toString()
                                      .split(' ')[0]
                                  : '-',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

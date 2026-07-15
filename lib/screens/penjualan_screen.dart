import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NEIRA_COFFEE/providers/data_provider.dart';
import 'package:NEIRA_COFFEE/models/transaksi_penjualan.dart';

class PenjualanScreen extends StatefulWidget {
  const PenjualanScreen({super.key});

  @override
  State<PenjualanScreen> createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  int? _selectedMenuId;
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false)
          .loadTransaksiPenjualan();
      Provider.of<DataProvider>(context, listen: false).loadProdukMenu();
    });
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  void _showAddPenjualanDialog() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Penjualan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedMenuId,
                decoration: const InputDecoration(
                  labelText: 'Menu',
                  border: OutlineInputBorder(),
                ),
                items: dataProvider.produkMenu.map((menu) {
                  return DropdownMenuItem<int>(
                    value: menu.id,
                    child: Text(
                        '${menu.namaMenu} - Rp ${menu.hargaJual.toStringAsFixed(0)}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMenuId = value;
                    if (value != null) {
                      final menu = dataProvider.produkMenu
                          .firstWhere((m) => m.id == value);
                      _nominalController.text = menu.hargaJual.toString();
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga Satuan',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
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
              await _savePenjualan(dataProvider);
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

  Future<void> _savePenjualan(DataProvider dataProvider) async {
    if (_selectedMenuId == null || _jumlahController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    try {
      final menu = dataProvider.produkMenu.firstWhere(
        (m) => m.id == _selectedMenuId,
      );

      final jumlah = int.parse(_jumlahController.text);
      final total = menu.hargaJual * jumlah;

      final transaksi = TransaksiPenjualan(
        tanggal: DateTime.now(),
        menu: menu,
        jumlah: jumlah,
        harga: menu.hargaJual,
        totalTransaksi: total,
      );

      await dataProvider.addTransaksiPenjualan(transaksi);

      _clearFields();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Penjualan berhasil dicatat'),
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
    _jumlahController.clear();
    _nominalController.clear();
    setState(() {
      _selectedMenuId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Penjualan'),
            backgroundColor: const Color(0xFF6F4E37),
            foregroundColor: Colors.white,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddPenjualanDialog,
            child: const Icon(Icons.add),
            backgroundColor: const Color(0xFF6F4E37),
          ),
          body: data.transaksiPenjualan.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.point_of_sale, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada transaksi penjualan',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tekan tombol + untuk mencatat penjualan',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.transaksiPenjualan.length,
                  itemBuilder: (context, index) {
                    final item = data.transaksiPenjualan[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: const Icon(Icons.sell, color: Colors.white),
                        ),
                        title: Text(
                          item['namaMenu'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Jumlah: ${item['jumlah']} pcs',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Rp ${(item['totalTransaksi'] ?? 0).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
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
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

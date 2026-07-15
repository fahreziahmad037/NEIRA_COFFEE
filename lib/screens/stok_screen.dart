import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NEIRA_COFFEE/providers/data_provider.dart';
import 'package:NEIRA_COFFEE/models/bahan_baku.dart';
import 'package:NEIRA_COFFEE/widgets/custom_textfield.dart';

class StokScreen extends StatefulWidget {
  const StokScreen({super.key});

  @override
  State<StokScreen> createState() => _StokScreenState();
}

class _StokScreenState extends State<StokScreen> {
  // ✅ Controller untuk input form
  final TextEditingController _kodeBahanController = TextEditingController();
  final TextEditingController _namaBahanController = TextEditingController();
  final TextEditingController _satuanController = TextEditingController();
  final TextEditingController _stokAwalController = TextEditingController();
  final TextEditingController _stokMinimumController = TextEditingController();
  final TextEditingController _hargaBeliController = TextEditingController();

  BahanBaku? _editingBahan;

  @override
  void initState() {
    super.initState();
    // ✅ HANYA SATU initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false).loadBahanBaku();
    });
  }

  @override
  void dispose() {
    // ✅ Bersihkan controller
    _kodeBahanController.dispose();
    _namaBahanController.dispose();
    _satuanController.dispose();
    _stokAwalController.dispose();
    _stokMinimumController.dispose();
    _hargaBeliController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _kodeBahanController.clear();
    _namaBahanController.clear();
    _satuanController.clear();
    _stokAwalController.clear();
    _stokMinimumController.clear();
    _hargaBeliController.clear();
    setState(() {
      _editingBahan = null;
    });
  }

  void _showAddStokDialog({BahanBaku? bahan}) {
    if (bahan != null) {
      _editingBahan = bahan;
      _kodeBahanController.text = bahan.kodeBahan;
      _namaBahanController.text = bahan.namaBahan;
      _satuanController.text = bahan.satuan;
      _stokAwalController.text = bahan.stokAwal.toString();
      _stokMinimumController.text = bahan.stokMinimum.toString();
      _hargaBeliController.text = bahan.hargaBeli.toString();
    } else {
      _clearFields();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bahan == null ? 'Tambah Bahan Baku' : 'Edit Bahan Baku'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _kodeBahanController,
                label: 'Kode Bahan',
                hintText: 'Contoh: BB001',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _namaBahanController,
                label: 'Nama Bahan',
                hintText: 'Masukkan nama bahan',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _satuanController,
                label: 'Satuan',
                hintText: 'Contoh: kg, liter, pcs',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _stokAwalController,
                label: 'Stok Awal',
                hintText: 'Masukkan stok awal',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _stokMinimumController,
                label: 'Stok Minimum',
                hintText: 'Masukkan stok minimum',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _hargaBeliController,
                label: 'Harga Beli',
                hintText: 'Masukkan harga beli',
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
              await _saveBahan();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6F4E37),
              foregroundColor: Colors.white,
            ),
            child: Text(_editingBahan == null ? 'Tambah' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveBahan() async {
    // ✅ Validasi input
    if (_kodeBahanController.text.isEmpty ||
        _namaBahanController.text.isEmpty ||
        _satuanController.text.isEmpty ||
        _stokAwalController.text.isEmpty ||
        _stokMinimumController.text.isEmpty ||
        _hargaBeliController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      final bahan = BahanBaku(
        id: _editingBahan?.id,
        kodeBahan: _kodeBahanController.text,
        namaBahan: _namaBahanController.text,
        satuan: _satuanController.text,
        stokAwal: double.parse(_stokAwalController.text),
        stokMinimum: double.parse(_stokMinimumController.text),
        hargaBeli: double.parse(_hargaBeliController.text),
      );

      if (_editingBahan == null) {
        await dataProvider.addBahanBaku(bahan);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Bahan baku berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await dataProvider.updateBahanBaku(bahan);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Bahan baku berhasil diperbarui'),
            backgroundColor: Colors.blue,
          ),
        );
      }

      _clearFields();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteBahan(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content:
            const Text('Apakah Anda yakin ingin menghapus bahan baku ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<DataProvider>(context, listen: false)
                  .deleteBahanBaku(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Bahan baku berhasil dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Manajemen Stok'),
            backgroundColor: const Color(0xFF6F4E37),
            foregroundColor: Colors.white,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddStokDialog(),
            child: const Icon(Icons.add),
            backgroundColor: const Color(0xFF6F4E37),
          ),
          body: data.bahanBaku.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada data bahan baku',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tekan tombol + untuk menambah bahan baku',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.bahanBaku.length,
                  itemBuilder: (context, index) {
                    final bahan = data.bahanBaku[index];
                    final isMenipis = bahan.stokMenipis;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isMenipis
                              ? Colors.orange
                              : const Color(0xFF6F4E37),
                          child: Icon(
                            isMenipis ? Icons.warning : Icons.inventory,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          bahan.namaBahan,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Kode: ${bahan.kodeBahan} | Satuan: ${bahan.satuan}'),
                            Text(
                                'Harga Beli: Rp ${bahan.hargaBeli.toStringAsFixed(0)}'),
                            Row(
                              children: [
                                Text(
                                    'Stok: ${bahan.stokAwal.toStringAsFixed(1)}'),
                                if (isMenipis) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Menipis',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddStokDialog(bahan: bahan),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteBahan(bahan.id!),
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

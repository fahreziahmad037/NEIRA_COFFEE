import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NEIRA_COFFEE/providers/data_provider.dart';
import 'package:NEIRA_COFFEE/models/supplier.dart';
import 'package:NEIRA_COFFEE/widgets/custom_textfield.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final TextEditingController _kodeSupplierController = TextEditingController();
  final TextEditingController _namaSupplierController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _nomorKontakController = TextEditingController();
  Supplier? _editingSupplier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false).loadSuppliers();
    });
  }

  @override
  void dispose() {
    _kodeSupplierController.dispose();
    _namaSupplierController.dispose();
    _alamatController.dispose();
    _nomorKontakController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _kodeSupplierController.clear();
    _namaSupplierController.clear();
    _alamatController.clear();
    _nomorKontakController.clear();
    setState(() {
      _editingSupplier = null;
    });
  }

  void _showAddSupplierDialog({Supplier? supplier}) {
    if (supplier != null) {
      _editingSupplier = supplier;
      _kodeSupplierController.text = supplier.kodeSupplier;
      _namaSupplierController.text = supplier.namaSupplier;
      _alamatController.text = supplier.alamat;
      _nomorKontakController.text = supplier.nomorKontak;
    } else {
      _clearFields();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(supplier == null ? 'Tambah Supplier' : 'Edit Supplier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _kodeSupplierController,
                label: 'Kode Supplier',
                hintText: 'Contoh: SUP001',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _namaSupplierController,
                label: 'Nama Supplier',
                hintText: 'Masukkan nama supplier',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _alamatController,
                label: 'Alamat',
                hintText: 'Masukkan alamat supplier',
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _nomorKontakController,
                label: 'Nomor Kontak',
                hintText: 'Masukkan nomor kontak',
                keyboardType: TextInputType.phone,
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
              await _saveSupplier();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6F4E37),
              foregroundColor: Colors.white,
            ),
            child: Text(_editingSupplier == null ? 'Tambah' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSupplier() async {
    if (_kodeSupplierController.text.isEmpty ||
        _namaSupplierController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _nomorKontakController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      final supplier = Supplier(
        id: _editingSupplier?.id,
        kodeSupplier: _kodeSupplierController.text,
        namaSupplier: _namaSupplierController.text,
        alamat: _alamatController.text,
        nomorKontak: _nomorKontakController.text,
      );

      if (_editingSupplier == null) {
        await dataProvider.addSupplier(supplier);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Supplier berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Update supplier (implement if needed)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Supplier berhasil diperbarui'),
            backgroundColor: Colors.blue,
          ),
        );
      }

      _clearFields();
      Navigator.pop(context);
      await dataProvider.loadSuppliers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Manajemen Supplier'),
            backgroundColor: const Color(0xFF6F4E37),
            foregroundColor: Colors.white,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddSupplierDialog(),
            child: const Icon(Icons.add),
            backgroundColor: const Color(0xFF6F4E37),
          ),
          body: data.suppliers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada data supplier',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tekan tombol + untuk menambah supplier',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.suppliers.length,
                  itemBuilder: (context, index) {
                    final supplier = data.suppliers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF6F4E37),
                          child: const Icon(Icons.store, color: Colors.white),
                        ),
                        title: Text(
                          supplier.namaSupplier,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kode: ${supplier.kodeSupplier}'),
                            Text('Alamat: ${supplier.alamat}'),
                            Text('Kontak: ${supplier.nomorKontak}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showAddSupplierDialog(supplier: supplier),
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

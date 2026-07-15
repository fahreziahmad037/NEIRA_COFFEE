import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:NEIRA_COFFEE/providers/data_provider.dart';

class KeuanganScreen extends StatefulWidget {
  const KeuanganScreen({super.key});

  @override
  State<KeuanganScreen> createState() => _KeuanganScreenState();
}

class _KeuanganScreenState extends State<KeuanganScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      dataProvider.loadLaporanKeuangan(_startDate, _endDate);
      dataProvider.loadLaporanStok();
      dataProvider.loadTransaksiPenjualan();
      dataProvider.loadTransaksiPembelian();
    });
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
        _endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      });
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      await dataProvider.loadLaporanKeuangan(_startDate, _endDate);
    }
  }

  String _formatRupiah(double value) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        final laporan = data.laporanKeuangan;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Laporan Keuangan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${DateFormat('MMMM yyyy').format(_selectedDate)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _showDatePicker,
                    icon: const Icon(Icons.calendar_today),
                    color: const Color(0xFF6F4E37),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Penjualan',
                      _formatRupiah(laporan['totalPenjualan'] ?? 0),
                      Colors.green,
                      Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Pembelian',
                      _formatRupiah(laporan['totalPembelian'] ?? 0),
                      Colors.red,
                      Icons.trending_down,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Laba Kotor
              _buildSummaryCardFull(
                'Laba Kotor',
                _formatRupiah(laporan['labaKotor'] ?? 0),
                Colors.purple,
                Icons.money,
              ),
              const SizedBox(height: 20),

              // Detail Transaksi
              const Text(
                'Detail Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Penjualan List
              if (data.transaksiPenjualan.isNotEmpty) ...[
                const Text(
                  'Penjualan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                ...data.transaksiPenjualan.take(5).map((item) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      dense: true,
                      leading:
                          const Icon(Icons.sell, color: Colors.green, size: 20),
                      title: Text(item['namaMenu'] ?? 'Unknown'),
                      subtitle: Text(
                        '${item['jumlah']} x ${_formatRupiah(item['harga'] ?? 0)}',
                      ),
                      trailing: Text(
                        _formatRupiah(item['totalTransaksi'] ?? 0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                }),
                if (data.transaksiPenjualan.length > 5)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '${data.transaksiPenjualan.length - 5} transaksi lainnya...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
              ],

              const SizedBox(height: 12),

              // Pembelian List
              if (data.transaksiPembelian.isNotEmpty) ...[
                const Text(
                  'Pembelian',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                ...data.transaksiPembelian.take(5).map((item) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.shopping_basket,
                          color: Colors.red, size: 20),
                      title: Text(item['namaBahan'] ?? 'Unknown'),
                      subtitle: Text(
                        'Dari: ${item['namaSupplier'] ?? '-'}',
                      ),
                      trailing: Text(
                        _formatRupiah(item['total'] ?? 0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                }),
                if (data.transaksiPembelian.length > 5)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '${data.transaksiPembelian.length - 5} transaksi lainnya...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCardFull(
      String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:NEIRA_COFFEE/providers/data_provider.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  String _selectedReport = 'Stok';
  final List<String> _reportTypes = [
    'Stok',
    'Penjualan',
    'Pembelian',
    'Keuangan'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      dataProvider.loadLaporanStok();
      dataProvider.loadTransaksiPenjualan();
      dataProvider.loadTransaksiPembelian();

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      dataProvider.loadLaporanKeuangan(start, now);
    });
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
        return Scaffold(
          appBar: AppBar(
            title: const Text('Laporan'),
            backgroundColor: const Color(0xFF6F4E37),
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report Type Selector
                Container(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _reportTypes.length,
                    itemBuilder: (context, index) {
                      final type = _reportTypes[index];
                      final isSelected = _selectedReport == type;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedReport = type;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF6F4E37)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              type,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Report Content
                Expanded(
                  child: _buildReportContent(data),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportContent(DataProvider data) {
    switch (_selectedReport) {
      case 'Stok':
        return _buildStokReport(data);
      case 'Penjualan':
        return _buildPenjualanReport(data);
      case 'Pembelian':
        return _buildPembelianReport(data);
      case 'Keuangan':
        return _buildKeuanganReport(data);
      default:
        return const Center(child: Text('Pilih laporan yang ingin dilihat'));
    }
  }

  Widget _buildStokReport(DataProvider data) {
    final stok = data.laporanStok;

    return ListView(
      children: [
        // Summary
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Total Bahan',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        stok['totalBahan']?.toString() ?? '0',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Stok Menipis',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        stok['stokMenipis']?.toString() ?? '0',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Detail Stok
        const Text(
          'Detail Stok Bahan Baku',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        ...data.bahanBaku.map((bahan) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    bahan.stokMenipis ? Colors.orange : Colors.blue,
                child: Icon(
                  bahan.stokMenipis ? Icons.warning : Icons.inventory,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(bahan.namaBahan),
              subtitle: Text(
                  'Stok: ${bahan.stokAwal.toStringAsFixed(1)} ${bahan.satuan}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Min: ${bahan.stokMinimum.toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (bahan.stokMenipis)
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
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPenjualanReport(DataProvider data) {
    return ListView(
      children: [
        if (data.transaksiPenjualan.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.assessment, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada data penjualan',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          ...data.transaksiPenjualan.map((item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    (data.transaksiPenjualan.indexOf(item) + 1).toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(item['namaMenu'] ?? 'Unknown'),
                subtitle: Text(
                  '${item['jumlah']} x ${_formatRupiah(item['harga'] ?? 0)}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatRupiah(item['totalTransaksi'] ?? 0),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      item['tanggal'] != null
                          ? DateFormat('dd/MM/yy HH:mm')
                              .format(DateTime.parse(item['tanggal']))
                          : '-',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildPembelianReport(DataProvider data) {
    return ListView(
      children: [
        if (data.transaksiPembelian.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.assessment, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada data pembelian',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          ...data.transaksiPembelian.map((item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Text(
                    (data.transaksiPembelian.indexOf(item) + 1).toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(item['namaBahan'] ?? 'Unknown'),
                subtitle: Text('Supplier: ${item['namaSupplier'] ?? '-'}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatRupiah(item['total'] ?? 0),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      item['tanggal'] != null
                          ? DateFormat('dd/MM/yy HH:mm')
                              .format(DateTime.parse(item['tanggal']))
                          : '-',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildKeuanganReport(DataProvider data) {
    final laporan = data.laporanKeuangan;

    return ListView(
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildFinanceCard(
                'Total Penjualan',
                _formatRupiah(laporan['totalPenjualan'] ?? 0),
                Colors.green,
                Icons.arrow_upward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFinanceCard(
                'Total Pembelian',
                _formatRupiah(laporan['totalPembelian'] ?? 0),
                Colors.red,
                Icons.arrow_downward,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rekapitulasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFinanceSummaryItem(
                  'Laba Kotor',
                  _formatRupiah(laporan['labaKotor'] ?? 0),
                  Colors.purple,
                ),
                const Divider(),
                _buildFinanceSummaryItem(
                  'Total Transaksi',
                  laporan['totalTransaksi']?.toString() ?? '0',
                  Colors.blue,
                ),
                const Divider(),
                _buildFinanceSummaryItem(
                  'Status',
                  (laporan['labaKotor'] ?? 0) > 0 ? '🟢 Untung' : '🔴 Rugi',
                  (laporan['labaKotor'] ?? 0) > 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        Text(
          'Total Transaksi Penjualan: ${data.transaksiPenjualan.length}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          'Total Transaksi Pembelian: ${data.transaksiPembelian.length}',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildFinanceCard(
      String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceSummaryItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

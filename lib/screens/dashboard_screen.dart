import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NEIRA_COFFEE/providers/auth_provider.dart';
import 'package:NEIRA_COFFEE/providers/data_provider.dart';
import 'package:NEIRA_COFFEE/widgets/stok_card.dart';
import 'package:NEIRA_COFFEE/screens/pembelian_screen.dart';
import 'package:NEIRA_COFFEE/screens/penjualan_screen.dart';
import 'package:NEIRA_COFFEE/screens/stok_screen.dart';
import 'package:NEIRA_COFFEE/screens/supplier_screen.dart';
import 'package:NEIRA_COFFEE/screens/keuangan_screen.dart';
import 'package:NEIRA_COFFEE/screens/laporan_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardContent(),
    const PembelianScreen(),
    const PenjualanScreen(),
    const StokScreen(),
    const SupplierScreen(),
    const KeuanganScreen(),
    const LaporanScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Pembelian',
    'Penjualan',
    'Stok',
    'Supplier',
    'Keuangan',
    'Laporan',
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.shopping_cart,
    Icons.point_of_sale,
    Icons.inventory,
    Icons.business,
    Icons.account_balance,
    Icons.assessment,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false).loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: const Color(0xFF6F4E37),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    auth.currentUser?.nama[0] ?? 'U',
                    style: const TextStyle(color: Color(0xFF6F4E37)),
                  ),
                ),
                onSelected: (value) {
                  if (value == 'logout') {
                    auth.logout();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF6F4E37),
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Home'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Beli'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale), label: 'Jual'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.inventory), label: 'Stok'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.business), label: 'Supplier'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.account_balance), label: 'Kas'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.assessment), label: 'Lap'),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: const Color(0xFF6F4E37),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF5A3A2B),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.coffee, size: 40, color: Colors.white),
                  const SizedBox(height: 8),
                  const Text(
                    'Neira Coffee',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) => Text(
                      auth.currentUser?.role ?? 'User',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...List.generate(_titles.length, (index) {
              return ListTile(
                leading: Icon(_icons[index], color: Colors.white),
                title: Text(
                  _titles[index],
                  style: const TextStyle(color: Colors.white),
                ),
                selected: _selectedIndex == index,
                selectedTileColor: Colors.white.withOpacity(0.2),
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  Navigator.pop(context);
                },
              );
            }),
            const Divider(color: Colors.white54),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      dataProvider.loadLaporanStok();
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      dataProvider.loadLaporanKeuangan(start, now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Ringkasan usaha Neira Coffee hari ini',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  StokCard(
                    title: 'Total Bahan',
                    value: data.laporanStok['totalBahan']?.toString() ?? '0',
                    icon: Icons.inventory,
                    color: Colors.blue,
                  ),
                  StokCard(
                    title: 'Stok Menipis',
                    value: data.laporanStok['stokMenipis']?.toString() ?? '0',
                    icon: Icons.warning,
                    color: Colors.orange,
                  ),
                  StokCard(
                    title: 'Total Transaksi',
                    value: data.laporanKeuangan['totalTransaksi']?.toString() ??
                        '0',
                    icon: Icons.receipt_long,
                    color: Colors.green,
                  ),
                  StokCard(
                    title: 'Laba Kotor',
                    value:
                        'Rp ${(data.laporanKeuangan['labaKotor'] ?? 0).toStringAsFixed(0)}',
                    icon: Icons.money,
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (data.bahanBaku.where((b) => b.stokMenipis).isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Peringatan Stok Menipis',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...data.bahanBaku
                          .where((b) => b.stokMenipis)
                          .map((bahan) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${bahan.namaBahan} (${bahan.satuan})'),
                              Text(
                                'Sisa: ${bahan.stokAwal.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

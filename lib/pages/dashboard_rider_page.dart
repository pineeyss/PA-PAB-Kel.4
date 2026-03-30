import 'package:flutter/material.dart';
import 'auth/login_page.dart';
import 'transaksi/transaksi_page.dart';
import 'stok/stok_page.dart';

class DashboardRiderPage extends StatelessWidget {
  const DashboardRiderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Rider'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('Input Transaksi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransaksiPage()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Lihat Stok'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StokPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
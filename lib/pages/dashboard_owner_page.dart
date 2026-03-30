import 'package:flutter/material.dart';
import 'auth/login_page.dart';
import 'menu/menu_page.dart';
import 'gerobak/gerobak_page.dart';
import 'rider/rider_page.dart';

class DashboardOwnerPage extends StatelessWidget {
  const DashboardOwnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Owner'),
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
              leading: const Icon(Icons.local_cafe),
              title: const Text('Kelola Menu'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MenuPage()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Kelola Gerobak'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GerobakPage()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delivery_dining),
              title: const Text('Kelola Rider'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RiderPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
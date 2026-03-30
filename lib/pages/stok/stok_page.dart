import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StokPage extends StatefulWidget {
  const StokPage({super.key});

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  final supabase = Supabase.instance.client;

  List stokList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getStok();
  }

  Future<void> getStok() async {
    try {
      final data = await supabase
          .from('stok_gerobak')
          .select('id, stok_awal, stok_saat_ini, menu:menu_id(nama_menu)')
          .order('created_at');

      setState(() {
        stokList = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lihat Stok'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : stokList.isEmpty
              ? const Center(child: Text('Belum ada data stok'))
              : ListView.builder(
                  itemCount: stokList.length,
                  itemBuilder: (context, index) {
                    final stok = stokList[index];
                    final menu = stok['menu'];

                    return Card(
                      child: ListTile(
                        title: Text(menu?['nama_menu'] ?? 'Menu tidak ditemukan'),
                        subtitle: Text(
                          'Stok awal: ${stok['stok_awal']} | Stok saat ini: ${stok['stok_saat_ini']}',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
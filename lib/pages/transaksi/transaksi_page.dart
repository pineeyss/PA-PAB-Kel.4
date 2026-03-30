import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> menuList = [];
  Map<String, dynamic>? selectedMenu;

  final qtyController = TextEditingController();

  int totalHarga = 0;

  @override
  void initState() {
    super.initState();
    getMenus();
  }

  Future<void> getMenus() async {
    final data = await supabase.from('menu').select();

    setState(() {
      menuList = List<Map<String, dynamic>>.from(data);
    });
  }

  void hitungTotal() {
    if (selectedMenu != null && qtyController.text.isNotEmpty) {
      final harga = (selectedMenu!['harga'] as num).toInt();
      final qty = int.tryParse(qtyController.text) ?? 0;

      setState(() {
        totalHarga = harga * qty;
      });
    } else {
      setState(() {
        totalHarga = 0;
      });
    }
  }

  Future<void> simpanTransaksi() async {
    try {
      final qty = int.tryParse(qtyController.text) ?? 0;

      if (selectedMenu == null || qty == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih menu dan isi qty')),
        );
        return;
      }

      final menuId = selectedMenu!['id'];

      final stokData = await supabase
          .from('stok_gerobak')
          .select()
          .eq('menu_id', menuId)
          .limit(1)
          .single();

      final stokSekarang = (stokData['stok_saat_ini'] as num).toInt();

      if (stokSekarang < qty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stok tidak cukup')),
        );
        return;
      }

      final stokBaru = stokSekarang - qty;

      await supabase
          .from('stok_gerobak')
          .update({'stok_saat_ini': stokBaru})
          .eq('id', stokData['id']);

      await supabase.from('transaksi').insert({
        'total_harga': totalHarga,
        'tanggal': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil')),
      );

      setState(() {
        selectedMenu = null;
        qtyController.clear();
        totalHarga = 0;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Map<String, dynamic>>(
              hint: const Text('Pilih Menu'),
              value: selectedMenu,
              items: menuList.map((menu) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: menu,
                  child: Text(menu['nama_menu']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMenu = value;
                });
                hitungTotal();
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(labelText: 'Qty'),
              keyboardType: TextInputType.number,
              onChanged: (value) => hitungTotal(),
            ),
            const SizedBox(height: 16),
            Text('Total: Rp $totalHarga'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: simpanTransaksi,
              child: const Text('Simpan Transaksi'),
            ),
          ],
        ),
      ),
    );
  }
}
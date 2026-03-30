import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final supabase = Supabase.instance.client;

  List menuList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getMenus();
  }

  Future<void> getMenus() async {
    try {
      final data = await supabase.from('menu').select().order('nama_menu');

      setState(() {
        menuList = data;
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

  Future<void> addMenu(String nama, int harga) async {
    try {
      await supabase.from('menu').insert({
        'nama_menu': nama,
        'harga': harga,
      });

      await getMenus();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu berhasil ditambahkan')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> updateMenu(String id, String nama, int harga) async {
    try {
      await supabase.from('menu').update({
        'nama_menu': nama,
        'harga': harga,
      }).eq('id', id);

      await getMenus();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu berhasil diupdate')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> deleteMenu(String id) async {
    try {
      await supabase.from('menu').delete().eq('id', id);
      await getMenus();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu berhasil dihapus')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void showAddDialog() {
    final namaController = TextEditingController();
    final hargaController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Menu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Menu'),
            ),
            TextField(
              controller: hargaController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final nama = namaController.text.trim();
              final harga = int.tryParse(hargaController.text.trim()) ?? 0;

              Navigator.pop(context);
              addMenu(nama, harga);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void showEditDialog(Map menu) {
    final namaController = TextEditingController(text: menu['nama_menu']);
    final hargaController = TextEditingController(text: menu['harga'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Menu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Menu'),
            ),
            TextField(
              controller: hargaController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final nama = namaController.text.trim();
              final harga = int.tryParse(hargaController.text.trim()) ?? 0;

              Navigator.pop(context);
              updateMenu(menu['id'], nama, harga);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Menu'),
        content: const Text('Yakin ingin menghapus menu ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteMenu(id);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Menu'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : menuList.isEmpty
              ? const Center(child: Text('Belum ada menu'))
              : ListView.builder(
                  itemCount: menuList.length,
                  itemBuilder: (context, index) {
                    final menu = menuList[index];

                    return Card(
                      child: ListTile(
                        title: Text(menu['nama_menu']),
                        subtitle: Text('Harga: Rp ${menu['harga']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => showEditDialog(menu),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () => showDeleteDialog(menu['id']),
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
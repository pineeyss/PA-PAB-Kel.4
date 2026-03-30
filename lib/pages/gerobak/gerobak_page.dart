import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GerobakPage extends StatefulWidget {
  const GerobakPage({super.key});

  @override
  State<GerobakPage> createState() => _GerobakPageState();
}

class _GerobakPageState extends State<GerobakPage> {
  final supabase = Supabase.instance.client;

  List gerobakList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getGerobak();
  }

  Future<void> getGerobak() async {
    try {
      final data = await supabase.from('gerobak').select().order('nama_gerobak');

      setState(() {
        gerobakList = data;
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

  Future<void> addGerobak(String namaGerobak, String lokasi) async {
    try {
      await supabase.from('gerobak').insert({
        'nama_gerobak': namaGerobak,
        'lokasi': lokasi,
      });

      await getGerobak();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gerobak berhasil ditambahkan')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> updateGerobak(String id, String namaGerobak, String lokasi) async {
    try {
      await supabase.from('gerobak').update({
        'nama_gerobak': namaGerobak,
        'lokasi': lokasi,
      }).eq('id', id);

      await getGerobak();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gerobak berhasil diupdate')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> deleteGerobak(String id) async {
    try {
      await supabase.from('gerobak').delete().eq('id', id);
      await getGerobak();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gerobak berhasil dihapus')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void showAddDialog() {
    final namaGerobakController = TextEditingController();
    final lokasiController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Gerobak'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaGerobakController,
              decoration: const InputDecoration(labelText: 'Nama Gerobak'),
            ),
            TextField(
              controller: lokasiController,
              decoration: const InputDecoration(labelText: 'Lokasi'),
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
              final namaGerobak = namaGerobakController.text.trim();
              final lokasi = lokasiController.text.trim();

              Navigator.pop(context);
              addGerobak(namaGerobak, lokasi);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void showEditDialog(Map gerobak) {
    final namaGerobakController =
        TextEditingController(text: gerobak['nama_gerobak']);
    final lokasiController = TextEditingController(text: gerobak['lokasi']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Gerobak'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaGerobakController,
              decoration: const InputDecoration(labelText: 'Nama Gerobak'),
            ),
            TextField(
              controller: lokasiController,
              decoration: const InputDecoration(labelText: 'Lokasi'),
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
              final namaGerobak = namaGerobakController.text.trim();
              final lokasi = lokasiController.text.trim();

              Navigator.pop(context);
              updateGerobak(gerobak['id'], namaGerobak, lokasi);
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
        title: const Text('Hapus Gerobak'),
        content: const Text('Yakin ingin menghapus gerobak ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteGerobak(id);
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
        title: const Text('Kelola Gerobak'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : gerobakList.isEmpty
              ? const Center(child: Text('Belum ada gerobak'))
              : ListView.builder(
                  itemCount: gerobakList.length,
                  itemBuilder: (context, index) {
                    final gerobak = gerobakList[index];

                    return Card(
                      child: ListTile(
                        title: Text(gerobak['nama_gerobak']),
                        subtitle: Text('Lokasi: ${gerobak['lokasi']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => showEditDialog(gerobak),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () => showDeleteDialog(gerobak['id']),
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
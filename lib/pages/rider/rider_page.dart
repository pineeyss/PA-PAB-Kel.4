import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiderPage extends StatefulWidget {
  const RiderPage({super.key});

  @override
  State<RiderPage> createState() => _RiderPageState();
}

class _RiderPageState extends State<RiderPage> {
  final supabase = Supabase.instance.client;

  List riderList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getRiders();
  }

  Future<void> getRiders() async {
    try {
      final data = await supabase.from('riders').select().order('nama_rider');

      setState(() {
        riderList = data;
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

  Future<void> addRider(String namaRider, String noHp) async {
    try {
      await supabase.from('riders').insert({
        'nama_rider': namaRider,
        'no_hp': noHp,
      });

      await getRiders();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rider berhasil ditambahkan')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> updateRider(String id, String namaRider, String noHp) async {
    try {
      await supabase.from('riders').update({
        'nama_rider': namaRider,
        'no_hp': noHp,
      }).eq('id', id);

      await getRiders();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rider berhasil diupdate')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> deleteRider(String id) async {
    try {
      await supabase.from('riders').delete().eq('id', id);
      await getRiders();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rider berhasil dihapus')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void showAddDialog() {
    final namaRiderController = TextEditingController();
    final noHpController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Rider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaRiderController,
              decoration: const InputDecoration(labelText: 'Nama Rider'),
            ),
            TextField(
              controller: noHpController,
              decoration: const InputDecoration(labelText: 'No HP'),
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
              final namaRider = namaRiderController.text.trim();
              final noHp = noHpController.text.trim();

              Navigator.pop(context);
              addRider(namaRider, noHp);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void showEditDialog(Map rider) {
    final namaRiderController =
        TextEditingController(text: rider['nama_rider']);
    final noHpController = TextEditingController(text: rider['no_hp']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Rider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaRiderController,
              decoration: const InputDecoration(labelText: 'Nama Rider'),
            ),
            TextField(
              controller: noHpController,
              decoration: const InputDecoration(labelText: 'No HP'),
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
              final namaRider = namaRiderController.text.trim();
              final noHp = noHpController.text.trim();

              Navigator.pop(context);
              updateRider(rider['id'], namaRider, noHp);
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
        title: const Text('Hapus Rider'),
        content: const Text('Yakin ingin menghapus rider ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteRider(id);
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
        title: const Text('Kelola Rider'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : riderList.isEmpty
              ? const Center(child: Text('Belum ada rider'))
              : ListView.builder(
                  itemCount: riderList.length,
                  itemBuilder: (context, index) {
                    final rider = riderList[index];

                    return Card(
                      child: ListTile(
                        title: Text(rider['nama_rider']),
                        subtitle: Text('No HP: ${rider['no_hp']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => showEditDialog(rider),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () => showDeleteDialog(rider['id']),
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
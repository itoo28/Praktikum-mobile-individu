import 'package:flutter/material.dart';

void main() => runApp(const MahasiswaApp());

class MahasiswaApp extends StatelessWidget {
  const MahasiswaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
      home: const MahasiswaPage(),
    );
  }
}

class MahasiswaPage extends StatefulWidget {
  const MahasiswaPage({super.key});

  @override
  State<MahasiswaPage> createState() => _MahasiswaPageState();
}

class _MahasiswaPageState extends State<MahasiswaPage> {
  // TAHAP 1: Inisialisasi data sementara di RAM.
  final List<Map<String, String>> mahasiswa = [
    {
      'id': '1',
      'nim': '2026001',
      'nama': 'Andi',
      'prodi': 'Informatika',
      'ipk': '3.50',
    },
    {
      'id': '2',
      'nim': '2026002',
      'nama': 'Siti',
      'prodi': 'Informatika',
      'ipk': '4.00',
    },
  ];
  int nextId = 3;

  final TextEditingController _searchController = TextEditingController();
  String keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get dataTampil {
    final q = keyword.trim().toLowerCase();
    return mahasiswa
        .where(
          (m) =>
              m['nama']!.toLowerCase().contains(q) ||
              m['nim']!.toLowerCase().contains(q),
        )
        .toList();
  }

  String _formatIpk(String? raw) {
    final parsed = double.tryParse((raw ?? '').replaceAll(',', '.'));
    if (parsed == null) return raw ?? '-';
    return parsed.toStringAsFixed(2);
  }

  // TAHAP 3: CREATE. Form mengembalikan data baru.
  Future<void> tambahData() async {
    final hasil = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => MahasiswaForm(dataSudahAda: mahasiswa),
    );
    if (!mounted || hasil == null) return;
    setState(() {
      mahasiswa.add({'id': '${nextId++}', ...hasil});
    });
  }

  // TAHAP 4: UPDATE berdasarkan id, BUKAN indeks ListView.
  Future<void> ubahData(Map<String, String> dipilih) async {
    final hasil = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => MahasiswaForm(dataAwal: dipilih, dataSudahAda: mahasiswa),
    );
    if (!mounted || hasil == null) return;
    final index = mahasiswa.indexWhere((m) => m['id'] == dipilih['id']);
    if (index < 0) return;
    setState(() {
      mahasiswa[index] = {'id': dipilih['id']!, ...hasil};
    });
  }

  // TAHAP 5: DELETE dengan dialog konfirmasi.
  Future<void> hapusData(Map<String, String> dipilih) async {
    final colorScheme = Theme.of(context).colorScheme;
    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus data?'),
        content: Text('Hapus ${dipilih['nama']} (${dipilih['nim']})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || setuju != true) return;
    setState(() => mahasiswa.removeWhere((m) => m['id'] == dipilih['id']));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tampil = dataTampil;

    return Scaffold(
      appBar: AppBar(title: const Text('Praktikum 7: Data Mahasiswa')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari nama atau NIM',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: keyword.isNotEmpty
                    ? IconButton(
                        tooltip: 'Bersihkan',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => keyword = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => keyword = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  keyword.trim().isEmpty
                      ? 'Data tersimpan: ${mahasiswa.length}'
                      : 'Data tersimpan: ${mahasiswa.length} • Ditemukan: ${tampil.length}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tampil.isEmpty
                ? Center(
                    child: Text(
                      keyword.trim().isEmpty
                          ? 'Belum ada data mahasiswa'
                          : 'Data tidak ditemukan',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
                    itemCount: tampil.length,
                    itemBuilder: (context, index) {
                      final item = tampil[index];
                      final nama = item['nama'] ?? '';
                      final initial =
                          nama.isNotEmpty ? nama[0].toUpperCase() : '?';
                      final ipkText = _formatIpk(item['ipk']);

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            foregroundColor: colorScheme.onPrimaryContainer,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          title: Text(
                            nama,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${item['nim']} • ${item['prodi']}'),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'IPK $ipkText',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Ubah',
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: colorScheme.primary,
                                ),
                                onPressed: () => ubahData(item),
                              ),
                              IconButton(
                                tooltip: 'Hapus',
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: colorScheme.error,
                                ),
                                onPressed: () => hapusData(item),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: tambahData,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

// Form dipisahkan menjadi widget agar controller memiliki lifecycle yang benar.
class MahasiswaForm extends StatefulWidget {
  final Map<String, String>? dataAwal;
  final List<Map<String, String>> dataSudahAda;

  const MahasiswaForm({super.key, this.dataAwal, required this.dataSudahAda});

  @override
  State<MahasiswaForm> createState() => _MahasiswaFormState();
}

class _MahasiswaFormState extends State<MahasiswaForm> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nim;
  late final TextEditingController nama;
  late final TextEditingController prodi;
  late final TextEditingController ipk;

  @override
  void initState() {
    super.initState();
    nim = TextEditingController(text: widget.dataAwal?['nim'] ?? '');
    nama = TextEditingController(text: widget.dataAwal?['nama'] ?? '');
    prodi = TextEditingController(text: widget.dataAwal?['prodi'] ?? '');
    ipk = TextEditingController(text: widget.dataAwal?['ipk'] ?? '');
  }

  @override
  void dispose() {
    nim.dispose();
    nama.dispose();
    prodi.dispose();
    ipk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dataAwal == null ? 'Tambah Data' : 'Ubah Data'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nim,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'NIM wajib diisi';
                  final sudahAda = widget.dataSudahAda.any(
                    (m) => m['nim'] == v && m['id'] != widget.dataAwal?['id'],
                  );
                  if (sudahAda) return 'NIM sudah digunakan';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nama,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: prodi,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Prodi',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Prodi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: ipk,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'IPK',
                  hintText: 'Contoh: 3.75',
                  prefixIcon: Icon(Icons.grade_outlined),
                ),
                validator: (v) {
                  final raw = (v ?? '').trim().replaceAll(',', '.');
                  if (raw.isEmpty) return 'IPK wajib diisi';
                  final nilai = double.tryParse(raw);
                  if (nilai == null) return 'IPK harus berupa angka';
                  if (nilai < 0.0 || nilai > 4.0) {
                    return 'IPK harus antara 0.00 - 4.00';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            final nilaiIpk = double.parse(
              ipk.text.trim().replaceAll(',', '.'),
            );
            Navigator.pop(context, {
              'nim': nim.text.trim(),
              'nama': nama.text.trim(),
              'prodi': prodi.text.trim(),
              'ipk': nilaiIpk.toStringAsFixed(2),
            });
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

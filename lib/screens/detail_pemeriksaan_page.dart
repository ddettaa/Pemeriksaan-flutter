import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPemeriksaanPage extends StatefulWidget {
  final String noRegistrasi;
  final String noRM;
  final String namaPasien;

  const DetailPemeriksaanPage({
    Key? key,
    this.noRegistrasi = '',
    this.noRM = '',
    this.namaPasien = '',
  }) : super(key: key);

  @override
  State<DetailPemeriksaanPage> createState() => _DetailPemeriksaanPageState();
}

class _DetailPemeriksaanPageState extends State<DetailPemeriksaanPage> {
  // Controller untuk masing-masing input
  final TextEditingController noRegController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController suhuController = TextEditingController();
  final TextEditingController tensiController = TextEditingController();
  final TextEditingController beratBadanController = TextEditingController();
  final TextEditingController tinggiBadanController = TextEditingController();
  final TextEditingController noRMController = TextEditingController();

  // Fungsi validasi
  bool allFieldsFilled() {
    return noRegController.text.isNotEmpty &&
        namaController.text.isNotEmpty &&
        suhuController.text.isNotEmpty &&
        tensiController.text.isNotEmpty &&
        beratBadanController.text.isNotEmpty &&
        tinggiBadanController.text.isNotEmpty;
    // keluhanController dihapus dari validasi
  }

  @override
  void initState() {
    super.initState();
    noRegController.text = widget.noRegistrasi;
    noRMController.text = widget.noRM;
    namaController.text = widget.namaPasien;
  }

  @override
  void dispose() {
    // Hapus controller ketika widget dibuang
    noRegController.dispose();
    namaController.dispose();
    suhuController.dispose();
    tensiController.dispose();
    beratBadanController.dispose();
    tinggiBadanController.dispose();
    noRMController.dispose();
    super.dispose();
  }

  Future<void> submitPemeriksaan() async {
    final url = Uri.parse('https://ti054a02.agussbn.my.id/api/pemeriksaan');
    double suhuDouble =
        double.tryParse(suhuController.text.replaceAll(',', '.')) ?? 0.0;
    int suhuInt = (suhuDouble * 10).round();

    // Gunakan hanya noRMController.text (berisi no_rm)
    final rmValue = noRMController.text;

    final Map<String, dynamic> data = {
      'no_registrasi': noRegController.text,
      'rm': rmValue,
      'suhu': suhuInt,
      'tensi': tensiController.text,
      'tinggi_badan': tinggiBadanController.text,
      'berat_badan': beratBadanController.text,
      'keluhan': '-',
    };

    // Gunakan token static sesuai permintaan
    const token = '338|1l7yAp3VH2ETU1wcY7LjEtQNhisyEJrMraJCE2Pbc071c2fe';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      print(
          'POST PEMERIKSAAN: ${response.request?.url} => ${response.statusCode}');
      print('TOKEN USED: $token');
      print('BODY: ${response.body}');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data pemeriksaan berhasil disimpan!')),
        );
        Navigator.pop(context);
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akses ditolak. Silakan login ulang.')),
        );
      } else {
        // Tampilkan pesan error validasi dari API jika ada
        String msg = 'Gagal simpan data: ${response.body}';
        try {
          final err = json.decode(response.body);
          if (err is Map && err['errors'] != null) {
            msg = (err['errors'] as Map)
                .entries
                .map((e) => '${e.key}: ${(e.value as List).join(', ')}')
                .join('\n');
          }
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hilangkan AppBar, gunakan layout custom
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pemeriksaan Awal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // No Registrasi & No RM
                      Row(
                        children: [
                          Expanded(
                            child: buildReadOnlyField(
                              label: 'No Registrasi',
                              controller: noRegController,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: buildReadOnlyField(
                              label: 'No RM',
                              controller: noRMController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Nama
                      Row(
                        children: [
                          Expanded(
                            child: buildReadOnlyField(
                              label: 'Nama',
                              controller: namaController,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(child: Container()), // Kosongkan kolom kanan
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Suhu & Tinggi Badan
                      Row(
                        children: [
                          Expanded(
                            child: buildInputWithSuffix(
                              label: 'Suhu *',
                              controller: suhuController,
                              suffix: '°C',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: buildInputWithSuffix(
                              label: 'Tinggi Badan *',
                              controller: tinggiBadanController,
                              suffix: 'cm',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tensi & Berat Badan
                      Row(
                        children: [
                          Expanded(
                            child: buildInputWithSuffix(
                              label: 'Tensi *',
                              controller: tensiController,
                              suffix: 'mmHg',
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: buildInputWithSuffix(
                              label: 'Berat Badan *',
                              controller: beratBadanController,
                              suffix: 'kg',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      // Hapus field keluhan
                    ],
                  ),
                ),
              ),
              // Tombol aksi di kanan bawah
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text('BATAL'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (allFieldsFilled()) {
                        await submitPemeriksaan();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Harap isi semua data terlebih dahulu!'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text('SIMPAN'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReadOnlyField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget buildInputWithSuffix({
    required String label,
    required TextEditingController controller,
    String? suffix,
    int maxLines = 1,
    String? hintText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            suffixText: suffix,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_nav.dart';

class HistoriScreen extends StatefulWidget {
  const HistoriScreen({Key? key}) : super(key: key);

  @override
  State<HistoriScreen> createState() => _HistoriScreenState();
}

class _HistoriScreenState extends State<HistoriScreen> {
  List<dynamic> allData = [];
  List<dynamic> filteredData = [];
  bool isLoading = false;
  String searchQuery = '';
  DateTime selectedDate = DateTime.now();

  static const int pageSize = 10;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('https://ti054a01.agussbn.my.id/api/pendaftaran'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200)
        throw Exception('Gagal mengambil data pasien');
      final data = json.decode(response.body);
      if (data != null && data['data'] is List) {
        List<dynamic> patients = data['data'];
        final dateStr = selectedDate.toIso8601String().substring(0, 10);
        patients = patients.where((patient) {
          final tgl =
              (patient['tgl_kunjungan'] ?? '').toString().substring(0, 10);
          final status = patient['status'];
          return tgl == dateStr &&
              (status == 2 ||
                  (status is String &&
                      status.toLowerCase() == 'selesai diperiksa'));
        }).toList();
        setState(() {
          allData = patients;
          filterData();
        });
      } else {
        setState(() {
          allData = [];
          filterData();
        });
      }
    } catch (e) {
      setState(() {
        allData = [];
        filterData();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterData() {
    setState(() {
      filteredData = allData.where((item) {
        final nama = (item['nama_pasien'] ?? '').toString().toLowerCase();
        final rm = (item['rm'] ?? '').toString();
        return searchQuery.isEmpty ||
            nama.contains(searchQuery.toLowerCase()) ||
            rm.contains(searchQuery);
      }).toList();
      currentPage = 1;
    });
  }

  List<dynamic> get pagedData {
    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize) > filteredData.length
        ? filteredData.length
        : (start + pageSize);
    return filteredData.sublist(start, end);
  }

  int get totalPages => (filteredData.length / pageSize).ceil() == 0
      ? 1
      : (filteredData.length / pageSize).ceil();

  Future<Map<String, dynamic>?> fetchPemeriksaanDetail(
      String noRegistrasi) async {
    try {
      // Gunakan token static sesuai permintaan
      const token = '338|1l7yAp3VH2ETU1wcY7LjEtQNhisyEJrMraJCE2Pbc071c2fe';

      final response = await http.get(
        Uri.parse(
            'https://ti054a02.agussbn.my.id/api/pemeriksaan/$noRegistrasi'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('GET DETAIL: ${response.request?.url} => ${response.statusCode}');
      print('TOKEN USED: $token');
      print('BODY: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Ambil dari data['data']['pemeriksaan'] jika ada
        if (data != null &&
            data['data'] != null &&
            data['data']['pemeriksaan'] != null) {
          return data['data']['pemeriksaan'];
        }
        // fallback jika API kadang mengembalikan list/map langsung
        if (data != null && data['data'] is Map && data['data'].isNotEmpty) {
          return data['data'];
        } else if (data != null &&
            data['data'] is List &&
            data['data'].isNotEmpty) {
          return data['data'][0];
        }
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akses ditolak. Silakan login ulang.')),
        );
      }
    } catch (e) {
      print('ERROR fetchPemeriksaanDetail: $e');
    }
    return null;
  }

  void showDetailDialog(BuildContext context, String noRegistrasi) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final detail = await fetchPemeriksaanDetail(noRegistrasi);
    Navigator.pop(context); // close loading dialog

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detail Pemeriksaan'),
        content: detail == null
            ? const Text('Data tidak ditemukan.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No Registrasi: ${detail['no_registrasi'] ?? '-'}'),
                  Text('No RM: ${detail['rm'] ?? '-'}'),
                  Text('Suhu: ${detail['suhu'] ?? '-'}'),
                  Text('Tensi: ${detail['tensi'] ?? '-'}'),
                  Text('Tinggi Badan: ${detail['tinggi_badan'] ?? '-'}'),
                  Text('Berat Badan: ${detail['berat_badan'] ?? '-'}'),
                  if (detail['keluhan'] != null)
                    Text('Keluhan: ${detail['keluhan']}'),
                  if (detail['diagnosa'] != null)
                    Text('Diagnosa: ${detail['diagnosa']}'),
                  if (detail['tindakan'] != null)
                    Text('Tindakan: ${detail['tindakan']}'),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histori Pemeriksaan'),
        backgroundColor: const Color(0xFF688BFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search & Date Filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari nama pasien atau RM...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                    ),
                    onChanged: (val) {
                      searchQuery = val;
                      filterData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 130,
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: selectedDate.toIso8601String().substring(0, 10),
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_today, size: 18),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 8),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                        await fetchPatients();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Table Header
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFc9d6ec),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: const [
                  Expanded(
                      flex: 1,
                      child: Text('Antrian',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 3,
                      child: Text('Nama',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 2,
                      child: Text('Status',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 2,
                      child: Text('Aksi',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Table Data
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : pagedData.isEmpty
                      ? const Center(
                          child: Text('Tidak ada riwayat pasien ditemukan'))
                      : ListView.separated(
                          itemCount: pagedData.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final patient = pagedData[idx];
                            return Container(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                          '${patient['no_antrian'] ?? '-'}')),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                          '${patient['nama_pasien'] ?? '-'}')),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.purple[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${patient['status'] ?? '-'}',
                                        style: const TextStyle(
                                            color: Colors.purple,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: IconButton(
                                      icon: const Icon(Icons.description,
                                          color: Color(0xFF0099a8)),
                                      onPressed: () {
                                        showDetailDialog(
                                            context,
                                            patient['no_registrasi']
                                                    ?.toString() ??
                                                '');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            // Pagination
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: currentPage > 1
                      ? () {
                          setState(() {
                            currentPage--;
                          });
                        }
                      : null,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        currentPage > 1 ? Colors.grey[300] : Colors.grey[200],
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8))),
                  ),
                  child: const Text('Previous'),
                ),
                ...List.generate(totalPages, (i) {
                  final page = i + 1;
                  return TextButton(
                    onPressed: () {
                      setState(() {
                        currentPage = page;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: currentPage == page
                          ? const Color(0xFF0099a8)
                          : Colors.white,
                      foregroundColor:
                          currentPage == page ? Colors.white : Colors.grey[700],
                    ),
                    child: Text('$page'),
                  );
                }),
                TextButton(
                  onPressed: currentPage < totalPages
                      ? () {
                          setState(() {
                            currentPage++;
                          });
                        }
                      : null,
                  style: TextButton.styleFrom(
                    backgroundColor: currentPage < totalPages
                        ? Colors.grey[300]
                        : Colors.grey[200],
                    foregroundColor: Colors.grey[700],
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8))),
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }
}

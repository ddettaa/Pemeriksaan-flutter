import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../widgets/bottom_nav.dart';
import 'detail_pemeriksaan_page.dart';
import 'histori_screen.dart';

class PemeriksaanScreen extends StatefulWidget {
  const PemeriksaanScreen({Key? key}) : super(key: key);

  @override
  State<PemeriksaanScreen> createState() => _PemeriksaanScreenState();
}

class _PemeriksaanScreenState extends State<PemeriksaanScreen> {
  List<dynamic> dataPemeriksaan = [];
  List<dynamic> filteredData = [];
  bool isLoading = true;

  String? userPoli;
  String searchQuery = '';
  DateTime selectedDate = DateTime.now();

  int currentPage = 1;
  static const int pageSize = 10;

  int get totalPages => (filteredData.length / pageSize).ceil() == 0
      ? 1
      : (filteredData.length / pageSize).ceil();

  List<dynamic> get pagedData {
    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize) > filteredData.length
        ? filteredData.length
        : (start + pageSize);
    return filteredData.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    getUserPoli().then((_) => fetchPemeriksaan());
  }

  Future<void> getUserPoli() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      try {
        final userMap = json.decode(userJson);
        if (userMap['poli'] != null && userMap['poli']['nama_poli'] != null) {
          userPoli = userMap['poli']['nama_poli'];
        } else if (userMap['nama_poli'] != null) {
          userPoli = userMap['nama_poli'];
        }
      } catch (_) {}
    }
  }

  Future<void> fetchPemeriksaan() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse('https://ti054a01.agussbn.my.id/api/pendaftaran'));
      if (response.statusCode == 200) {
        final jsonResult = json.decode(response.body);
        final List<dynamic> data = jsonResult['data'] ?? [];
        setState(() {
          dataPemeriksaan = data;
          filterData();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterData() {
    setState(() {
      filteredData = dataPemeriksaan.where((item) {
        // Filter poli
        final poliMatch = userPoli == null ||
            userPoli!.isEmpty ||
            (item['nama_poli']?.toString().trim().toLowerCase() ?? '') ==
                userPoli!.trim().toLowerCase();
        // Filter tanggal
        final tgl = (item['tgl_kunjungan'] ?? '').toString().substring(0, 10);
        final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
        final dateMatch = tgl == dateStr;
        // Filter search
        final nama = (item['nama_pasien'] ?? '').toString().toLowerCase();
        final rm = (item['rm'] ?? '').toString();
        final searchMatch = searchQuery.isEmpty ||
            nama.contains(searchQuery.toLowerCase()) ||
            rm.contains(searchQuery);
        return poliMatch && dateMatch && searchMatch;
      }).toList();
      currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Halaman Pemeriksaan'),
        backgroundColor: const Color.fromARGB(255, 44, 99, 97),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter bar
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
                              text:
                                  DateFormat('yyyy-MM-dd').format(selectedDate),
                            ),
                            decoration: InputDecoration(
                              prefixIcon:
                                  const Icon(Icons.calendar_today, size: 18),
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
                                filterData();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 200,
                      height: 80,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF688BFF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PEMERIKSAAN HARI INI',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.assignment,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${filteredData.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'DAFTAR PEMERIKSAAN',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1.2), // Antrian
                          1: FlexColumnWidth(3), // Nama Pasien
                          2: FlexColumnWidth(1.5), // Status
                          3: FlexColumnWidth(1.5), // Aksi
                        },
                        border: TableBorder(
                          horizontalInside:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(
                              color: Color(0xFF9AD4E0),
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Antrian',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Nama Pasien',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Status',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Aksi',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          for (var item in pagedData)
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      item['no_antrian']?.toString() ?? '-'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      item['nama_pasien']?.toString() ?? '-'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    item['status']?.toString() ?? '-',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: (item['status']
                                                  ?.toString()
                                                  .toLowerCase() ==
                                              'selesai')
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DetailPemeriksaanPage(
                                            noRegistrasi: item['no_registrasi']
                                                    ?.toString() ??
                                                '',
                                            // Gunakan hanya 'no_rm' untuk noRM
                                            noRM: item['no_rm']?.toString() ?? '',
                                            namaPasien: item['nama_pasien']
                                                    ?.toString() ??
                                                '',
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 68, 255, 202),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                    child: const Text('Periksa'),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Pagination controls
                    if (totalPages > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: currentPage > 1
                                ? () {
                                    setState(() {
                                      currentPage--;
                                    });
                                  }
                                : null,
                          ),
                          Text('Halaman $currentPage dari $totalPages'),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: currentPage < totalPages
                                ? () {
                                    setState(() {
                                      currentPage++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }
}
  }
}

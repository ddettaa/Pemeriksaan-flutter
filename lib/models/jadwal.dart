class Jadwal {
  final String namaDokter;
  final String namaPerawat;
  final String hari;
  final String jamMulai;
  final String jamAkhir;

  Jadwal({
    required this.namaDokter,
    required this.namaPerawat,
    required this.hari,
    required this.jamMulai,
    required this.jamAkhir,
  });

  // Factory constructor untuk membuat instance Jadwal dari JSON
  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      namaDokter: json['nama_dokter']?.toString() ?? 'Tanpa Nama',
      namaPerawat: json['nama_perawat']?.toString() ?? 'Tanpa Nama',
      hari: json['hari']?.toString() ?? 'Tidak Diketahui',
      jamMulai: json['jam_mulai']?.toString() ?? '00:00',
      jamAkhir: json['jam_akhir']?.toString() ?? '00:00',
    );
  }
}

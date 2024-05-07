import 'package:flutter/material.dart'; // Mengimport package flutter/material yang berisi widget-widget dasar dalam Flutter.
import 'package:http/http.dart'
    as http; // Mengimport package http untuk melakukan request HTTP.
import 'dart:convert'; // Mengimport package dart:convert untuk melakukan parsing JSON.
import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimport package flutter_bloc untuk menggunakan Cubit dan BlocProvider.

class University {
  String name; // Variabel untuk menyimpan nama universitas.
  String website; // Variabel untuk menyimpan situs web universitas.

  University(
      {required this.name,
      required this.website}); // Constructor untuk inisialisasi objek University.
}

// Kelas UniversityCubit merupakan subclass dari Cubit<List<University>>, bertanggung jawab untuk mengelola state list universitas.
class UniversityCubit extends Cubit<List<University>> {
  UniversityCubit()
      : super(
            []); // Constructor untuk inisialisasi state awal dengan list kosong.

  // Method untuk melakukan request data universitas berdasarkan negara yang dipilih.
  void fetchUniversities(String country) async {
    String url =
        "http://universities.hipolabs.com/search?country=$country"; // URL API untuk mendapatkan data universitas berdasarkan negara yang dipilih.
    final response = await http.get(
        Uri.parse(url)); // Melakukan HTTP GET request menggunakan package http.

    if (response.statusCode == 200) {
      // Jika response berhasil (status code 200).
      List<dynamic> data = json.decode(
          response.body); // Parsing JSON response menjadi List<dynamic>.
      List<University> universities = [];

      // Iterasi data JSON untuk membuat objek University dan menambahkannya ke dalam list universities.
      for (var item in data) {
        universities.add(
          University(
            name: item['name'], // Mendapatkan nama universitas.
            website: item['web_pages']
                [0], // Mendapatkan situs web pertama universitas.
          ),
        );
      }

      emit(universities); // Memperbarui state dengan list universitas.
    } else {
      throw Exception(
          'Failed to load universities'); // Jika request gagal, lemparkan exception.
    }
  }
}

// Kelas MyApp adalah StatelessWidget yang merupakan root dari aplikasi.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universitas App', // Judul aplikasi.
      home: BlocProvider(
        // Membungkus aplikasi dengan BlocProvider untuk menyediakan UniversityCubit ke dalam widget-tree.
        create: (context) =>
            UniversityCubit(), // Membuat instance dari UniversityCubit.
        child: UniversitiesPage(), // Menampilkan halaman UniversitiesPage.
      ),
    );
  }
}

// Kelas UniversitiesPage adalah StatelessWidget yang menampilkan UI untuk memilih negara ASEAN dan menampilkan daftar universitas.
class UniversitiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Universitas di Negara ASEAN', // Judul AppBar.
          style:
              TextStyle(color: Colors.white), // Gaya teks untuk judul AppBar.
        ),
        backgroundColor:
            Color.fromARGB(255, 2, 128, 201), // Warna latar belakang AppBar.
      ),
      body: Column(
        children: [
          BlocBuilder<UniversityCubit, List<University>>(
            builder: (context, universityList) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Pilih Negara ASEAN', // Label dropdown.
                    border: OutlineInputBorder(), // Gaya border untuk dropdown.
                    filled: true, // Mengisi latar belakang dropdown.
                    fillColor:
                        Colors.grey[200], // Warna latar belakang dropdown.
                  ),
                  items: <String>[
                    // Daftar negara ASEAN.
                    'Indonesia',
                    'Singapura',
                    'Malaysia',
                    'Thailand',
                    'Vietnam',
                    'Filipina',
                    'Myanmar',
                    'Cambodia',
                    'Laos',
                    'Brunei Darussalam'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context.read<UniversityCubit>().fetchUniversities(
                          newValue); // Memanggil method fetchUniversities saat negara diubah.
                    }
                  },
                ),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<UniversityCubit, List<University>>(
              builder: (context, universityList) {
                if (universityList.isEmpty) {
                  // Jika daftar universitas kosong.
                  return Center(
                    child:
                        CircularProgressIndicator(), // Tampilkan indikator loading.
                  );
                } else {
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: universityList.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(), // Widget pembatas antar item ListView.
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            universityList[index].name), // Nama universitas.
                        subtitle: Text(universityList[index]
                            .website), // Situs web universitas.
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MyApp()); // Menjalankan aplikasi.
}

import 'package:flutter/material.dart'; // Mengimport package flutter/material yang berisi widget-widget dasar dalam Flutter.
import 'package:http/http.dart'
    as http; // Mengimport package http untuk melakukan request HTTP.
import 'dart:convert'; // Mengimport package dart:convert untuk melakukan parsing JSON.
import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimport package flutter_bloc untuk menggunakan Bloc dan BlocProvider.

class University {
  String name;
  String website;

  University(
      {required this.name,
      required this.website}); // Constructor untuk inisialisasi objek University.
}

// Abstract class UniversityEvent digunakan sebagai kerangka untuk event yang akan dipicu pada Bloc.
abstract class UniversityEvent {}

// Class FetchUniversities merupakan event yang dipicu untuk meminta data universitas berdasarkan negara tertentu.
class FetchUniversities extends UniversityEvent {
  final String country; // Variabel untuk menyimpan nama negara.

  FetchUniversities(
      this.country); // Constructor untuk inisialisasi event FetchUniversities.
}

// Kelas UniversitiesBloc merupakan subclass dari Bloc<UniversityEvent, List<University>>, bertanggung jawab untuk mengelola state list universitas.
class UniversitiesBloc extends Bloc<UniversityEvent, List<University>> {
  UniversitiesBloc()
      : super(
            []); // Constructor untuk inisialisasi state awal dengan list kosong.

  @override
  Stream<List<University>> mapEventToState(UniversityEvent event) async* {
    if (event is FetchUniversities) {
      yield await fetchUniversities(event
          .country); // Memperbarui state dengan list universitas yang di-fetch.
    }
  }

  // Method untuk melakukan request data universitas berdasarkan negara yang dipilih.
  Future<List<University>> fetchUniversities(String country) async {
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

      return universities; // Mengembalikan list universitas.
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
      title: 'Univ ASEAN', // Judul aplikasi.
      home: BlocProvider(
        // Membungkus aplikasi dengan BlocProvider untuk menyediakan UniversitiesBloc ke dalam widget-tree.
        create: (context) =>
            UniversitiesBloc(), // Membuat instance dari UniversitiesBloc.
        child: UniversitiesPage(), // Menampilkan halaman UniversitiesPage.
      ),
    );
  }
}

// Kelas UniversitiesPage adalah StatelessWidget yang menampilkan UI untuk memilih negara ASEAN dan menampilkan daftar universitas.
class UniversitiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UniversitiesBloc universitiesBloc = BlocProvider.of<UniversitiesBloc>(
        context); // Mendapatkan instance dari UniversitiesBloc dari BlocProvider.

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Universitas di Negara ASEAN', // Judul AppBar.
          style: TextStyle(
              color: Color.fromARGB(
                  255, 53, 53, 53)), // Gaya teks untuk judul AppBar.
        ),
        backgroundColor:
            Color.fromARGB(255, 2, 128, 201), // Warna latar belakang AppBar.
      ),
      body: Column(
        children: [
          BlocBuilder<UniversitiesBloc, List<University>>(
            builder: (context, universityList) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Pilih Universitas', // Label dropdown.
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
                      universitiesBloc.add(FetchUniversities(
                          newValue)); // Memanggil event FetchUniversities dengan negara yang dipilih.
                    }
                  },
                ),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<UniversitiesBloc, List<University>>(
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

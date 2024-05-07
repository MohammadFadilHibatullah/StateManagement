import 'package:flutter/material.dart'; // Import modul flutter material untuk membangun UI.
import 'package:http/http.dart'
    as http; // Import modul http untuk melakukan request HTTP.
import 'dart:convert'; // Import modul json untuk melakukan parsing JSON.
import 'package:provider/provider.dart'; // Import modul provider untuk manajemen state.

// Deklarasi class University untuk merepresentasikan data universitas.
class University {
  String name;
  String website;

  University({required this.name, required this.website});
}

// Kelas UniversityProvider untuk menyediakan data universitas.
class UniversityProvider extends ChangeNotifier {
  late Future<List<University>>
      futureUniversities; // Future untuk menyimpan hasil request universitas.
  late String url; // URL untuk melakukan request data universitas.

  // Konstruktor untuk UniversityProvider.
  UniversityProvider() {
    url =
        "http://universities.hipolabs.com/search?country=Indonesia"; // URL awal untuk data universitas Indonesia.
    futureUniversities =
        fetchUniversities(); // Memanggil fungsi untuk mengambil data universitas.
  }

  // Fungsi untuk melakukan request data universitas.
  Future<List<University>> fetchUniversities() async {
    final response = await http.get(Uri.parse(url)); // Melakukan request HTTP.

    if (response.statusCode == 200) {
      // Jika response berhasil (status code 200).
      List<dynamic> data = json.decode(response.body); // Parsing JSON response.
      List<University> universities =
          []; // List untuk menyimpan data universitas.

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

  // Fungsi untuk mengubah URL berdasarkan negara yang dipilih.
  void changeCountry(String country) {
    url =
        "http://universities.hipolabs.com/search?country=$country"; // Mengubah URL berdasarkan negara.
    futureUniversities =
        fetchUniversities(); // Memanggil fungsi untuk mengambil data universitas.
    notifyListeners(); // Memberitahu listener bahwa data telah berubah.
  }
}

// Kelas utama (widget) aplikasi.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          UniversityProvider(), // Membuat instance dari UniversityProvider dan menyediakannya ke dalam tree.
      child: MaterialApp(
        title: 'Universities App', // Judul aplikasi.
        home: Scaffold(
          appBar: AppBar(
            title: Text('Universities in ASEAN'), // Judul AppBar.
            backgroundColor: Colors.blueAccent, // Warna latar belakang AppBar.
          ),
          body:
              UniversityList(), // Menampilkan widget UniversityList sebagai body.
        ),
      ),
    );
  }
}

// Widget untuk menampilkan daftar universitas.
class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var universityProvider = Provider.of<UniversityProvider>(
        context); // Mendapatkan instance dari UniversityProvider.

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Country', // Label untuk combobox.
              border: OutlineInputBorder(), // Jenis border.
              filled: true, // Mengisi latar belakang.
              fillColor: Colors.grey[200], // Warna latar belakang.
            ),
            items: <String>[
              'Indonesia',
              'Singapore',
              'Malaysia',
              'Thailand',
              'Vietnam',
              'Philippines',
              'Myanmar',
              'Cambodia',
              'Laos',
              'Brunei'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                universityProvider.changeCountry(
                    newValue); // Memanggil fungsi untuk mengubah negara yang dipilih.
              }
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<University>>(
            future: universityProvider
                .futureUniversities, // Menggunakan future dari UniversityProvider.
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Jika sedang dalam proses fetching data.
                return Center(
                  child:
                      CircularProgressIndicator(), // Tampilkan indikator loading.
                );
              } else if (snapshot.hasError) {
                // Jika terjadi error saat fetching data.
                return Center(
                  child: Text('${snapshot.error}'), // Tampilkan pesan error.
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // Jika tidak ada data atau data kosong.
                return Center(
                  child: Text(
                      'No data available'), // Tampilkan pesan bahwa tidak ada data.
                );
              } else {
                // Jika data berhasil diambil.
                return ListView.separated(
                  shrinkWrap:
                      true, // Agar ListView hanya menggunakan ruang yang diperlukan.
                  itemCount:
                      snapshot.data!.length, // Jumlah item dalam ListView.
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(), // Widget pembatas antar item ListView.
                  itemBuilder: (context, index) {
                    // Builder untuk setiap item dalam ListView.
                    return ListTile(
                      title: Text(snapshot
                          .data![index].name), // Judul item: nama universitas.
                      subtitle: Text(snapshot.data![index]
                          .website), // Subtitle item: situs web universitas.
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

// Fungsi main untuk menjalankan aplikasi.
void main() {
  runApp(MyApp());
}

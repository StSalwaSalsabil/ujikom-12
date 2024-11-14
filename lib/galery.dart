import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'gallery_detail.dart';

class GaleryScreen extends StatefulWidget {
  @override
  _GaleryScreenState createState() => _GaleryScreenState();
}

class _GaleryScreenState extends State<GaleryScreen> {
  List<dynamic> _galleryItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGalleryData();
  }

  Future<void> _fetchGalleryData() async {
    try {
      print('Memulai fetch gallery...');
      final response = await http.get(
        Uri.parse('http://10.0.2.2/ujikom-master1/public/api/galery'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body raw: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print('Decoded data: $decodedData');
        
        // Periksa struktur data
        if (decodedData is List) {
          setState(() {
            _galleryItems = decodedData;
            print('Gallery items count: ${_galleryItems.length}');
            _isLoading = false;
          });
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          // Jika response dibungkus dalam objek dengan key 'data'
          setState(() {
            _galleryItems = decodedData['data'];
            print('Gallery items count: ${_galleryItems.length}');
            _isLoading = false;
          });
        } else {
          throw Exception('Format data tidak sesuai');
        }
      } else {
        throw Exception('Failed to load gallery: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error fetching data: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galeri SMKN 4 Bogor'),
        backgroundColor: Color.fromARGB(255, 181, 218, 248),
      ),
      body: Container(
        color: Color.fromARGB(255, 141, 203, 255),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul halaman
            Center(
              child: Column(
                children: [
                  Text(
                    'Galeri',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 26, 51, 94),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Dokumentasi foto dan video kegiatan sekolah',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            _isLoading
                ? Expanded(child: Center(child: CircularProgressIndicator()))
                : _galleryItems.isEmpty
                    ? Expanded(child: Center(child: Text('No items found')))
                    : Expanded(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1, // Menampilkan satu galeri per baris
                            childAspectRatio: 2.5, // Mengubah proporsi grid
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _galleryItems.length,
                          itemBuilder: (context, index) {
                            final item = _galleryItems[index];
                            print('Processing gallery item $index: $item');
                            
                            final title = item['judul_galery']?.toString() ?? 'Tidak ada judul';
                            final description = item['deskripsi_galery']?.toString() ?? 'Tidak ada deskripsi';
                            final galleryId = item['id'];
                            final photos = item['photos'] as List<dynamic>? ?? [];
                            
                            print('Title: $title');
                            print('Deskripsi: $description');
                            print('Gallery ID: $galleryId');
                            print('Photos: $photos');

                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 1, 5, 12),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      description,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 60, 60, 60),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    if (photos.isNotEmpty)
                                      Row(
                                        children: List.generate(
                                          (photos.length > 3 ? 3 : photos.length),
                                          (i) {
                                            final photoData = photos[i] as Map<String, dynamic>?;
                                            final photoUrl = photoData?['isi_photo']?.toString() ?? '';
                                            print('Photo URL $i: $photoUrl');
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: photoUrl.isNotEmpty
                                                    ? Image.network(
                                                        photoUrl,
                                                        width: 80,
                                                        height: 80,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          print('Error loading image: $error');
                                                          return Container(
                                                            width: 80,
                                                            height: 80,
                                                            color: Colors.grey[300],
                                                            child: Icon(Icons.error),
                                                          );
                                                        },
                                                      )
                                                    : Container(
                                                        width: 80,
                                                        height: 80,
                                                        color: Colors.grey[300],
                                                        child: Center(child: Text('No Image')),
                                                      ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    SizedBox(height: 10),
                                    if (galleryId != null)
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => GalleryDetailScreen(
                                                galleryId: galleryId,
                                                title: title,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Lihat foto lainnya',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
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
      ),
    );
  }
}

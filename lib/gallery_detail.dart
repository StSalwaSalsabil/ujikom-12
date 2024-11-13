import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GalleryDetailScreen extends StatefulWidget {
  final int galleryId;
  final String title;

  GalleryDetailScreen({required this.galleryId, required this.title});

  @override
  _GalleryDetailScreenState createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends State<GalleryDetailScreen> {
  List<dynamic> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGalleryPhotos();
  }

  Future<void> _fetchGalleryPhotos() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/ujikom-master1/public/api/galery/${widget.galleryId}/photos')
      );

      if (response.statusCode == 200) {
        setState(() {
          _photos = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load photos');
      }
    } catch (e) {
      print('Error fetching photos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Color.fromARGB(255, 181, 218, 248),
      ),
      body: Container(
        color: Color.fromARGB(255, 141, 203, 255),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _photos.isEmpty
                ? Center(child: Text('Tidak ada foto'))
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      final photo = _photos[index];
                      final photoUrl = photo['isi_photo'] ?? '';
                      
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: photoUrl.isNotEmpty
                              ? Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: Center(child: Text('No Image')),
                                ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
} 
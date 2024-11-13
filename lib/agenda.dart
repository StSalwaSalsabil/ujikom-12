import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgendaScreen extends StatefulWidget {
  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late Future<List<Agenda>> _agendaList;

  @override
  void initState() {
    super.initState();
    _agendaList = fetchAgenda();
  }

  Future<List<Agenda>> fetchAgenda() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2/ujikom-master1/public/api/agenda'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Agenda.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load agenda: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load agenda: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        backgroundColor: const Color.fromARGB(255, 5, 205, 255),
      ),
      body: FutureBuilder<List<Agenda>>(
        future: _agendaList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Data Found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final agenda = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: const Color.fromARGB(255, 180, 215, 235),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    agenda.judulAgenda,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color.fromARGB(255, 1, 68, 112),
                    ),
                  ),
                  subtitle: Text(
                    agenda.isiAgenda,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  trailing: Text(
                    agenda.tglAgenda,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Agenda {
  final String judulAgenda;
  final String isiAgenda;
  final String tglAgenda;

  const Agenda({
    required this.judulAgenda,
    required this.isiAgenda,
    required this.tglAgenda,
  });

  factory Agenda.fromJson(Map<String, dynamic> json) {
    return Agenda(
      judulAgenda: json['judul_agenda'] ?? '',
      isiAgenda: json['isi_agenda'] ?? '',
      tglAgenda: json['tgl_agenda'] ?? '',
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ImageData>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _imagesFuture = fetchImages();
  }

  Future<List<ImageData>> fetchImages() async {
    final url = Uri.parse("https://picsum.photos/v2/list?limit=10");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ImageData.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                context.read<AuthBloc>().add(LogoutRequested());
              } catch (_) {
                await FirebaseAuth.instance.signOut();
              }
            },
          )
        ],
      ),
      body: FutureBuilder<List<ImageData>>(
        future: _imagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final images = snapshot.data ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final img = images[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    img.downloadUrl,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fitWidth,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image by ${img.author}',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'ID: ${img.id}',
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class ImageData {
  final String id;
  final String author;
  final String downloadUrl;

  ImageData({
    required this.id,
    required this.author,
    required this.downloadUrl,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      id: json['id'],
      author: json['author'],
      downloadUrl: json['download_url'],
    );
  }
}

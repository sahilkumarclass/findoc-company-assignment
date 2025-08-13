import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../repository/image_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ImageRepository();
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: repo.fetchImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading images"));
          }
          final images = snapshot.data ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final img = images[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(img['url'], fit: BoxFit.fitWidth),
                  const SizedBox(height: 8),
                  Text(
                    img['title'],
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    img['description'],
                    style: const TextStyle(color: Colors.grey),
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

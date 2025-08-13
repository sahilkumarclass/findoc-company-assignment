import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageRepository {
  Future<List<Map<String, dynamic>>> fetchImages() async {
    final url = Uri.parse("https://picsum.photos/v2/list?limit=10");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List data = List.from(jsonDecode(response.body));
      return data.map((item) => {
        "title": "Image by ${item['author']}",
        "description": "ID: ${item['id']}",
        "url": item['download_url'],
      }).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }
}

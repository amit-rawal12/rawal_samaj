import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EBook extends StatelessWidget {
  const EBook({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> books = [
      {
        "title": "भगवद गीता",
        "filePath": "assets/bhagavad_gita.pdf",
        "cover": "assets/bhagavad_gita_cover.jpg"
      },
      {
        "title": "रामायण",
        "filePath": "assets/ramayan.pdf",
        "cover": "assets/ramayan_cover.jpg"
      },
      {
        "title": "महाभारत",
        "filePath": "assets/mahabharat.pdf",
        "cover": "assets/mahabharat_cover.jpg"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Dharmik (पुस्तकालय)",style: GoogleFonts.breeSerif(color: Colors.white),),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return BookCard(
              title: books[index]["title"]!,
              filePath: books[index]["filePath"]!,
              coverImage: books[index]["cover"]!,
            );
          },
        ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final String title;
  final String filePath;
  final String coverImage;

  const BookCard({
    super.key,
    required this.title,
    required this.filePath,
    required this.coverImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // PDF रीडर खोलने की functionality यहाँ ऐड करेंगे
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(coverImage, fit: BoxFit.cover),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

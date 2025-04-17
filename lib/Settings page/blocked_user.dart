import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BlockedUser extends StatefulWidget {
  const BlockedUser({super.key});

  @override
  State<BlockedUser> createState() => _BlockedUserState();
}

class _BlockedUserState extends State<BlockedUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Blocked Users',
          style: GoogleFonts.breeSerif(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/coming_soon.png', // अपने assets में एक अच्छा सा "Coming Soon" PNG डालें
              height: 180,
            ),
            const SizedBox(height: 20),
            Text(
              'Coming Soon...',
              style: GoogleFonts.breeSerif(
                fontSize: 22,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This feature is under development.',
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

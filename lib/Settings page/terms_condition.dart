import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfUse extends StatefulWidget {
  const TermsOfUse({super.key});

  @override
  State<TermsOfUse> createState() => _TermsOfUseState();
}

class _TermsOfUseState extends State<TermsOfUse> {
  bool _isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        elevation: 1,
        centerTitle: true,
        title: Text("Terms & Conditions", style: GoogleFonts.breeSerif(color: Colors.white, fontSize: 20)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''
Welcome to our App!

By using this application, you agree to the following terms and conditions:

1. **User Data**: Your data will be securely stored and will not be shared with third parties.
2. **Content Usage**: Any unauthorized reproduction or distribution of the app content is prohibited.
3. **App Usage**: Do not use this app for any illegal activities.
4. **Updates**: We may change these terms at any time with or without notice.

By using our services, you acknowledge that you have read, understood, and agree to be bound by these terms.
                  ''',
                  style: GoogleFonts.poppins(fontSize: 15, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _isAgreed,
                  onChanged: (value) {
                    setState(() {
                      _isAgreed = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    "I have read and agree to the Terms & Conditions",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isAgreed
                  ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("You have accepted the terms."),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                "I Agree",
                style: GoogleFonts.breeSerif(
                    fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

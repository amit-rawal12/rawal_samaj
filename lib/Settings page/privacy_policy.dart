import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        elevation: 1,
        centerTitle: true,
        title: Text("Privacy Policy", style: GoogleFonts.breeSerif(color: Colors.white, fontSize: 20)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
We value your privacy.

This Privacy Policy explains how we collect, use, and protect your personal data:

1. **Data Collection**: We may collect personal information such as name, email, and usage data.
2. **Data Usage**: Your data is used to improve user experience, personalize content, and offer support.
3. **Data Sharing**: We do not share your personal data with third parties without your consent.
4. **Security**: We implement strong security measures to protect your information.
5. **User Rights**: You may request to update or delete your personal information at any time.
6. **Cookies**: We may use cookies for a better user experience.
7. **Policy Updates**: We may update this privacy policy from time to time.

For questions, contact us at: support@example.com

By using this app, you agree to this privacy policy.
            ''',
            style: GoogleFonts.openSans(fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}

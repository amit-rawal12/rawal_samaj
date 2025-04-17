import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rawal_samaj/Settings%20page/privacy_policy.dart';
import 'package:rawal_samaj/Settings%20page/terms_condition.dart';
import '../accounts/login_screen.dart';
import '../accounts/register_screen.dart';
import 'blocked_user.dart';
import 'change_pass.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Account", style: GoogleFonts.breeSerif(fontWeight: FontWeight.bold)),
        content: Text("are you sure you want to delete this account", style: GoogleFonts.breeSerif()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser?.delete();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) =>  RegisterScreen()),
                      (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error deleting account: $e")),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text("Delete", style: GoogleFonts.breeSerif(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        elevation: 1,
        centerTitle: true,
        title: Text("Settings", style: GoogleFonts.breeSerif(color: Colors.white, fontSize: 20)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle("Account"),
          _settingsTile("Change Password", Icons.lock, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePass()));
          }),
          _settingsTile("Blocked users", Icons.block, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => BlockedUser()));
          }),
          Divider(thickness: 1, indent: 12, endIndent: 12, color: Colors.grey.shade300),
          _sectionTitle("Legal"),
          _settingsTile("Terms of use", Icons.description_outlined, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => TermsOfUse()));
          }),
          _settingsTile("Privacy policy", Icons.privacy_tip_outlined, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => PrivacyPolicy()));
          }),
          Divider(thickness: 1, indent: 12, endIndent: 12, color: Colors.grey.shade300),
          SizedBox(height: 30),

          Center(
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                padding: EdgeInsets.symmetric(horizontal: media.width * 0.36, vertical: 10),
              ),
              child: Text("LogOut", style: GoogleFonts.breeSerif(color: Colors.black, fontSize: 17)),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () => _showDeleteDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                  side: BorderSide(color: Colors.orange),
                ),
                padding: EdgeInsets.symmetric(horizontal: media.width * 0.28, vertical: 10),
              ),
              child: Text("Delete account", style: GoogleFonts.breeSerif(color: Colors.orange, fontSize: 17)),
            ),
          ),
          SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, top: 20, bottom: 10),
      child: Text(title,
          style: GoogleFonts.breeSerif(color: Colors.grey.shade700, fontSize: 20, fontWeight: FontWeight.w600)),
    );
  }

  Widget _settingsTile(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: GoogleFonts.breeSerif(fontSize: 17)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:qr_flutter/qr_flutter.dart';

import '../Help Center/help_screen.dart';
import '../Settings page/setting_page.dart';
import 'profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Widget buildUserDetails(Map<String, dynamic> userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDetailRow("Name", userData["name"]),
        buildDetailRow("Number", userData["phone"]),
        buildDetailRow("Birth Date", userData["dob"]),
        buildDetailRow("Address", userData["address"]),
        buildDetailRow("Gender", userData["gender"]),
        // और फील्ड्स जोड़ सकते हो जैसे "कास्ट", "Aadhaar", etc.
      ],
    );
  }

  Widget buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle textStyle() {
    return TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white);
  }

  Widget buildAdmitCard(Map<String, dynamic> userData) {
    Size media = MediaQuery.of(context).size;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.transparent, width: 2),
      ),
      child: Container(
        width: media.width * 1.1,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.orange.shade500, Colors.redAccent.shade200]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          height: media.height*0.3, // Set a proper height for PageView to avoid layout issues
          child: PageView(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 21, backgroundImage: AssetImage("assets/om.png")),
                        SizedBox(width: media.width * 0.10),
                        Expanded(
                          child: Text(
                            "🛕रावल समाज समिति",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        CircleAvatar(radius: 21, backgroundImage: AssetImage("assets/hindu.png")),
                      ],
                    ),
                    SizedBox(height: 3),
                    Divider(color: Colors.white70, thickness: 1.2),
                    SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildAdmitPhoto(userData["photoUrl"]),
                        SizedBox(width: 12),
                        Expanded(child: buildUserDetails(userData)),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      "👉 Swipe करें QR Code देखने के लिए",
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),

              // 👉 Page 2 - QR Code
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "🛕 आपका यूनिक QR Code",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(8),
                      child: QrImageView(
                        data: userData["uniqueCode"] ?? "No Code",
                        version: QrVersions.auto,
                        size: 130,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "⬅️ Swipe करें Details देखने के लिए",
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildAdmitPhoto(String? photoUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 90,
        height: 90,
        color: Colors.white,
        child: photoUrl != null
            ? Image.network(photoUrl, fit: BoxFit.cover)
            : Image.asset("assets/default_profile.png", fit: BoxFit.cover),
      ),
    );
  }

  Widget buildQrCode(String data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(5),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: 50,
        gapless: false,
        errorStateBuilder: (ctx, err) => Text("QR Error"),
      ),
    );
  }


  Future<void> fetchUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("users").child(userId);
    ref.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          userData = Map<String, dynamic>.from(data);
          isLoading = false;
        });
      } else {
        setState(() {
          userData = null;
          isLoading = false;
        });
      }
    });
  }

  Widget customListTile({
    required IconData icon,
    required String title,
    required List<Color> gradientColors,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 15,
        backgroundColor: gradientColors.first.withOpacity(0.2),
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(colors: gradientColors).createShader(bounds),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.breeSerif(color: Colors.black, fontSize: 16),
      ),
      trailing: Icon(Icons.arrow_forward_ios_outlined, size: 17, color: iconColor),
    );
  }

  Widget buildHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.23,
      decoration: BoxDecoration(
        color: Colors.orange.shade400,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Jay shree ram 🚩",
                  style: GoogleFonts.breeSerif(fontSize: 18, color: Colors.black87)),
              SizedBox(height: 5),
              Text(
                userData?["name"] ?? "User",
                style: GoogleFonts.breeSerif(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: SizedBox(
                width: 94,
                height: 94,
                child: Image.network(
                  userData?["photoUrl"] ?? "https://via.placeholder.com/150",
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) =>
                  loadingProgress == null ? child : Center(child: CircularProgressIndicator()),
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOptionsList() {
    return Column(
      children: [
        customListTile(
          icon: Icons.account_circle,
          title: "Profile",
          gradientColors: [Colors.orange, Colors.deepOrange],
          iconColor: Colors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Profile()),
          ),
        ),
        customListTile(
          icon: Icons.settings,
          title: "Settings",
          gradientColors: [Colors.deepOrangeAccent, Colors.orange],
          iconColor: Colors.deepOrangeAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingPage()),
          ),
        ),
        customListTile(
          icon: Icons.help_outline,
          title: "Help Center",
          gradientColors: [Colors.redAccent, Colors.deepOrange],
          iconColor: Colors.redAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HelpScreen()),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData == null
          ? Center(child: Text("❌ डेटा नहीं मिला", style: TextStyle(fontSize: 18)))
          : SingleChildScrollView(
        child: Column(
          children: [
            buildHeader(),
            SizedBox(height: 12),
            buildOptionsList(),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 12),
            buildAdmitCard(userData!),
          ],
        ),
      ),
    );
  }

}

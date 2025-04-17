import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberList extends StatefulWidget {
  @override
  _MemberListState createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref("users");

  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> filteredMembers = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMembers();
    searchController.addListener(_onSearchChanged);
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('❌ कॉल नहीं हो सका');
    }
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredMembers =
          members.where((member) {
            return member["name"].toLowerCase().contains(query) ||
                member["address"].toLowerCase().contains(query) ||
                member["phone"].toLowerCase().contains(query);
          }).toList();
    });
  }

  void _fetchMembers() {
    _database.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        List<Map<String, dynamic>> tempList = [];

        data.forEach((key, value) {
          tempList.add({
            "name": value["name"] ?? "नाम नहीं मिला",
            "address": value["address"] ?? "पता नहीं मिला",
            "phone": value["phone"] ?? "N/A",
            "photo": value["photoUrl"] ?? "",
          });
        });

        setState(() {
          members = tempList;
          filteredMembers = tempList;
        });
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Members",
          style: GoogleFonts.breeSerif(color: Colors.white),
        ),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // सिर्फ ये हिस्सा scroll होगा
          Expanded(
            child:
                filteredMembers.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          color: Colors.orange.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      (member["photo"] != null &&
                                              member["photo"]
                                                  .toString()
                                                  .isNotEmpty)
                                          ? NetworkImage(member["photo"])
                                          : AssetImage(
                                                "assets/default_user.png",
                                              )
                                              as ImageProvider,
                                  backgroundColor: Colors.orange.shade600,
                                ),
                                SizedBox(width: media.width * 0.03),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member["name"],
                                        style: GoogleFonts.breeSerif(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: media.height * 0.01),
                                      Text(
                                        "📍 Add: ${member["address"]}",
                                        style: GoogleFonts.breeSerif(
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: media.height * 0.01),
                                      Text(
                                        "📞 Call: ${member["phone"]}",
                                        style: GoogleFonts.breeSerif(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.phone, color: Colors.green),
                                  onPressed: () {
                                    _makePhoneCall(member["phone"]);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

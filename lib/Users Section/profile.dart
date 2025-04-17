import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference userRef =
    FirebaseDatabase.instance.ref().child("users").child(userId);

    userRef.onValue.listen((event) {
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

  Future<void> pickProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      String uid = FirebaseAuth.instance.currentUser!.uid;
      String fileName = "profile_images/$uid.jpg";

      try {
        Reference storageRef =
        FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = storageRef.putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        updateUserData("photoUrl", downloadUrl);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  void updateUserData(String key, String value) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference userRef =
    FirebaseDatabase.instance.ref().child("users").child(userId);
    userRef.update({key: value});
  }

  void showEditDialog(String label, String key) {
    TextEditingController controller =
    TextEditingController(text: userData?[key] ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update", style: GoogleFonts.breeSerif()),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "नया $label दर्ज करें",
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () {
                setState(() {
                  userData?[key] = controller.text;
                });
                updateUserData(key, controller.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildEditableField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: TextFormField(
        readOnly: true,
        initialValue: userData?[key] ?? "N/A",
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.blueGrey),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueGrey.shade200, width: 1),
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.edit, color: Colors.blueAccent),
            onPressed: () => showEditDialog(label, key),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        title: Text(
          "Profile",
          style: GoogleFonts.breeSerif(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 👤 Profile Picture Section
            GestureDetector(
              onTap: pickProfilePhoto,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: userData?['photoUrl'] != null
                        ? NetworkImage(userData!['photoUrl'])
                        : AssetImage("assets/default_user.png")
                    as ImageProvider,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Icon(Icons.edit, color: Colors.orange.shade700),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Text(
              userData?['name'] ?? "नाम",
              style: GoogleFonts.breeSerif(fontSize: 20),
            ),
            const SizedBox(height: 20),

            // 📝 Editable Fields
            buildEditableField("👤 Name", "name"),
            buildEditableField("📧 Email ID", "email"),
            buildEditableField("📞 Number", "phone"),
            buildEditableField("🏠 Address", "address"),
            buildEditableField("🚻 Gender", "gender"),
            buildEditableField("🆔 Aadhaar", "aadhaar"),
            buildEditableField("🎂 Birth", "dob"),
          ],
        ),
      ),
    );
  }

}

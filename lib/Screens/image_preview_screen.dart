import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PhotoPreviewScreen extends StatefulWidget {
  final File imageFile;

  const PhotoPreviewScreen({super.key, required this.imageFile});

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref("group_chat");
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _captionController = TextEditingController();
  bool _isSending = false;

  Future<void> _uploadAndSend() async {
    if (user == null) return;

    setState(() => _isSending = true);

    try {
      // 🔼 Upload image to Firebase Storage
      final fileName = path.basename(widget.imageFile.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("group_chat_media/$fileName");
      await storageRef.putFile(widget.imageFile);
      final imageUrl = await storageRef.getDownloadURL();

      // 🔽 Send message with image URL & caption
      await _sendMessage(imageUrl: imageUrl, caption: _captionController.text);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _sendMessage({
    required String imageUrl,
    required String caption,
  }) async {
    try {
      final userInfoSnapshot = await FirebaseDatabase.instance
          .ref("users/${user!.uid}")
          .once();

      final userData = userInfoSnapshot.snapshot.value as Map?;
      final senderName = userData?['name'] ?? 'Unknown User';

      final newMessage = {
        'imageUrl': imageUrl,
        'caption': caption,
        'senderId': user!.uid,
        'senderName': senderName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await _chatRef.push().set(newMessage);
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 📸 Full Screen Image with zoom
          Positioned.fill(
            child: InteractiveViewer(
              child: Align(
                alignment: Alignment.centerRight,
                child: Image.file(
                  widget.imageFile,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // 🔼 Top Action Bar
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BackButton(color: Colors.white),
                Row(
                  children: const [
                    Icon(Icons.crop_rotate, color: Colors.white),
                    SizedBox(width: 15),
                    Icon(Icons.emoji_emotions_outlined, color: Colors.white),
                    SizedBox(width: 15),
                    Icon(Icons.title, color: Colors.white),
                    SizedBox(width: 15),
                    Icon(Icons.edit, color: Colors.white),
                  ],
                )
              ],
            ),
          ),

          // 🔽 Bottom Caption Input & Send
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.black54,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Add a caption...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  _isSending
                      ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                      : IconButton(
                    onPressed: _uploadAndSend,
                    icon: const Icon(Icons.send, color: Colors.greenAccent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

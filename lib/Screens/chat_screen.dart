import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import 'image_preview_screen.dart';
import 'image_view_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref("group_chat");
  final User? user = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();
  String? replyImageUrl;



  // -------------------- Send Message --------------------
  void _sendMessage({String? imageUrl, String? videoUrl, String? audioUrl}) async {
    if (_messageController.text.trim().isEmpty && imageUrl == null && videoUrl == null && audioUrl == null) return;

    final userInfo = await FirebaseDatabase.instance.ref("users/${user!.uid}").once();
    final senderData = userInfo.snapshot.value as Map<dynamic, dynamic>?;

    final message = {
      "message": _messageController.text.trim(),
      "senderId": user!.uid,
      "senderName": senderData?["name"] ?? "User",
      "senderPhoto": senderData?["photoUrl"] ?? "",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "imageUrl": imageUrl ?? "",
      "videoUrl": videoUrl ?? "",
      "audioUrl": audioUrl ?? "",
    };

    await _chatRef.push().set(message);
    _messageController.clear();
  }

  // -------------------- Media Picker Bottom Sheet --------------------
  void _pickCameraOrGalleryOption() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        height: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Choose media", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickCameraMedia();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickGalleryMedia();
              },
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- Pick Image from Camera --------------------
  Future<void> _pickCameraMedia() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final file = File(picked.path);
      final fileName = path.basename(picked.path);
      final ref = FirebaseStorage.instance.ref().child("group_chat_media/$fileName");
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      _sendMessage(imageUrl: url);
    }
  }

  // -------------------- Pick Image from Gallery --------------------
  Future<void> _pickGalleryMedia() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoPreviewScreen(imageFile: File(picked.path)),
        ),
      );
    }
  }

  // -------------------- Edit/Delete Message --------------------
  void _showEditDeleteDialog(String messageKey, Map msg) {
    final editController = TextEditingController(text: msg["message"]);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit/Delete"),
        content: TextField(controller: editController),
        actions: [
          TextButton(
            child: Text("Edit"),
            onPressed: () async {
              await _chatRef.child(messageKey).update({"message": editController.text.trim()});
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await _chatRef.child(messageKey).remove();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // -------------------- Build Single Message --------------------
  Widget _buildMessage(String key, Map msg, bool isMe) {
    return GestureDetector(
      onLongPress: isMe ? () => _showEditDeleteDialog(key, msg) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe && (msg["senderPhoto"] ?? "").isNotEmpty)
                ...[
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: CachedNetworkImageProvider(msg["senderPhoto"]),
                  ),
                  SizedBox(width: 8),
                ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.orange.shade100 : Colors.orange.shade300,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: isMe ? Radius.circular(12) : Radius.zero,
                          bottomRight: isMe ? Radius.zero : Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (!isMe && (msg["senderName"] ?? "").isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                msg["senderName"],
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),

                          if ((msg["message"] ?? "").isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(msg["message"], style: TextStyle(fontSize: 14)),
                            ),

                          if ((msg["imageUrl"] ?? "").isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ImageViewerPage(
                                          imageUrl: msg["imageUrl"],
                                          caption: msg["caption"],
                                        ),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: msg["imageUrl"],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error, color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ),

                                if ((msg["caption"] ?? "").toString().trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
                                    child: Text(
                                      msg["caption"],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                          if ((msg["videoUrl"] ?? "").isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                "[🎥 वीडियो] ${msg["videoUrl"]}",
                                style: TextStyle(color: Colors.blueAccent, fontStyle: FontStyle.italic),
                              ),
                            ),

                          if ((msg["audioUrl"] ?? "").isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                "[🔊 ऑडियो] ${msg["audioUrl"]}",
                                style: TextStyle(color: Colors.deepPurple, fontStyle: FontStyle.italic),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('hh:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(msg["timestamp"]),
                        ),
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              if (isMe) SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- Build Input Bar --------------------
  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(hintText: "Message", border: InputBorder.none),
            ),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.grey),
            onPressed: _pickCameraOrGalleryOption,
          ),
          CircleAvatar(
            backgroundColor:Colors.orange.shade700,
            radius: 22,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }


  // -------------------- Build Main Chat UI --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Hindu Group Chat", style: GoogleFonts.breeSerif(color: Colors.white)),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _chatRef.orderByChild("timestamp").onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  Map data = snapshot.data!.snapshot.value as Map;
                  List<MapEntry> entries = data.entries.toList();
                  entries.sort((a, b) => a.value["timestamp"].compareTo(b.value["timestamp"]));

                  // ✅ Auto-scroll to bottom
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final key = entries[index].key;
                      final msg = Map<String, dynamic>.from(entries[index].value);
                      final isMe = msg["senderId"] == user?.uid;
                      return _buildMessage(key, msg, isMe);
                    },
                  );
                } else {
                  return Center(child: Text("No messages yet."));
                }
              },
            ),
          ),

          _buildInputBar(),
        ],
      ),

    );
  }
}

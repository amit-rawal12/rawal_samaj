import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedFile;
  String? _mediaType; // 'image' or 'video'
  bool _isLoading = false;
  VideoPlayerController? _videoController;

  /// Media Picker for image/video
  Future<void> _pickMedia(bool isImage) async {
    if (isImage) {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        _selectedFile = File(picked.path);
        _mediaType = 'image';
        _videoController?.dispose();
      }
    } else {
      final pickedVideo = await _picker.pickVideo(source: ImageSource.gallery);
      if (pickedVideo != null) {
        _selectedFile = File(pickedVideo.path);
        _mediaType = 'video';

        _videoController?.dispose();
        _videoController = VideoPlayerController.file(_selectedFile!)
          ..initialize().then((_) {
            setState(() {});
            _videoController!.setLooping(true);
            _videoController!.play();
          });
      }
    }

    setState(() {});
  }

  /// Upload Post to Firebase Storage & Realtime Database
  Future<void> _uploadPost() async {
    if (_selectedFile == null || _captionController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final postId = const Uuid().v4();
      final ext = _mediaType == 'video' ? 'mp4' : 'jpg';

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('posts/$postId.$ext');
      await storageRef.putFile(_selectedFile!);
      final mediaUrl = await storageRef.getDownloadURL();

      // Save post data to Realtime Database
      final postRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user!.uid)
          .child('posts')
          .child(postId);

      await postRef.set({
        'postId': postId,
        'caption': _captionController.text.trim(),
        'mediaUrl': mediaUrl,
        'mediaType': _mediaType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'userName': user.displayName ?? 'Anonymous',
        'userPhoto': user.photoURL ?? '',
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Post uploaded successfully!")),
      );

      // Clear inputs
      _captionController.clear();
      _videoController?.dispose();

      setState(() {
        _selectedFile = null;
        _mediaType = null;
        _videoController = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  /// Media Preview Widget
  Widget _buildMediaPreview() {
    if (_mediaType == 'image' && _selectedFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.file(_selectedFile!, height: 200, fit: BoxFit.cover),
      );
    } else if (_mediaType == 'video' && _videoController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      );
    } else {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey),
        ),
        child: const Center(
          child: Text("No media selected"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        title: Text(
          "Upload Post",
          style: GoogleFonts.breeSerif(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildMediaPreview(),
                  const SizedBox(height: 12),

                  // Buttons to pick media
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickMedia(true),
                        icon: const Icon(Icons.image),
                        label: const Text("Pick Image"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickMedia(false),
                        icon: const Icon(Icons.video_library),
                        label: const Text("Pick Video"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Caption Input
                  TextField(
                    controller: _captionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Write a caption...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Upload Button
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _uploadPost,
                      icon: const Icon(Icons.cloud_upload,color: Colors.white,),
                      label:Text(
                        "Upload Post",
                        style: GoogleFonts.breeSerif(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

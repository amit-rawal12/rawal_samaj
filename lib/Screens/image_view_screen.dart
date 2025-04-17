import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageViewerPage extends StatelessWidget {
  final String imageUrl;
  final String? caption;

  const ImageViewerPage({super.key, required this.imageUrl, this.caption});

  void _replyToImage(BuildContext context) {
    Navigator.pop(context, "reply_image");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Image view
          Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain, // यह जरूरी है!
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),


          // AppBar with blur & opacity
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  height: kToolbarHeight + MediaQuery.of(context).padding.top,
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  color: Colors.black.withOpacity(0.1), // semi-transparent black
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackButton(color: Colors.white),
                      Text("Image View", style: TextStyle(color: Colors.white, fontSize: 18)),
                      IconButton(
                        icon: Icon(Icons.reply, color: Colors.white),
                        onPressed: () => _replyToImage(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Caption at bottom
          if (caption != null && caption!.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black87,
                padding: EdgeInsets.all(12),
                child: Text(
                  caption!,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

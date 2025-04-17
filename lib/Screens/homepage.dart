import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/HomeFeedProvider.dart';

import 'chat_screen.dart';
import 'notification_screen.dart';

class HomeFeed extends StatelessWidget {

  // 🔶 Post Card Widget
  Widget _buildPostCard(BuildContext context, HomeFeedProvider provider, Map<String, dynamic> post) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(context, provider, post),

          // ✅ Fixed height media section (Instagram-style)
          Container(
            height: 300, // Fix card size for every post
            width: double.infinity,
            color: Colors.grey[200],
            child: (post["mediaUrl"] ?? "").isNotEmpty
                ? _buildPostMedia(post)
                : Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 60)),
          ),

          if ((post["caption"] ?? "").isNotEmpty)
            _buildPostCaption(post["caption"]),

          _buildPostActions(context, provider, post),
        ],
      ),
    );
  }

  // 👤 Header with user info and delete button (if owner)
  Widget _buildPostHeader(BuildContext context, HomeFeedProvider provider, Map<String, dynamic> post) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: post["userPhoto"] != null && post["userPhoto"].isNotEmpty
            ? NetworkImage(post["userPhoto"])
            : AssetImage("assets/default_user.png") as ImageProvider,
      ),
      title: Text(post["userName"], style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        DateFormat("dd MMM yyyy, hh:mm a").format(
          DateTime.fromMillisecondsSinceEpoch(post["timestamp"]),
        ),
      ),
      trailing: currentUserId == post["userId"]
          ? IconButton(
        icon: Icon(Icons.more_vert_sharp, color: Colors.red),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Delete Post"),
              content: Text("Are you sure you want to delete this post?"),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    provider.deletePost(post["userId"], post["postId"]);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      )
          : null,
    );
  }

  // 🖼 Media section
  Widget _buildPostMedia(Map<String, dynamic> post) {
    final mediaUrl = post["mediaUrl"];

    if (post["isVideo"] == true) {
      return Container(
        height: 300, // Match height with card
        width: double.infinity,
        color: Colors.black12,
        child: Center(
          child: Icon(Icons.videocam, size: 60, color: Colors.grey),
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: mediaUrl,
        height: 300, // Match height with card
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) {
          debugPrint("❌ Error loading image: $error");
          return Center(
            child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
          );
        },
      );
    }
  }

  // 📝 Caption
  Widget _buildPostCaption(String caption) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Text(caption, style: TextStyle(fontSize: 16)),
    );
  }

  // ❤️💬🔗 Post Actions (Like, Comment, Share)
  Widget _buildPostActions(BuildContext context, HomeFeedProvider provider, Map<String, dynamic> post) {
    bool isLiked = post["isLiked"] ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(
            Icons.favorite,
            color: isLiked ? Colors.red : Colors.white,
          ),
          onPressed: () {
            provider.toggleLike(post["userId"], post["postId"]);
          },
        ),
        Text("${post["likes"]} Likes"),
        IconButton(
          icon: Icon(Icons.comment, color: Colors.green),
          onPressed: () => _showCommentsBottomSheet(context, provider, post),
        ),
        Text("${post["comments"].length} Comments"),
        IconButton(
          icon: Icon(Icons.share, color: Colors.purple),
          onPressed: () {
            final postId = post["postId"];  // Fetch the post ID
            final postCaption = post["caption"];
            final mediaUrl = post["mediaUrl"];

            final link = "https://yourapp.com/homefeed?id=$postId";  // Custom link for deep linking
            Share.share("📢 $postCaption\n🔗 $link\nMedia: $mediaUrl");
          },
        )

      ],
    );
  }


  // 💬 Comments Modal Bottom Sheet
  void _showCommentsBottomSheet(BuildContext context, HomeFeedProvider provider, Map<String, dynamic> post) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    TextEditingController _commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Text("Comments (${post["comments"].length})", style: TextStyle(fontWeight: FontWeight.bold)),
              Divider(),
              Container(
                height: 300,
                child: ListView(
                  children: post["comments"].map<Widget>((comment) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: comment["userPhoto"] != null && comment["userPhoto"].isNotEmpty
                            ? NetworkImage(comment["userPhoto"])
                            : AssetImage("assets/default_user.png") as ImageProvider,
                      ),
                      title: Text(comment["userName"] ?? "Unknown User", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment["comment"]),
                          SizedBox(height: 4),
                          Text(
                            _formatTime(comment["timestamp"]),
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: currentUserId == comment["userId"]
                          ? IconButton(
                        icon: Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Delete Comment"),
                              content: Text("Are you sure you want to delete this comment?"),
                              actions: [
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    provider.deleteComment(post["userId"], post["postId"], comment["commentKey"]);
                                    Navigator.pop(context); // close dialog
                                    Navigator.pop(context); // close bottom sheet
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      )
                          : null,
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(hintText: "Write a comment..."),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.blue),
                      onPressed: () {
                        provider.addComment(post["userId"], post["postId"], _commentController.text);
                        _commentController.clear();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🕒 Timestamp Formatter
  String _formatTime(int timestamp) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeFeedProvider(),
      child: Consumer<HomeFeedProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Rawal Samaj Feed",
                style: GoogleFonts.breeSerif(color: Colors.white),
              ),
              backgroundColor: Colors.orange.shade700,
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationScreen(),));
                    print("Notification icon tapped");
                  },
                ),
                SizedBox(width: 7,),
                IconButton(
                  icon: Icon(Icons.message, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(),));
                    // 🔔 नोटिफिकेशन पेज पर नेविगेट करें या एक्शन
                    print("Message icon tapped");
                  },
                ),
                SizedBox(width: 7,),
              ],
            ),

            body: provider.isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: provider.posts.length,
              itemBuilder: (context, index) {
                final post = provider.posts[index];
                return _buildPostCard(context, provider, post);
              },
            ),
          );
        },
      ),
    );
  }


}

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomeFeedProvider extends ChangeNotifier {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref("users");

  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;

  StreamSubscription<DatabaseEvent>? _postsSubscription;

  HomeFeedProvider() {
    fetchPosts();
  }

  void fetchPosts() {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      _postsSubscription = _usersRef.onValue.listen((event) {
        final usersData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (usersData != null) {
          List<Map<String, dynamic>> tempList = [];

          usersData.forEach((userId, userData) {
            if (userData.containsKey("posts")) {
              Map<dynamic, dynamic> userPosts = userData["posts"];

              userPosts.forEach((postId, postData) {
                String mediaUrl = postData["mediaUrl"] ?? "";
                debugPrint("📸 Media URL for postId $postId: $mediaUrl");

                List<Map<String, dynamic>> commentList = [];

                if (postData["comments"] != null) {
                  (postData["comments"] as Map<dynamic, dynamic>).forEach((commentKey, c) {
                    commentList.add({
                      "commentKey": commentKey,
                      "comment": c["comment"] ?? "",
                      "userId": c["userId"] ?? "",
                      "userName": c["userName"] ?? "Unknown",
                      "userPhoto": c["userPhoto"] ?? "",
                      "timestamp": c["timestamp"] ?? 0,
                    });
                  });
                }

                // ✅ isLiked और likedBy यहीं पर होना चाहिए
                Map likedBy = postData["likedBy"] != null
                    ? Map.from(postData["likedBy"])
                    : {};
                bool isLiked = currentUser != null && likedBy.containsKey(currentUser.uid);

                tempList.add({
                  "userId": userId,
                  "postId": postId,
                  "userName": userData["name"] ?? "Unknown",
                  "userPhoto": userData["photoUrl"] ?? "",
                  "mediaUrl": postData['mediaUrl'] ?? "",
                  "mediaType": postData["video"] == true ? "video" : "image",
                  "caption": postData["caption"] ?? "",
                  "likes": postData["likes"] ?? 0,
                  "likedBy": likedBy,
                  "isLiked": isLiked,
                  "comments": commentList,
                  "timestamp": postData["timestamp"] ?? DateTime.now().millisecondsSinceEpoch,
                });
              });
            }
          });

          // posts = tempList.reversed.toList(); // 🔴 Remove this line
          tempList.sort((a, b) => (b["timestamp"] as int).compareTo(a["timestamp"] as int));
          posts = tempList;// Latest post first
        }

        isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint("Error fetching posts: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  // ❤️ Like or Unlike
  Future<void> toggleLike(String postOwnerId, String postId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final postRef = _usersRef.child(postOwnerId).child("posts").child(postId);

    final snapshot = await postRef.get();
    final postData = snapshot.value as Map?;

    if (postData == null) return;

    int currentLikes = postData["likes"] ?? 0;
    Map likedBy = postData["likedBy"] ?? {};

    bool alreadyLiked = likedBy.containsKey(currentUser.uid);

    if (alreadyLiked) {
      likedBy.remove(currentUser.uid);
      currentLikes--;
    } else {
      likedBy[currentUser.uid] = true;
      currentLikes++;
    }

    await postRef.update({
      "likes": currentLikes,
      "likedBy": likedBy,
    });
  }

  // 💬 Add Comment
  Future<void> addComment(String userId, String postId, String comment) async {
    if (comment.trim().isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userSnapshot = await _usersRef.child(currentUser.uid).get();
    final userData = userSnapshot.value as Map?;

    String userName = userData?["name"] ?? "Unknown";
    String userPhoto = userData?["photoUrl"] ?? "";

    try {
      await _usersRef
          .child(userId)
          .child("posts")
          .child(postId)
          .child("comments")
          .push()
          .set({
        "userId": currentUser.uid,
        "userName": userName,
        "userPhoto": userPhoto,
        "comment": comment,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint("Error adding comment: $e");
    }
  }

  // ❌ Delete Comment
  Future<void> deleteComment(String userId, String postId, String commentKey) async {
    await _usersRef
        .child(userId)
        .child("posts")
        .child(postId)
        .child("comments")
        .child(commentKey)
        .remove();
  }

  // 🗑️ Delete Post
  Future<void> deletePost(String userId, String postId) async {
    try {
      await _usersRef
          .child(userId)
          .child("posts")
          .child(postId)
          .remove();
    } catch (e) {
      debugPrint("Error deleting post: $e");
    }
  }

  // 🧹 Clean up
  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }
}

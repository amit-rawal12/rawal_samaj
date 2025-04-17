import 'package:flutter/material.dart';
import '../Users Section/user_profile.dart';
import 'create_post_page.dart';
import 'e_book.dart';
import 'homepage.dart';
import 'member_list.dart';  // Member List Screen

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {

  List<Widget> pages = [
    HomeFeed(),
    UploadPostPage(),
    MemberList(),
    EBook(),
    ProfilePage(),// New Member List Screen
  ];

  int currentPage = 0;

  void updatePage(int index){
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPage],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFFF9933),
        onTap: updatePage,
        currentIndex: currentPage,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.post_add),
              label: "post"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: "Members"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: "Book"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_rounded),
              label: "Account"
          ),
        ],
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Home';
      case 1: return 'post';
      case 2: return 'Members';
      case 3: return 'Book';
      case 4: return 'Account';
      default: return '';
    }
  }
}

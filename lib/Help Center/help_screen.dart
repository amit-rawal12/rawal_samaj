import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rawal_samaj/Help%20Center/support_screen.dart';
import 'contact_us.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        elevation: 1,
        centerTitle: true,
        title: Text("Help Center", style: GoogleFonts.breeSerif(color: Colors.white, fontSize: 20)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          InkWell(onTap: () => Navigator.push(context, CupertinoDialogRoute(builder: (context) => Support(), context: context)),
        child: ListTile(
        leading: Text("Support",style: GoogleFonts.breeSerif(color: Colors.black,fontSize: 17),),
        trailing: Icon(Icons.arrow_forward_ios_rounded,color: Colors.grey,size: 19,),
            ),
      ),
          Divider(
            color: Colors.grey.shade100,
            endIndent: 7,
            indent: 7,
          ),
          InkWell(onTap: () => Navigator.push(context, CupertinoDialogRoute(builder: (context) => ContactUs(), context: context)),
            child: ListTile(
              leading: Text("Contact Us",style: GoogleFonts.breeSerif(color: Colors.black,fontSize: 17),),
              trailing: Icon(Icons.arrow_forward_ios_rounded,color: Colors.grey,size: 19,),
            ),
          ),
          Divider(
            color: Colors.grey.shade100,
            endIndent: 7,
            indent: 7,
          ),
        ],
      ),
    );
  }
}

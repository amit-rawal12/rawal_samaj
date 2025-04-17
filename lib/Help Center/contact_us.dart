import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {

  final String phone1 = "+916376599243";
  final String phone2 = "+916354806444";
  final String email = "info@rawalmatrimony.com";
  final String whatsappNumber = "+916354806444";

  void _launchPhone(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not launch $phoneNumber";
    }
  }  //call function

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Support Request',
        'body': 'Hello, I need some help regarding your service.'
      },
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication); // बाहरी ऐप में खोलें
    } else {
      throw "Could not launch Email";
    }
  }  // email function


  void _launchWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/$whatsappNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not launch WhatsApp";
    }
  }  // whatsapp function

  @override
  Widget build(BuildContext context) {
    Size media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Contact Us",
          style: GoogleFonts.breeSerif(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(30),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 3,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.black, size: 18),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("Rawal Brahmin Matrimony",style: GoogleFonts.breeSerif(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black),),
            SizedBox(height: 4,),

            Text("Rawal Brahmin Matrimony",style: TextStyle(fontSize: 15,),),
            Text("Jalore Rajasthan",style: TextStyle(fontSize: 15,),),

            SizedBox(height: 10,),
            InkWell(onTap: () => _launchPhone(phone1),
              child: Row(
                children: [
                  Icon(Icons.call,color: Colors.blue,size: 20,),
                  SizedBox(width: 5,),
                  Text("+91 6376599243",style: GoogleFonts.breeSerif(fontSize: 17,color: Colors.blue),)
                ],
              ),
            ),
            SizedBox(height: 8,),

            InkWell(onTap: () => _launchPhone(phone2),
              child: Row(
                children: [
                  Icon(Icons.call,color: Colors.blue,size: 20,),
                  SizedBox(width: 5,),
                  Text("+91 6354806444",style: GoogleFonts.breeSerif(fontSize: 17,color: Colors.blue),)
                ],
              ),
            ),

            SizedBox(height: 10,),

            InkWell( onTap: ()=> _launchEmail(email),
              child: Row(
                children: [
                  Icon(Icons.email,color: Colors.blue,size: 20,),
                  SizedBox(width: 5,),
                  Text("info@rawalmatrimony.com",style: GoogleFonts.breeSerif(fontSize: 17,color: Colors.blue),)
                ],
              ),
            ),
            SizedBox(height: media.height*0.034,),

            Center(
              child: ElevatedButton(
                onPressed: _launchWhatsApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CupertinoColors.systemGreen,
                  padding: EdgeInsets.symmetric(horizontal: media.width*0.13,vertical: 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Chat with us on WhatsApp",
                      style: GoogleFonts.breeSerif(
                        color: Colors.white,
                        fontSize: 16, // Text size बढ़ाया गया
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10,),
            Divider(
              color: Colors.grey,
            ),

            Text("Branch Locations",style: GoogleFonts.breeSerif(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black),),

            SizedBox(
              height: 20,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                  },
                  child: Container(
                    height: media.height * 0.085,
                    width: media.width * 0.43,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400, width: 0.4),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10), // थोड़ा padding दिया
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Jalore",
                                  style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "6376599243",
                                  style: GoogleFonts.breeSerif(
                                    color: Colors.grey.shade600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),


                InkWell(
                  onTap: () {
                  },
                  child: Container(
                    height: media.height * 0.085,
                    width: media.width * 0.43,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400, width: 0.4),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10), // थोड़ा padding दिया
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Pali",
                                  style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "6354806444",
                                  style: GoogleFonts.breeSerif(
                                    color: Colors.grey.shade600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

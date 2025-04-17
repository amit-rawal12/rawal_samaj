import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:url_launcher/url_launcher.dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  String? fileName;  //for file select
  final String phoneNumber = "+916354806444";

  Country selectedCountry = countries.firstWhere((c) => c.code == "IN"); // Default: India 🇮🇳
  TextEditingController phoneController = TextEditingController(); // Phone Number Controller
  TextEditingController messageController = TextEditingController();
  TextEditingController emailController =TextEditingController();


  // call function
  void _makePhoneCall()async{
    final Uri callUri = Uri.parse('tel:$phoneNumber');
    if(await canLaunchUrl(callUri)){
      await launchUrl(callUri);
    }else{
      print("could not launch call");
    }
  }

  //whatspp msg function
  void _openWhatsApp() async {
    String phoneNumber = "916354806444"; // 91 country code के साथ
    String message = Uri.encodeComponent("Hello, I need support!");

    Uri url = Uri.parse("https://wa.me/$phoneNumber?text=$message");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print("Could not launch WhatsApp");
    }
  }

  void showCountryPicker() {
    TextEditingController searchController = TextEditingController();
    List<Country> filteredCountries = countries;

    showModalBottomSheet(
      context: context,
      isScrollControlled: false, // Bottom Sheet पूरे स्क्रीन पर नहीं जाएगा
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  )
              ),

              padding: EdgeInsets.all(15),
              height: MediaQuery.of(context).size.height * 0.6, // आधी स्क्रीन जितना ऊंचा
              child: Column(
                children: [
                  // 🔹 Search Bar
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search Country",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredCountries = countries
                            .where((country) =>
                        country.name.toLowerCase().contains(value.toLowerCase()) ||
                            country.dialCode.contains(value))
                            .toList();
                      });
                    },
                  ),
                  SizedBox(height: 10),

                  // 🔹 Country List
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCountries.length,
                      itemBuilder: (context, index) {
                        Country country = filteredCountries[index];
                        return ListTile(
                          leading: Text(
                            country.flag,
                            style: TextStyle(fontSize: 22),
                          ),
                          title: Text(country.name),
                          trailing: Text("+${country.dialCode}"),
                          onTap: () {
                            setState(() {
                              selectedCountry = country;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),

                  // 🔹 Cancel Button
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.breeSerif(
                          color: Colors.red, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void removeFile() {
    setState(() {
      fileName = null; // Remove File Name
    });
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        fileName = result.files.single.name; // Store File Name in State
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Support",
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 13,right: 13,top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(onTap: _makePhoneCall,
                    child: Container(
                      height: media.height * 0.088,
                      width: media.width * 0.43,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey, width: 0.5),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9.0, vertical: 5.0),
                        child: Row(
                          children: [
                            // Call Icon (Circular)
                            Container(
                              height: 28,
                              width: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle, // Circular Shape
                                color: Colors.blue, // Blue Background
                              ),
                              child: Center(
                                child: Icon(Icons.call,
                                    color: Colors.white, size: 17), // Bigger Icon
                              ),
                            ),
                            SizedBox(width: 12), // Space between Icon and Text

                            // Call Text Details
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Call Now",
                                  style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2), // Small spacing
                                Text(
                                  "24/7 Customer...",
                                  style: GoogleFonts.breeSerif(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  InkWell(onTap: _openWhatsApp,
                    child: Container(
                      height: media.height * 0.088,
                      width: media.width * 0.43,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey, width: 0.5),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9.0, vertical: 5.0),
                        child: Row(
                          children: [
                            // WhatsApp Icon in Circular Shape
                            Center(
                              child: FaIcon(
                                FontAwesomeIcons.squareWhatsapp,
                                color: Colors.green,
                                size: 28, // Adjusted size for better balance
                              ),
                            ),
                            SizedBox(width: 12), // Space between Icon and Text

                            // WhatsApp Chat Text
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Chat with us",
                                  style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2), // Small spacing
                                Text(
                                  "on WhatsApp",
                                  style: GoogleFonts.breeSerif(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Text(
                "Support request",
                style: GoogleFonts.breeSerif(
                    color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
              ),
              SizedBox(height: 6),
              Text(
                "Our support team is standing by to help.",
                style: GoogleFonts.breeSerif(color: Colors.grey, fontSize: 13),
              ),
              SizedBox(height: 10),

              // 🔹 Name TextField
              TextField(
                decoration: InputDecoration(
                  hintText: "Full Name",
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey, width: 0.3),
                  ),
                ),
              ),

              SizedBox(height: media.height*0.015),

              // 🔹 Custom Country Code Picker + Phone Input
              GestureDetector(
                onTap: showCountryPicker,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      // Country Picker (Opens Bottom Sheet)
                      GestureDetector(
                        onTap: showCountryPicker,
                        child: Row(
                          children: [
                            Text(selectedCountry.flag, style: TextStyle(fontSize: 22)),
                            SizedBox(width: 10),
                            Text("+${selectedCountry.dialCode}",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),

                      SizedBox(width: 10),

                      // Phone Number Input Field
                      Expanded(
                        child: TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter phone number",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: media.height*0.015),

              // 🔹 WhatsApp Number Input
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email id",
                  hintText: "Email ID (Optional)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: media.height*0.015),


              TextField(
                controller: messageController,
                maxLines: 6, // Multi-line text field
                decoration: InputDecoration(
                  labelText: "Your Message",
                  alignLabelWithHint: true, // Proper alignment for multi-line
                  hintText: "Write your message here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, ),
                ),
                onChanged: (text) {
                  setState(() {}); // Update UI when text changes
                },
              ),

              // Character Counter
              Padding(
                padding: const EdgeInsets.only(top: 1, right: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${messageController.text.length}/600",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),



              InkWell(onTap: pickFile,  //file picker function
                child: Container(
                  height: media.height*0.045,
                  width: media.width*0.36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue,width: 0.7),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.attachment_outlined,color: Colors.blue,),
                        Text("Attach file",style: GoogleFonts.breeSerif(color: Colors.blue,fontWeight: FontWeight.w600),)
                      ]
                  ),
                ),
              ),

              // 🔹 Selected File Name (if available)
              // 🔹 Selected File Name + Remove Option
              if (fileName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Selected: $fileName",
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          overflow: TextOverflow.ellipsis, // If name is too long
                        ),
                      ),
                      SizedBox(width: 8),

                      // ❌ Remove Button
                      InkWell(
                        onTap: removeFile,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.1),
                          ),
                          child: Icon(Icons.close, color: Colors.red, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: media.height*0.03,),
              // 🔹 Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Submit Logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Submit Button Color
                    padding: EdgeInsets.symmetric(horizontal: media.width*0.35, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: media.height*0.02,),

            ],
          ),
        ),
      ),
    );
  }
}

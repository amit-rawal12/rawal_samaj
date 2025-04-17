import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false; // 🔁 Loader flag

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  File? _imageFile;
  String? _imageUrl; // ✅ Firebase Storage Image URL

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToFirebase(File image) async {
    try {
      String fileName = "profile_${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child("profile_images/$fileName");

      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint("🔥 Image Upload Error: $e");
      return "";
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      setState(() {
        _isLoading = true; // ✅ Loader Start
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String uid = userCredential.user!.uid;

        String imageUrl = await _uploadImageToFirebase(_imageFile!);
        if (imageUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image upload failed!")));
          setState(() {
            _isLoading = false; // ✅ Loader Stop
          });
          return;
        }

        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(uid);

        await userRef.set({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'dob': _dobController.text,
          'gender': _genderController.text,
          'aadhaar': _aadhaarController.text,
          'photoUrl': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration Successful!")));
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        setState(() {
          _isLoading = false; // ✅ Loader Stop
        });
      }
    } else {
      debugPrint("⚠️ Validation Failed or Image Not Selected");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields and upload an image")));
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isEmail = false, bool isNumber = false, int? length}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.orange[50],
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepOrange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value!.isEmpty) return "Enter your $label";
        if (isEmail && !value.contains('@')) return "Enter valid email";
        if (length != null && value.length != length) return "Enter valid $label";
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.orange[50],
        labelText: "Password",
        prefixIcon: Icon(Icons.lock, color: Colors.deepOrange),
        suffixIcon: IconButton(
          icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.deepOrange),
          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value!.length < 6 ? "Password must be 6+ characters" : null,
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register, // Disable when loading
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.5,
        )
            : Text(
          "Register",
          style: GoogleFonts.breeSerif(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoginText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Do you have an account?", style: GoogleFonts.breeSerif(fontSize: 17)),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          child: Text("Login", style: GoogleFonts.breeSerif(fontSize: 17, color: Colors.deepOrange)),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return TextFormField(
      controller: _genderController,
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.orange[50],
        labelText: "Gender",
        prefixIcon: Icon(Icons.person,color: Colors.deepOrange,),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onTap: () => showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: ["Male", "Female", "Other"].map((gender) =>
              ListTile(
                title: Text(gender),
                leading: Icon(gender == "Male" ? Icons.male : gender == "Female" ? Icons.female : Icons.transgender),
                onTap: () => setState(() { _genderController.text = gender; Navigator.pop(context); }),
              ),
          ).toList(),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Select Date of Birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepOrange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepOrange,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }


  @override
  Widget build(BuildContext context) {
    Size media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadowColor: Colors.deepOrange.shade100,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Create Account",
                        style: GoogleFonts.breeSerif(
                          fontSize: 26,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: media.height*0.02),
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.deepOrange.shade100,
                          backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                          child: _imageFile == null
                              ? Icon(Icons.camera_alt, size: 40, color: Colors.deepOrange)
                              : null,
                        ),
                      ),
                      SizedBox(height: media.height*0.02),
                      _buildTextField(_nameController, "Full Name", Icons.person),
                      SizedBox(height: media.height*0.02),
                      _buildTextField(_emailController, "Email", Icons.email, isEmail: true),
                      SizedBox(height: media.height*0.02),
                      _buildTextField(_phoneController, "Phone Number", Icons.phone, isNumber: true),
                      SizedBox(height: media.height*0.02),
                      _buildTextField(_addressController, "Address", Icons.location_city),
                      SizedBox(height: media.height*0.02),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: _buildTextField(_dobController, "Date of Birth", Icons.calendar_today),
                        ),
                      ),
                      SizedBox(height: media.height*0.02),
                      _buildGenderField(),
                      SizedBox(height: media.height*0.02),
                      _buildPasswordField(),
                      SizedBox(height: media.height*0.02),
                      _buildRegisterButton(),
                      SizedBox(height: media.height*0.02),
                      _buildLoginText(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



}

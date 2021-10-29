import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resident_app/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color primaryColor = const Color(0xff18203d);
  final Color secondaryColor = const Color(0xff232c51);

  final Color logoGreen = const Color(0xff25bcbb);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void generateOTP(int aadhaarNumber) {
    // TODO
  }

  void verifyOTP(int OTP) {
    bool verified = true;

    // TODO

    if (verified) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      passwordController.text = "Invalid OTP";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: primaryColor,
      body: Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Enter your Details',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(color: Colors.white, fontSize: 28),
              ),
              const SizedBox(height: 20),
              Text(
                'Enter your Aadhaar Number and OTP below to continue!',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 50),
              _buildTextField(nameController, Icons.account_circle, 'Aadhaar'),
              const SizedBox(height: 20),
              _buildTextField(passwordController, Icons.lock, 'OTP'),
              const SizedBox(height: 150),
              EditButton(
                innerText: "Generate OTP",
                buttonColor: Colors.teal,
                textColor: Colors.white,
                onPressed: () {
                  String stringAadhaarNum = nameController.text;
                  int aadhaarNum;

                  if (_isInValidAadhar(stringAadhaarNum)) {
                    nameController.text = "Enter a Valid Aadhar Number";
                    return;
                  }

                  aadhaarNum = int.parse(stringAadhaarNum);
                  generateOTP(aadhaarNum);
                },
              ),
              const SizedBox(height: 20),
              EditButton(
                innerText: "Verify",
                buttonColor: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  String stringOtp = passwordController.text;
                  int intOtp;

                  if (_isInValid(stringOtp)) {
                    passwordController.text = "Enter a Valid OTP";
                    return;
                  }

                  intOtp = int.parse(stringOtp);
                  verifyOTP(intOtp);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  bool _isInValid(String s) {
    if (s == '') {
      return true;
    }

    if (int.tryParse(s) == null) {
      return true;
    }

    //6 digit
    if (s.length == 6) {
      return false;
    } else {
      return true;
    }
  }

  bool _isInValidAadhar(String s) {
    if (s == '') {
      return true;
    }

    if (int.tryParse(s) == null) {
      return true;
    }

    //6 digit
    if (s.length == 12) {
      return false;
    } else {
      return true;
    }
  }

  _buildTextField(
      TextEditingController controller, IconData icon, String labelText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: secondaryColor, border: Border.all(color: Colors.blue)),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: Colors.white,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          hintText: labelText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
      ),
    );
  }
}

class EditButton extends StatelessWidget {
  final String innerText;
  final Color buttonColor;
  final Color textColor;
  final VoidCallback onPressed;

  // ignore: sort_constructors_first, use_key_in_widget_constructors
  const EditButton({
    required this.innerText,
    required this.buttonColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: buttonColor,
      borderRadius: BorderRadius.circular(6.0),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          child: Text(
            innerText,
            style: TextStyle(
              fontSize: 18,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

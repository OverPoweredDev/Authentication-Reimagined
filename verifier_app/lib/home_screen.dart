import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verifier_app/api/otp_auth.dart';
import 'package:verifier_app/api/otp_request.dart';
import 'package:verifier_app/qr_scanner.dart';

import 'camera_screen.dart';
import 'verifier_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryColor = const Color(0xff202020);
  final Color secondaryColor = const Color(0xff232c51);

  final Color logoGreen = const Color(0xff25bcbb);

  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  static const platform = MethodChannel('faceRD');

  String txnId = "";

  void uploadPhoto(String imageURI) {
    //in case you need the image as a file
    File image = File(imageURI);

    //same image as a string of bytes, easier to upload in a http request
    String imageBytes =
        'data:image/png;base64,' + base64Encode(image.readAsBytesSync());

    // TODO
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                'View Details',
                style: GoogleFonts.openSans(color: Colors.white, fontSize: 28),
              ),
              const SizedBox(height: 80),
              Text(
                'Face Recognition',
                style: GoogleFonts.openSans(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              EditButton(
                innerText: 'Test Camera',
                buttonColor: Colors.amber,
                textColor: Colors.black,
                onPressed: () async {
                  _showFaceDialog(context);
                },
              ),
              const SizedBox(height: 20),
              EditButton(
                innerText: 'Check Lighting',
                buttonColor: Colors.amber,
                textColor: Colors.black,
                onPressed: () async {
                  print("lighting");
                  await platform.invokeMethod('lightingIntent');
                  // await Future.delayed(const Duration(seconds: 30));
                  // bool res = await platform.invokeMethod('getResult');
                  // print(res);
                },
              ),
              const SizedBox(height: 20),
              EditButton(
                innerText: 'Offline Face Auth',
                buttonColor: Colors.amber,
                textColor: Colors.black,
                onPressed: () async {
                  await platform.invokeMethod('captureIntent');
                  String res = await platform.invokeMethod('getResult');
                },
              ),
              const SizedBox(height: 80),
              Text(
                'Verify Identity',
                style: GoogleFonts.openSans(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              EditButton(
                innerText: 'Scan QR Code',
                buttonColor: Colors.redAccent,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Scanner()),
                  );
                },
              ),
              const SizedBox(height: 20),
              EditButton(
                innerText: 'Enter OTP',
                buttonColor: Colors.redAccent,
                textColor: Colors.white,
                onPressed: () async {
                  txnId = await generateOTPapi(VerifierData.qrData);
                  _showOTPDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _waitForResult(bool result) async {
    await Future.delayed(const Duration(seconds: 3));
    _showSuccessFailureDialog(context, result);
  }

  _showFaceDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        late CameraDescription _cameraDescription;
        String _imagePath = '';

        return AlertDialog(
          content: SizedBox(
              height: 412,
              width: 400,
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  availableCameras().then((cameras) {
                    final camera = cameras
                        .where((camera) =>
                            camera.lensDirection == CameraLensDirection.back)
                        .toList()
                        .first;
                    setState(() {
                      _cameraDescription = camera;
                    });
                  }).catchError((err) {});

                  return Container(
                    padding: const EdgeInsets.only(top: 15.0),
                    color: primaryColor,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          height: 300,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              CardPicture(
                                onTap: () async {
                                  final String? path =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TakePhoto(
                                        camera: _cameraDescription,
                                      ),
                                    ),
                                  );

                                  // print('imagepath: $path');
                                  if (path != null && path.isNotEmpty) {
                                    setState(() {
                                      _imagePath = path;
                                    });
                                  }
                                },
                                imagePath: _imagePath,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: EditButton(
                              buttonColor: Colors.amberAccent,
                              innerText: "Done",
                              textColor: Colors.white,
                              onPressed: () {
                                uploadPhoto(_imagePath);
                                Navigator.pop(context);
                              },
                            )),
                      ],
                    ),
                  );
                },
              )),
          contentPadding: const EdgeInsets.all(0),
          backgroundColor: Colors.white,
          scrollable: true,
        );
      },
      barrierColor: Colors.black.withOpacity(0.75),
    );
  }

  _showOTPDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the OTP you recieved',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(otpController, Icons.lock, 'OTP'),
              const SizedBox(height: 20),
              EditButton(
                innerText: "Verify",
                buttonColor: Colors.redAccent,
                textColor: Colors.white,
                onPressed: () async {
                  String stringOtp = otpController.text;
                  int intOtp;

                  if (_isInValid(stringOtp)) {
                    otpController.text = "Enter a Valid OTP";
                    return;
                  }

                  intOtp = int.parse(stringOtp);

                  bool result =
                      await verifyOTPapi(VerifierData.qrData, intOtp, txnId);
                  print(result);

                  Navigator.pop(context);
                  _showSuccessFailureDialog(context, result);
                },
              ),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.all(0),
        backgroundColor: primaryColor,
        scrollable: true,
      ),
      barrierColor: Colors.black.withOpacity(0.75),
    );
  }

  _showSuccessFailureDialog(BuildContext context, bool result) {
    IconData icon = Icons.clear;
    Color dialogColor = Colors.redAccent;
    String text = "Authentication Failed, Please Try Again";

    if (result) {
      icon = Icons.check;
      dialogColor = Colors.green;
      text = "Authentication Succeeded!";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Icon(icon, size: 140, color: Colors.white),
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  text,
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.all(0),
        backgroundColor: dialogColor,
        scrollable: true,
      ),
      barrierColor: Colors.black.withOpacity(0.75),
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

  _buildTextField(
      TextEditingController controller, IconData icon, String labelText,
      [bool isDense = false]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: secondaryColor, border: Border.all(color: Colors.black38)),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: Colors.white,
          ),
          isDense: isDense,
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

class CardPicture extends StatelessWidget {
  const CardPicture({this.onTap, this.imagePath});

  final Function()? onTap;
  final String? imagePath;
  final color = Colors.white24;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (imagePath != null && imagePath != '') {
      return Card(
        color: color,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(10.0),
            width: size.width * .70,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: FileImage(File(imagePath as String)),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      color: color,
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
          width: size.width * .70,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Attach Picture',
                style: TextStyle(fontSize: 17.0, color: Colors.white),
              ),
              Icon(
                Icons.photo_camera,
                color: Colors.white54,
              )
            ],
          ),
        ),
      ),
    );
  }
}

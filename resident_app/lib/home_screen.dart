import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:resident_app/api/vid_otp_request.dart';
import 'package:resident_app/resident_data.dart';

import 'api/captcha_generation.dart';
import 'api/vid_generate.dart';
import 'camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryColor = const Color(0xff202020);
  final Color secondaryColor = const Color(0xff565656);

  final Color logoGreen = const Color(0xff25bcbb);

  final TextEditingController captchaController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String vidTxnID = "";
  Map<String, String?>? captcha;

  Future<String?> generateCaptcha() async {
    captcha = await generateCaptchaapi();
    return captcha!['captchaBase64String'];
  }

  void generateOTP(String aadhar, String captchaTxnId, String captchaValue) async {
    vidTxnID = await vidGenerateOTPapi(aadhar, captchaTxnId, captchaValue);
  }

  Future<String> generateVid(
      String aadhar, String mobile, int otp, String txnId) {
    return generateVidapi(aadhar, mobile, otp, txnId);
  }

  void verifyOTP(int OTP, String txnID) async {
    bool verified = true;

    Resident.phoneNum = phoneController.text;
    Resident.VID = await generateVid(Resident.aadharNum, phoneController.text, OTP, txnID);

    print(Resident.VID);

    if (verified) {
      Resident.isVIDUploaded = true;
      Navigator.pop(context);
      setState(() {});
    } else {
      otpController.text = "Invalid OTP";
    }
  }

  // void uploadPhoto(String imageURI) {
  //   //in case you need the image as a file
  //   File image = File(imageURI);
  //
  //   //same image as a string of bytes, easier to upload in a http request
  //   String imageBytes =
  //       'data:image/png;base64,' + base64Encode(image.readAsBytesSync());
  //
  //   // TODO
  // }

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
              const SizedBox(height: 100),
              Text(
                'Upload Information',
                style: GoogleFonts.openSans(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              _getVIDButton(),
              const SizedBox(height: 20),
              EditButton(
                innerText: 'Get eKYC Document',
                buttonColor: Colors.amber,
                textColor: Colors.black,
                onPressed: () {
                  _showFaceDialog(context);
                },
              ),
              const SizedBox(height: 80),
              Text(
                'Verify Identity',
                style: GoogleFonts.openSans(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              EditButton(
                innerText: 'Generate QR Code',
                buttonColor: Colors.redAccent,
                textColor: Colors.white,
                onPressed: () {
                  _showQRDialog(context);
                },
              ),
              const SizedBox(height: 180),
              Padding(
                padding: const EdgeInsets.only(left: 190),
                child: Text(
                  '202 ACCEPTED',
                  style: GoogleFonts.jetBrainsMono(
                      color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getVIDButton() {
    String buttonTitle = 'Get VID';
    if (Resident.isVIDUploaded) {
      buttonTitle = 'Recieved VID';
    }

    return EditButton(
      innerText: buttonTitle,
      buttonColor: _getButtonColor(Resident.isVIDUploaded),
      textColor: Colors.black,
      onPressed: () async {
        _showCaptchaDialog(context);
      },
    );
  }

  _getButtonColor(bool isUploaded) {
    if (isUploaded) {
      return Colors.grey;
    } else {
      return Colors.amber;
    }
  }

  _showCaptchaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String image64 = '';
        return AlertDialog(
          content: SizedBox(
              height: 360,
              width: 300,
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  if (image64.isEmpty) {
                    generateCaptcha().then((imageBase64) {
                      setState(() {
                        image64 = imageBase64!;
                      });
                    });
                  }

                  getImage() {
                    if (image64.isNotEmpty) {
                      return Image.memory(base64Decode(image64));
                    } else {
                      return Container();
                    }
                  }

                  return Container(
                    padding: const EdgeInsets.only(top: 15.0),
                    color: primaryColor,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          height: 100,
                          child: getImage(),
                        ),
                        const SizedBox(height: 20.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: _buildTextField(
                              phoneController, Icons.phone, 'Phone Number'),
                        ),
                        const SizedBox(height: 20.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: _buildTextField(captchaController,
                              Icons.text_format, 'Captcha Value'),
                        ),
                        const SizedBox(height: 20.0),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: EditButton(
                            buttonColor: Colors.redAccent,
                            innerText: "Verify Value",
                            textColor: Colors.white,
                            onPressed: () {
                              generateOTP(
                                Resident.aadharNum,
                                captcha!['captchaTxnId']!,
                                captchaController.text,
                              );
                              Navigator.pop(context);
                              _showOTPDialog(context);
                            },
                          ),
                        ),
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
                onPressed: () {
                  String stringOtp = otpController.text;
                  int intOtp;

                  if (_isInValid(stringOtp)) {
                    otpController.text = "Enter a Valid OTP";
                    return;
                  }

                  intOtp = int.parse(stringOtp);
                  verifyOTP(intOtp, vidTxnID);
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

  _showFaceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        late CameraDescription _cameraDescription;
        String _imagePath = '';

        return AlertDialog(
          content: SizedBox(
              height: 400,
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
                        const SizedBox(height: 20.0),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: EditButton(
                            buttonColor: Colors.redAccent,
                            innerText: "Upload Image",
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
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

  _showQRDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: SizedBox(
          width: 320,
          height: 312,
          child: QrImage(
            data: Resident.VID,
            version: QrVersions.auto,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.all(10),
            size: 300,
            gapless: false,
          ),
        ),
        contentPadding: const EdgeInsets.all(0),
        backgroundColor: Colors.white,
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

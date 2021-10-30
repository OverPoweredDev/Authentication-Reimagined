import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verifier_app/qr_scanner.dart';

import 'package:android_intent_plus/android_intent.dart';
import 'camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryColor = const Color(0xff202020);
  final Color secondaryColor = const Color(0xff232c51);

  final Color logoGreen = const Color(0xff25bcbb);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  static const platform = MethodChannel('faceRD');

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
                'Verify Identity',
                style: GoogleFonts.openSans(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              EditButton(
                innerText: 'Take Photo',
                buttonColor: Colors.amber,
                textColor: Colors.black,
                onPressed: () {
                  _showFaceDialog(context);
                },
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
            ],
          ),
        ),
      ),
    );
  }

  _showFaceDialog(BuildContext context) async {

    await platform.invokeMethod('captureIntent');

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
                              buttonColor: Colors.blue,
                              innerText: "Upload Image",
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

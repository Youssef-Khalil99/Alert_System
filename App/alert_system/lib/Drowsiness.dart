import 'dart:convert';
import 'package:alert_system/widgets/app_button.dart';
import 'package:alert_system/widgets/custom_app_bar.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'Drowsiness_Camera.dart';
import 'description.dart';


class Drowsiness extends StatefulWidget {
  const Drowsiness({super.key});

  @override
  State<Drowsiness> createState() => _DrowsinessState();
}

class _DrowsinessState extends State<Drowsiness> {

  String backgroundImage = "assets/images/background.jpg";
  File? _image;
  double? _imageWidth;
  double? _imageHeight;
  final picker = ImagePicker();
  String? _recognitions;


  Future selectFromGallery() async {
    final pickedXFile = await picker.pickImage(
        source: ImageSource.gallery);

    if (pickedXFile != null) {
      File pickedImage = File(pickedXFile.path);
      await sendImage(pickedImage, 'http://192.168.181.2:5000/drowsiness');
    }
  }

  Future selectFromCamera() async {
    final pickedXFile = await picker.pickImage(
        source: ImageSource.camera, imageQuality: 10);

    if (pickedXFile != null) {
      File pickedImage = File(pickedXFile.path);
      await sendImage(pickedImage, 'http://192.168.181.2:5000/drowsiness');
    }
  }

  Future sendImage(File image, String url) async {
    // if(image == null) return;
    setState(() {
      _image = image;
    });
    List<int> imageBytes = await image.readAsBytes();
    String base64Image =  base64Encode(imageBytes);
    await predict(base64Image, url);

    // get the width and height of selected image
    FileImage(image)
        .resolve(const ImageConfiguration())
        .addListener((ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageWidth = info.image.width.toDouble();
        _imageHeight = info.image.height.toDouble();
      });
    })));
  }


  Future predict(String base64Image, String url) async {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _recognitions = jsonDecode(response.body);
      });
    } else {
      setState(() {
        _recognitions = 'Request has been Failed';
      });
    }
  }

  Widget printValue(rcg) {
    if (rcg == null) {
      return const Text('',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700));
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                "Prediction: ",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    backgroundColor: Colors.teal.shade50),
              ),
            ),
            Flexible(
              child: Text(
                _recognitions!, overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    backgroundColor: Color(0xFFa3b18a)),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;

    double finalW;
    double finalH;

    if (_imageWidth == null && _imageHeight == null) {
      finalW = size.width;
      finalH = size.height;
    } else {
      double ratioW = size.width / _imageWidth!;
      double ratioH = size.height / _imageHeight!;

      finalW = _imageWidth! * ratioW * .85;
      finalH = _imageHeight! * ratioH * .50;
    }

//    List<Widget> stackChildren = [];

    return Scaffold(
        appBar: CustomAppBar(CustomAppBarAttributes(
            title: "Recognition Test",
            trailing: const Icon(Icons.batch_prediction))),
        body: Stack(
            children: [
              SizedBox(
                height: size.height,
                width: size.width,
                child: Image.asset(backgroundImage, fit: BoxFit.fill),
              ),
              ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                    child: printValue(_recognitions),
                  ),
              Stack(children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
                        child: Container(
                          height: 350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 5, color: Colors.teal),
                          ),
                          child: _image == null
                              ? const Center(
                              child: Text("Load an Image to Predict")
                          )
                              : Center(
                              child: Image.file(
                                _image!,
                                fit: BoxFit.fill,
                                width: finalW,
                                height: finalH,
                              )),
                        )),
                    Positioned(
                        right: 20,
                        child: Visibility(
                          visible: _image != null,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _image = null;
                                _recognitions = null;
                              });
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.redAccent,
                              // color: Colors.black54.shade100,
                              size: 30,
                            ),
                          ),
                        ))
                  ]),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Center(
                        child: AppButton(
                          width: 300,
                          height: 50,
                          color: Colors.blue,
                          icon: Icons.video_camera_back_outlined,
                          onTap: () async {
                            final cameras = await availableCameras();
                            final controller = CameraController(
                                cameras[1], ResolutionPreset.medium);
                            await controller.initialize();
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  DrowsinessCamera(controller: controller,),));
                          },
                        ),
                      )
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                          child: AppButton(
                            width: 150,
                            height: 50,
                            color: Colors.pinkAccent,
                            icon: Icons.camera_alt,
                            onTap: selectFromCamera,
                          )),
                      AppButton(
                          width: 150,
                          height: 50,
                          onTap: selectFromGallery,
                          color: Colors.teal,
                          icon: Icons.upload),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Center(
                      child: InkWell(
                        child: const Text(
                          "View Instruction",
                          style: TextStyle(
                              fontSize: 18,
                              decoration: TextDecoration.underline,
                              color: Colors.teal
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) =>
                              const Description(
                                title: "Drowsiness Prediction Model",
                                description: "The drowsiness prediction model is used to detect signs of driver drowsiness or fatigue.",
                                imageCaptureRecommendation: "To capture images for the drowsiness model, position the camera in front of the driver, facing them directly. This allows for a frontal view of the driver's face, which provides better visibility of facial features and indicators of drowsiness such as eye closure or head tilt. Ensure that the camera captures the driver's face clearly, including both eyes and facial expressions.",
                                image: "assets/images/407.jpg",

                              )
                              )
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ]
        ));
  }
}


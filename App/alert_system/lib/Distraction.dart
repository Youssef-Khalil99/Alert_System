import 'dart:convert';
import 'package:alert_system/widgets/app_button.dart';
import 'package:alert_system/widgets/custom_app_bar.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'Distraction_Camera.dart';
import 'description.dart';

class Distraction extends StatefulWidget {
  const Distraction({super.key});

  @override
  State<Distraction> createState() => _DistractionState();
}

class _DistractionState extends State<Distraction> {


  String backgroundImage = "assets/images/background.jpg";
  File? _image;
  double? _imageWidth;
  double? _imageHeight;
  final picker = ImagePicker();
  var _recognitions;


  Future selectFromGallery() async {
    final pickedXFile = await picker.pickImage(
        source: ImageSource.gallery);

    if (pickedXFile != null) {
      File pickedImage = File(pickedXFile.path);
      await sendImage(pickedImage, 'http://192.168.1.6:5000/distraction');
    }


  }

  Future selectFromCamera() async {
    final pickedXFile = await picker.pickImage(
        source: ImageSource.camera);

    if (pickedXFile != null) {
      File pickedImage = File(pickedXFile.path);
      await sendImage(pickedImage, 'http://192.168.1.6:5000/distraction');
    }
  }

  Future sendImage(File image, String url) async {
    // if(image == null) return;
    setState(() {
      _image = image;
    });
    final base64Image = base64Encode(image.readAsBytesSync());
    await predict(base64Image,url);

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


  Future predict(String base64Image, String url)async{

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
            Text(
              "Prediction: ",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  backgroundColor: Colors.teal.shade50),
            ),
            Text(
              _recognitions,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  backgroundColor: Color(0xFF8ecae6)),
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
          color: const Color(0xFF219ebc),
            title: "Recognition Test", trailing: const Icon(Icons.batch_prediction))),
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
                            border: Border.all(width: 5, color: const Color(0xFF219ebc)),
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
                          onTap: ()async {
                            final cameras = await availableCameras();
                            final CameraController controller = CameraController(cameras[1], ResolutionPreset.medium);
                            await controller.initialize();
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => DistractionCamera(controller: controller),));
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
                              color:Colors.teal
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const Description(
                                title: "Distracted Driver Prediction Model",
                                description: "The distracted driver prediction model is designed to identify driver distractions, such as mobile phone usage or other activities that divert attention from driving.",
                                imageCaptureRecommendation: "Capturing images for the distracted driver model is best achieved from the side of the driver. Position the camera to the side of the driver's seat, capturing a profile view of the driver. Ensure that the camera angle provides a clear view of the driver's face and the surrounding area.",
                                image: "assets/images/img_3590.jpg",

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

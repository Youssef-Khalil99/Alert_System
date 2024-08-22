import 'package:alert_system/widgets/custom_app_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';

class DistractionCamera extends StatefulWidget {

  final CameraController controller;
  const DistractionCamera({super.key, required this.controller});
  @override
  State<DistractionCamera> createState() => _CameraPageState();
}

class _CameraPageState extends State<DistractionCamera> {
  String backgroundImage = "assets/images/background.jpg";
  late CameraController _controller;
  Timer? _timer;
  String? _prediction;
  final player = AudioPlayer();
  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    // Start image capture
    _startImageCapture();

  }

  @override
  void dispose() async {
    _timer?.cancel();
    _controller.dispose();
    setDataImage(0);
    super.dispose();
  }

  Future<void> setDataImage(int value) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("data/image");
    await ref.set(value);
  }

  Future<void> setDataLevel(int value) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("data/level");
    await ref.set(value);
  }

  Future playAlertSound() async {
    String soundFilePath = 'sounds/alarm.wav'; // Replace with the actual path to your sound file
    await player.play(AssetSource(soundFilePath));
  }



  Future _startImageCapture() async {
    int alertCounter = 0;
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) async {
      try {
        final pickedXFileDriver = await _controller.takePicture();
        final pickedImageDriver = File(pickedXFileDriver.path);
        final base64ImageDriver = base64Encode(pickedImageDriver.readAsBytesSync());
        String? result = await predict(base64ImageDriver, 'http://192.168.1.6:5000/distraction');
        await setDataImage(1);
        setState(() {
          _prediction= result;

        });
        if (_prediction == 'Warning!!! There is an object') {
          alertCounter++;
          if (alertCounter == 3) {
            await setDataLevel(1);
            await playAlertSound();
          }
          else if (alertCounter == 4) {
            await setDataLevel(2);
            await playAlertSound();

          }else if (alertCounter == 5) {
            await setDataLevel(3);
            await playAlertSound();
          }
          else if (alertCounter == 6) {
            await setDataLevel(4);
            await playAlertSound();
          }
          else if(alertCounter >= 7){
            await playAlertSound();
          }
        } else {
          alertCounter = 0; // Reset the counter if 'Drowsiness Detected' is not received
          await setDataLevel(0);
        }

      } catch (e) {
        setState(() {
          _prediction = 'Error capturing image';
        });
      }
    });
  }





  Future predict(String base64Image, String url)async{

    final http.Response response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    else {
      return 'Request has been Failed';
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
                "Predictions: ",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    backgroundColor: Colors.teal.shade50),
              ),
            ),
            Flexible(
              child: Text(
                rcg,overflow: TextOverflow.ellipsis,
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
    Size size = MediaQuery.of(context).size;

    if (!_controller.value.isInitialized) {
      return Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }
    return Scaffold(
        appBar: CustomAppBar(CustomAppBarAttributes(
            title: "Camera Preview",
            trailing: const Icon(Icons.batch_prediction))),
        body: Stack(
          children: [
            SizedBox(
              height: size.height,
              width: size.width,
              child: Image.asset(backgroundImage, fit: BoxFit.fill),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                    child: printValue(_prediction),
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 5, color: Colors.teal),
                        ),
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: CameraPreview(_controller),
                        ),
                      )),
                  const SizedBox(
                    height: 55,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

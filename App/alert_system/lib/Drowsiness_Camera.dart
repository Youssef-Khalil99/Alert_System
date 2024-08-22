import 'package:alert_system/widgets/custom_app_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DrowsinessCamera extends StatefulWidget {

  final CameraController controller;

  const DrowsinessCamera({super.key, required this.controller});

  @override
  State<DrowsinessCamera> createState() => _DrowsinessCameraState();
}

class _DrowsinessCameraState extends State<DrowsinessCamera> {
  String backgroundImage = "assets/images/background.jpg";
  String token = '';
  late CameraController _controller;
  Timer? _timer;
  String? _recognitions;
  Uri uriAPI = Uri.parse('http://192.168.42.141:5000/drowsiness');
  final http.Client client = http.Client();
  final player = AudioPlayer();
  CollectionReference categories = FirebaseFirestore.instance.collection('documents');

  @override
  void initState(){
    super.initState();
    sendToFirebase(0);
    retrieveToken();
    _controller = widget.controller;
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   if (message.notification != null){
    //     print("===========foreGroundMessage==================");
    //     print(message.notification!.title);
    //     print(message.notification!.body);
    //     print("===========foreGroundMessage==================");
    //     //     // setState(() {
    //     //     //   body = message.notification!.body!;
    //     //     //   title = message.notification!.title!;
    //     //     // });
    //     //     // print(body);
    //     //     // print(title);
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${message.notification!.body}")));
    //     //     AwesomeDialog(context: context, title: message.notification!.title,body: Text("${message.notification!.body}"), dialogType: DialogType.error ).show();
    //   }
    // });
    _startImageCapture();
  }

  @override
  void dispose() async {
    _timer?.cancel();
    _controller.dispose();
    player.dispose();
    super.dispose();
    sendToFirebase(0);
  }

  // String? token = 'duco4VUeRjWbEJjPRuHD6t:APA91bHKMO8ayCC3mtgcfizNyUoIiYIblSmG5E5d7HS0E6fwlPKeI34Qpk4vMUYHc3D3vNPZwiqsf_4shE3jl8NueTwVoB5GUCYveacVaZzlU6JIS0Vu3U3C5nqX86IfGWOkfybprbeA';
  String? token2 = 'c7-SBV9RRSWD4CQzZrreNj:APA91bHPGf5PBXovhcsZk-HRBPVdG-SFpDqCHtqqGbGYw6Ssp8CGRBg-EkSDgy6bRgO5hb3bJhNp-uZn5ODd_qX175hoeqyFfL7BGUWehY4GV7_yxb9qVZ4Qp_W0WxyNAVsO0bf6r9z-';

  Future<void> retrieveToken() async{
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('UserTokens').doc('User1').get();
    setState(() {
      token = snapshot['token'];
    });
  }

  Future<void> sendNotification(String title, String content) async{
    var headersList = {
      'Accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'key=AAAAFtnQOAY:APA91bEHsPkpb_7qdCkUYeC5sUNPHPpMvo6gMCkKkPQ3TEctsSDgZIgdqA7hlnRma01D_x0IhLdncVJYmCV9aukIuHMrVEbQSNJnLP1o0iB33irEip5EjPvR04D41_O7UBRmnk4vLVsb'
    };
    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    var body = {
      "to": token,
      "notification": {
        "title": title,
        "body": content
      }
    };

    var req = http.Request('POST', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);


    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      print(resBody);
    }
    else {
      print(res.reasonPhrase);
    }
  }


  Future<void> sendToFirebase(int value) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("data/level");

    await ref.set(value);

  }

  playAlertSound(bool play) async {
    String soundFilePath = 'assets/sounds/mixkit-street-public-alarm-997.wav'; // Replace with the actual path to your sound file
    player.audioCache = AudioCache(prefix: '');
    if (play) {
      await player.play(AssetSource(soundFilePath));
    } else {
      await player.stop();
    }
  }


  Future<void> _startImageCapture() async {

    int drowsinessCounter = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 900), (Timer timer) async {
      try {
        XFile pickedXFile = await _controller.takePicture();
        File pickedImage = File(pickedXFile.path);
        List<int> imageBytes = await pickedImage.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        String result = await predict(base64Image);
        setState(() {
          _recognitions = result;
        });

        // Counter logic
        if(result == 'Drowsy')
          {
            drowsinessCounter++;

            if (drowsinessCounter == 3) {
              await sendToFirebase(1);
              await playAlertSound(true);
            }
            else if (drowsinessCounter == 6) {
              await sendToFirebase(2);
              await playAlertSound(true);
            }
            else if (drowsinessCounter == 9) {
              await sendToFirebase(3);
              await playAlertSound(true);
            }
            else if (drowsinessCounter >= 12 && drowsinessCounter % 2 == 0) {
              await playAlertSound(true);
              sendNotification('Alert!!!!', 'Driver is drowsy');
            }
          }
        else
          {
            drowsinessCounter = 0;
            await playAlertSound(false);
            await sendToFirebase(0);
          }

        // Send image as HTTP request to your API
      } catch (e) {
        setState(() {
          _recognitions = 'Could not sent the image';
        });
      }
    });
  }

  Future<String> predict(String base64Image)async{

    final http.Response response = await client.post(
      uriAPI,
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
                    child: printValue(_recognitions),
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
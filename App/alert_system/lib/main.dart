import 'package:alert_system/test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'HomePage.dart';

Future<void> getToken() async{
  await FirebaseMessaging.instance.getToken().then((token){
    print("=======================");
    print(token);
    print("=======================");
    saveToken(token!);
  }
  );
}
Future<void> saveToken(String user)async{
  DocumentReference categories = FirebaseFirestore.instance.collection('UserTokens').doc('User1');

  await categories.set(
      {
        'token' : user
      }
  );
}

Future<void> getPermission() async{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print("===========backGroundMessage==================");
  print(message.notification!.title);
  print(message.notification!.body);
  print("===========backGroundMessage==================");
}

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  getToken();
  getPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const CameraApp());
}

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:   const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

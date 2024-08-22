import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_dialog/awesome_dialog.dart';


class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    // getToken();

  }





  Future<void> sendNotification(String title, String content) async{
    var headersList = {
      'Accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'key=AAAAFtnQOAY:APA91bEHsPkpb_7qdCkUYeC5sUNPHPpMvo6gMCkKkPQ3TEctsSDgZIgdqA7hlnRma01D_x0IhLdncVJYmCV9aukIuHMrVEbQSNJnLP1o0iB33irEip5EjPvR04D41_O7UBRmnk4vLVsb'
    };
    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    var body = {
      "to": 'duco4VUeRjWbEJjPRuHD6t:APA91bHKMO8ayCC3mtgcfizNyUoIiYIblSmG5E5d7HS0E6fwlPKeI34Qpk4vMUYHc3D3vNPZwiqsf_4shE3jl8NueTwVoB5GUCYveacVaZzlU6JIS0Vu3U3C5nqX86IfGWOkfybprbeA',
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

  void sendPushMessage(String body, String title){
    try{
      http.patch(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String,String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAAFtnQOAY:APA91bEHsPkpb_7qdCkUYeC5sUNPHPpMvo6gMCkKkPQ3TEctsSDgZIgdqA7hlnRma01D_x0IhLdncVJYmCV9aukIuHMrVEbQSNJnLP1o0iB33irEip5EjPvR04D41_O7UBRmnk4vLVsb'
        },
        body: jsonEncode(
            <String,dynamic>{
              'priority': 'high',
              'data': <String,dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'status': 'done',
                'body': body,
                'title': title,
              },
              'notification': <String,dynamic>{
                'title': title,
                'body': body
              },
              'to': 'cTwX8Hn9Q5ykwp_a2LimkZ:APA91bFJE6WiGZICnRxvcs3OOXmD4a06sCSXUtwjUefkFZ9ZwZBQxAJkT1fRcVJYV0QuOBUyWBNSAQda252YtugaoI95OIvrBAOHvSNsh6n91TaId2zS3Oifs76E11c6E2UtAkph78GY'
            }
        ),
      );
    }catch(e){
      print("error has happen");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: MaterialButton(
          color: Colors.blueAccent,
          child: const Text("Click Me!"),
          onPressed: () async {
            // retrieveToken();
            // sendPushMessage('body', 'title');
            // saveToken('hello');
            // getToken();
            // sendNotification("hello!", "this a foreground@ notification");
            // AwesomeDialog(
            //   context: context,
            //   title: message.notification!.title,
            //   body: const Text("message.notification!.body!"),
            //   dialogType: DialogType.info,
            //
            // ).show();

          },
        ),
      ),
    );
  }
}

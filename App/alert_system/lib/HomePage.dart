import 'package:alert_system/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'Distraction.dart';
import 'Drowsiness.dart';


class HomePage extends StatelessWidget {

  final String backgroundImage = "assets/images/background.jpg";



  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
        appBar: CustomAppBar(CustomAppBarAttributes(
            title: "Home Page", trailing: const Icon(Icons.home))),
        body: Stack(
          children: [
            SizedBox(
              height: size.height,
              width: size.width,
              child: Image.asset(backgroundImage, fit: BoxFit.fill),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Text(
                    "Welcome to Driver Status Detection System.",
                    style: TextStyle(fontSize: 25,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.teal.shade50
                    ),
                    textAlign: TextAlign.center,

                  ),
                  const SizedBox(height: 30,),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: const Color(0xFF1d2d44))
                    ),
                      child: const Text("Start the Model for Prediction:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color(0xFF0d1321)))),
                  const SizedBox(height: 15,),
                  const Icon(Icons.keyboard_double_arrow_down_rounded, color: Color(0xFF0d1321),size: 50,),
                  const SizedBox(height: 10,),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 50),
                    height: 100,
                    width: 300,
                    decoration: BoxDecoration(
                        color: Colors.teal, borderRadius: BorderRadius.circular(12)),
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Drowsiness(),));
                      },
                      child: const Text("Start", style: TextStyle(fontSize: 30)),
                    ),
                  ),

                ],
              ),
            ),

          ],
        )
    );
  }
}

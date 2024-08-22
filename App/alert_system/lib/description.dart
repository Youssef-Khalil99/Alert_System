import 'package:alert_system/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class Description extends StatelessWidget {
  final String backgroundImage = "assets/images/background.jpg";
  final String? description;
  final String? imageCaptureRecommendation;
  final String? image;
  final String? title;
  const Description({super.key, required this.description, required this.imageCaptureRecommendation, required this.image, required this.title});


  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery
        .of(context)
        .size;
    
    return Scaffold(
      appBar: CustomAppBar(
        CustomAppBarAttributes(
          color: Colors.black,
          title: title
        )
      ),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(backgroundImage, fit: BoxFit.fill),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      const Text(
                        "Description",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 22
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          description!,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.normal
                          ),
                        ),
                      ),
                    ],
                  ),

                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      const Text(
                        "Image Capture Recommendation",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 22
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          imageCaptureRecommendation!,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.normal
                          ),
                        ),
                      )
                    ],
                  ),

                ),
                ListTile(
                  title: const Center(
                    child: Text(
                        "Image Example for best Prediction Result",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red
                      ),
                    ),
                  ),
                  subtitle: Container(
                    child: Image.asset(image!, fit: BoxFit.fill),
                  ),
                )
              ],
            ),
          )
        ],
      )
    );
  }
}

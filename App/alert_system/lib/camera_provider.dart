import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraProvider with ChangeNotifier {
  CameraController? controller;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller!.initialize();
    notifyListeners();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
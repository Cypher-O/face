import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CameraController? controller;
  late List<CameraDescription> cameras;
  int step = 0;
  final steps = ['Turn Left', 'Turn Right', 'Show Chin', 'Look Straight'];
  String guidance = '';

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[1], ResolutionPreset.high);
    await controller?.initialize();
    setState(() {});
  }

  Future<void> captureAndSendFrame() async {
    if (controller != null && controller!.value.isInitialized) {
      final XFile file = await controller!.takePicture();
      final bytes = await file.readAsBytes();

      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/real-time-recognition'),
        headers: {
          'X-API-Key': 'your-api-key',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'imageBytes': base64Encode(bytes),
          'step': step,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          guidance = responseData['data']['guidance'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Face Recognition')),
        body: Column(
          children: <Widget>[
            if (controller != null && controller!.value.isInitialized)
              Container(
                height: 400,
                child: CameraPreview(controller!),
              ),
            SizedBox(height: 20),
            Text('Guidance: $guidance', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                captureAndSendFrame();
              },
              child: Text('Capture Frame'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}


// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() => runApp(MyApp());

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   CameraController? controller;
//   late List<CameraDescription> cameras;
//   int step = 0;
//   final steps = ['Turn Left', 'Turn Right', 'Show Chin', 'Look Straight'];
 
//   @override
//   void initState() {
//     super.initState();
//     initCamera();
//   }

//   Future<void> initCamera() async {
//     cameras = await availableCameras();
//     controller = CameraController(cameras[1], ResolutionPreset.high);
//     await controller?.initialize();
//     setState(() {});
//   }

//   Future<void> captureAndSendFrame() async {
//     if (controller != null && controller!.value.isInitialized) {
//       final XFile file = await controller!.takePicture();
//       final bytes = await file.readAsBytes();

//       final response = await http.post(
//         Uri.parse('http://localhost:3000/api/auth/real-time-recognition'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'imageBytes': base64Encode(bytes),
//           'step': step
//         }),
//       );

//       final responseData = jsonDecode(response.body);
//       if (responseData['status'] == 'success') {
//         setState(() {
//           step++;
//         });
//       } else {
//         // Handle error
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Error'),
//             content: Text(responseData['message']),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Face Verification')),
//         body: controller == null || !controller!.value.isInitialized
//             ? const Center(child: CircularProgressIndicator())
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(steps[step]),
//                   const SizedBox(height: 20),
//                   AspectRatio(
//                     aspectRatio: controller!.value.aspectRatio,
//                     child: CameraPreview(controller!),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: step < steps.length ? captureAndSendFrame : null,
//                     child: const Text('Capture'),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }

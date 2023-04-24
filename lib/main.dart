import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:coeus/loading.dart';
import 'package:coeus/response_screen.dart';
import 'package:http/http.dart' as http;
import 'package:coeus/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:coeus/welcome.dart';
import 'package:http/http.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.last;
  runApp(MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
    ),
    debugShowCheckedModeBanner: false,
    // home: responseScreen(text: 'Hello',),
    home: SplashScreen(
      ca: firstCamera,
    ),
  ));
}

//TakePictureScreen(
// Pass the appropriate camera to the TakePictureScreen widget.
//  camera: firstCamera,
//),
// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.veryHigh,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
            title: const Text(
          'Capture the Problem',
          style: TextStyle(
              fontFamily: "Mukta",
              height: 1.2,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w700),
        )),
        // You must wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner until the
        // controller has finished initializing.
        body: Center(
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return CameraPreview(_controller);
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: Tooltip(
            message: 'Press it',
            verticalOffset: 40,
            height: 24,
            showDuration: const Duration(seconds: 1),
            // waitDuration: const Duration(seconds: 1),
            child: FloatingActionButton(
              // Provide an onPressed callback.
              onPressed: () async {
                // Take the Picture in a try / catch block. If anything goes wrong,
                // catch the error.
                try {
                  // Ensure that the camera is initialized.
                  await _initializeControllerFuture;

                  // Attempt to take a picture and get the file `image`
                  // where it was saved.
                  final image = await _controller.takePicture();

                  if (!mounted) return;

                  // If the picture was taken, display it on a new screen.
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DisplayPictureScreen(
                        // Pass the automatically generated path to
                        // the DisplayPictureScreen widget.
                        image: image,
                      ),
                    ),
                  );
                } catch (e) {
                  // If an error occurs, log the error to the console.
                  print(e);
                }
              },
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final XFile image;
  late Map<String, dynamic> ijson;
  DisplayPictureScreen({super.key, required this.image});

  Future<void> upload() async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            "https://backend-production-2203.up.railway.app/api/image-process"));

    request.files.add(http.MultipartFile(
        'file', image.readAsBytes().asStream(), await image.length(),
        filename: "data.jpeg"));
    var res = await request.send();
    ijson = jsonDecode(await res.stream.bytesToString());
    print(ijson);
  }

  // void fetchdata() async {
  //   final response = await get(Uri.parse("https://backend-production-2203.up.railway.app/api/generate-answer"));
  //   Map<String, dynamic> json = jsonDecode(response.body);
  //   print(json);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Captured Problem',
        style: TextStyle(
            fontFamily: "Mukta",
            height: 1.2,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w700),
      )),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Column(children: [
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(image.path),
            ],
          ),
        ),
      ]),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton.icon(
          onPressed: () async {
            await upload();
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => load(
                      text: ijson['response'].toString(),
                    )));
          },
          icon: const Icon(
            Icons.upload_file_sharp,
          ),
          label: const Text(
            'Submit',
            style: TextStyle(
                fontFamily: "Mukta",
                height: 1.2,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w700),
          ), // <-- Text
        ),
      ),
    );
  }
}

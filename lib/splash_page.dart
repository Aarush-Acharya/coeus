import 'dart:async';
import 'package:coeus/welcome.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.ca});
  final ca;
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  void _navigateAfter() {
    print("done timer");
    // Get.to(MyHomePage());
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => Welcome(
              cameran: widget.ca,
            )));
  }

  void startTimer() {
    Timer(const Duration(seconds: 3), _navigateAfter);
  }

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..forward();
    animation = CurvedAnimation(parent: controller, curve: Curves.bounceInOut);

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ScaleTransition(
          //   scale: animation,
          //   child:
          Center(
            //     child: Image.asset(
            //   "lib/hipi.png",
            //   width: 250,
            // )
            child: RiveAnimation.asset(
              'RiveAsset/beauty.riv',
            ),
          ),
          // ),
        ],
      ),
    );
  }
}

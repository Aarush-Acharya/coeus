import 'dart:async';
import 'package:coeus/response_screen.dart';
import 'package:coeus/welcome.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class load extends StatefulWidget {
  const load({super.key, required this.text});
  final text;
  @override
  _loadScreenState createState() => _loadScreenState();
}

class _loadScreenState extends State<load>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  void _navigateAfter() {
    print("done timer");
    // Get.to(MyHomePage());
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => responseScreen(
              text: widget.text,
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
    animation = CurvedAnimation(parent: controller, curve: Curves.bounceOut);
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
              'RiveAsset/car.riv',
            ),
          ),
          // ),
        ],
      ),
    );
  }
}
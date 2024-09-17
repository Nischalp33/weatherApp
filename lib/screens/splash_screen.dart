import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_m/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isSkipPressed = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();

    _checkSkipStatus(); // Check if skip was pressed before

    //5 seconds timer for the splash screen
    _timer = Timer(const Duration(seconds: 5), () {
      if (!_isSkipPressed) {
        _navigateToHome();
      }
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

//check skip button status
  Future<void> _checkSkipStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSkipPressed = prefs.getBool('skipPressed') ?? false;
    });
    if (_isSkipPressed) {
      _navigateToHome();
    }
  }

//navigate to homeScreen
  Future<void> _navigateToHome() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

//set the skip button
  Future<void> _setSkipPressed() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('skipPressed', true);
  }

  @override
  Widget build(BuildContext context) {
    //height and width define
    final height = MediaQuery.sizeOf(context).height * 1;
    final width = MediaQuery.sizeOf(context).width * 1;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              //border image
              Image.asset(
                'assets/frame.png',
                fit: BoxFit.fill,
                width: width * 1,
                height: height * 1,
              ),
              Positioned(
                  top: height * .4,
                  left: width * .22,
                  right: width * .22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WE SHOW WEATHER FOR YOU',
                        style: GoogleFonts.lora(
                            fontSize: 30, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: height * .1,
                      ),

                      //button to skip the splash screen
                      SizedBox(
                        width: width * .6,
                        child: ElevatedButton(
                            onPressed: () async {
                              await _setSkipPressed(); // Save the skip button state
                              _navigateToHome();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                elevation: 5),
                            child: Text(
                              'Skip',
                              style: GoogleFonts.lora(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            )),
                      )
                    ],
                  ))
            ],
          ),
        ],
      ),
    );
  }
}

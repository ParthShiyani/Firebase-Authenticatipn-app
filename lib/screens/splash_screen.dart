import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  navigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool? isLoggedIn = prefs.getBool('isLogedIn') ?? false;

    if (isLoggedIn == true) {
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      Navigator.of(context).pushReplacementNamed('login_page');
    }
  }

  @override
  void initState() {
    super.initState();

    Duration duration = const Duration(seconds: 3);
    Timer(duration, () {
      navigate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const FlutterLogo(
              style: FlutterLogoStyle.horizontal,
              size: 200,
            ),
            const Spacer(),
            Text(
              "User Authentication",
              style: GoogleFonts.poppins(
                fontSize: 25,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const LinearProgressIndicator(
              minHeight: 10,
            ),
          ],
        ),
      ),
    );
  }
}

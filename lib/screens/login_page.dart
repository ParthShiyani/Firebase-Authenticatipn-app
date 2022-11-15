import 'package:email_authentication_app/globals/global.dart';
import 'package:email_authentication_app/helpers/direbase_auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();
  final TextEditingController emailSignInController = TextEditingController();
  final TextEditingController passwordSignInController =
      TextEditingController();

  String? email;
  String? password;
  bool passwordShow = true;

  @override
  void initState() {
    super.initState();

    //for internet connection
    Global.subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          Global.status = "offline";
        });
      } else {
        setState(() {
          Global.status = "online";
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    //for internet connection
    Global.subscription.cancel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xfffdfdfd),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Form(
                key: signInFormKey,
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "Log in",
                        style: GoogleFonts.poppins(
                          fontSize: 50,
                          color: const Color(0xff3356ee),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 70,
                    ),
                    TextFormField(
                      controller: emailSignInController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) =>
                          (val!.isEmpty) ? 'Enter email first...' : null,
                      onSaved: (val) {
                        email = val;
                      },
                      decoration: InputDecoration(
                          label: const Text("Email"),
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          hintText: "Enter email here..."),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: passwordSignInController,
                      obscureText: passwordShow,
                      validator: (val) =>
                          (val!.isEmpty) ? 'Enter password first...' : null,
                      onSaved: (val) {
                        password = val;
                      },
                      decoration: InputDecoration(
                          label: const Text("PassWord"),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                (passwordShow == false)
                                    ? passwordShow = true
                                    : passwordShow = false;
                              });
                            },
                            child: Icon((passwordShow == false)
                                ? Icons.hide_source
                                : Icons.remove_red_eye),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                          hintText: "Enter Password here..."),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0f1f41),
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Log In'),
                      onPressed: () async {
                        if (Global.status == "online") {
                          if (signInFormKey.currentState!.validate()) {
                            signInFormKey.currentState!.save();

                            User? user = await FirebaseAuthHelper
                                .firebaseAuthHelper
                                .signInUser(email: email!, password: password!);

                            if (user != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("Log in Successful\n${user.uid}"),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );

                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('isLogedIn', true);
                              Navigator.of(context)
                                  .pushReplacementNamed('/', arguments: user);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Login Failed"),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }

                            emailSignInController.clear();
                            passwordSignInController.clear();

                            setState(() {
                              email = "";
                              password = "";
                            });
                          }
                        } else {
                          noInternet();
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Center(
                      child: Text("or sign in with"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        GestureDetector(
                          onTap: () async {
                            if (Global.status == "online") {
                              User? user = await FirebaseAuthHelper
                                  .firebaseAuthHelper
                                  .signInWithGoogle();

                              if (user != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text("Login Successfull\n${user.uid}"),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('isLogedIn', true);
                                Navigator.of(context)
                                    .pushReplacementNamed('/', arguments: user);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Login Failed"),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } else {
                              noInternet();
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 20),
                            height: 25,
                            width: 25,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/images/g.png"),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.only(left: 20),
                          iconSize: 30,
                          onPressed: () async {
                            if (Global.status == "online") {
                              User? user = await FirebaseAuthHelper
                                  .firebaseAuthHelper
                                  .signInAnonymously();

                              if (user != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text("Login Successfull\n${user.uid}"),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('isLogedIn', true);
                                Navigator.of(context)
                                    .pushReplacementNamed('/', arguments: user);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Login Failed"),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } else {
                              noInternet();
                            }
                          },
                          icon: Icon(
                            Icons.person,
                            color: Colors.grey,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            CustomPaint(
              foregroundPainter: MyPainter2(),
              child: Container(
                alignment: Alignment.topCenter,
                height: 250,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          emailSignInController.clear();
                          passwordSignInController.clear();

                          setState(() {
                            email = "";
                            password = "";
                          });
                          Navigator.of(context)
                              .pushReplacementNamed("signup_page");
                        },
                        child: const Text(
                          "Sign up",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //no internet snakbar =====================
  noInternet() {
    return ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 2),
        content: Text("No Internet Connection available !"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class MyPainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint brush1 = Paint()
      ..color = const Color(0xfff3f4f6)
      ..style = PaintingStyle.fill // stroke requrid
      ..strokeWidth = 5;

    Paint brush2 = Paint()
      ..color = const Color(0xffeaebef)
      ..style = PaintingStyle.fill
      ..strokeWidth = 5;
    Paint brush3 = Paint()
      ..color = const Color(0xff0f1f41)
      ..style = PaintingStyle.fill
      ..strokeWidth = 5;

    Path path = Path();
    Path path2 = Path();
    Path path3 = Path();

    path.moveTo(0, size.height * 0.55);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.20,
        size.width * 0.50, size.height * 0.55);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.85, size.width, size.height * 0.55);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(size.width * 0.25, size.height * 0.40,
        size.width * 0.50, size.height * 0.70);
    path2.quadraticBezierTo(
        size.width * 0.75, size.height, size.width, size.height * 0.80);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    path3.moveTo(0, size.height * 0.75);
    path3.quadraticBezierTo(
        size.width * 0.20, size.height, size.width * 0.50, size.height * 0.80);
    path3.quadraticBezierTo(
        size.width * 0.85, size.height * 0.50, size.width, size.height * 0.60);
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();

    canvas.drawPath(path, brush1);
    canvas.drawPath(path2, brush2);
    canvas.drawPath(path3, brush3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

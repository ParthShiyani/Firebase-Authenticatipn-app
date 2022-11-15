import 'package:email_authentication_app/helpers/direbase_auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuthHelper.firebaseAuthHelper.signOut();

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLogedIn', false);

                Navigator.of(context)
                    .pushNamedAndRemoveUntil('login_page', (route) => false);
              },
              icon: Icon(Icons.logout))
        ],
      ),
    );
  }
}

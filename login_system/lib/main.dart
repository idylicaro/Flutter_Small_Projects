import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import '/pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/signin_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign In',
      theme: ThemeData.dark(),
      home: LoginPage(),
    );
  }
}



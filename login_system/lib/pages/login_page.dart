import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_system/pages/register_page.dart';
import 'package:login_system/pages/signin_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  User user;

  @override
  void initState() {
    _auth.userChanges().listen((event) => setState(() => user = event));
    super.initState();
  }

  void _pushPage(BuildContext context, Widget page){
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Card(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SignInButtonBuilder(
                    height: 60,
                    fontSize: 20,
                    icon: Icons.person_add,
                    backgroundColor: Colors.indigo,
                    text: 'Registration',
                    onPressed: () => _pushPage(context, RegisterPage()),
                  ),
                  Divider(),
                  SignInButtonBuilder(
                      height: 60,
                      fontSize: 20,
                      icon: Icons.verified_user,
                      backgroundColor: Colors.orange,
                      text: 'Sign In',
                      onPressed: () async {
                        _signInWithGoogle();
                      }
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> _signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        var googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
        final googleAuthCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(googleAuthCredential);
      }

      final user = userCredential.user;
      print('Sign In ${user.uid} with Google');
    } catch (e) {
      print(e);
    }
  }
}

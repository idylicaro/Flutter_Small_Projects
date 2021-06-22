import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final FirebaseAuth _auth = FirebaseAuth.instance;

class SignInPage extends StatefulWidget {
  final String title = 'Sign In';

  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  User user;

  @override
  void initState() {
    _auth.userChanges().listen((event) => setState(() => user = event));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            _OtherProvidersSignInSection(),
          ],
        );
      }),
    );
  }

  // Example code for sign out.
  Future<void> _signOut() async {
    await _auth.signOut();
  }
}


class _OtherProvidersSignInSection extends StatefulWidget {
  _OtherProvidersSignInSection();

  @override
  State<StatefulWidget> createState() => _OtherProvidersSignInSectionState();
}

class _OtherProvidersSignInSectionState
    extends State<_OtherProvidersSignInSection> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _tokenSecretController = TextEditingController();

  int _selection = 0;
  bool _showAuthSecretTextField = false;
  bool _showProviderTokenField = true;
  String _provider = 'GitHub';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 16),
                alignment: Alignment.center,
                child: SignInButton(
                  Buttons.GoogleDark,
                  text: 'Sign In',
                  onPressed: () async {
                    _signInWithGoogle();
                  },
                ),
              ),
            ],
          )),
    );
  }

  //Example code of how to sign in with Google.
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
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Sign In ${user.uid} with Google'),
      ));
    } catch (e) {
      print(e);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google: $e'),
        ),
      );
    }
  }
} 
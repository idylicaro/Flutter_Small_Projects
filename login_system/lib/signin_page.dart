import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final FirebaseAuth _auth = FirebaseAuth.instance;

/// Entrypoint example for various sign-in flows with Firebase.
class SignInPage extends StatefulWidget {
  /// The page title.
  final String title = 'Sign In & Out';

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
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return FlatButton(
              textColor: Theme.of(context).buttonColor,
              onPressed: () async {
                final User user = _auth.currentUser;
                if (user == null) {
                  Scaffold.of(context).showSnackBar(const SnackBar(
                    content: Text('No one has signed in.'),
                  ));
                  return;
                }
                await _signOut();

                final String uid = user.uid;
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('$uid has successfully signed out.'),
                ));
              },
              child: const Text('Sign out'),
            );
          })
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            _UserInfoCard(user),
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

class _UserInfoCard extends StatefulWidget {
  final User user;

  const _UserInfoCard(this.user);

  @override
  _UserInfoCardState createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<_UserInfoCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              alignment: Alignment.center,
              child: const Text(
                'User info',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (widget.user != null)
              if (widget.user.photoURL != null)
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Image.network(widget.user.photoURL),
                )
              else
                Align(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.black,
                    child: const Text(
                      'No image',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            Text(widget.user == null
                ? 'Not signed in'
                : '${widget.user.isAnonymous ? 'User is anonymous\n\n' : ''}'
                    'Email: ${widget.user.email} (verified: ${widget.user.emailVerified})\n\n'
                    'Phone number: ${widget.user.phoneNumber}\n\n'
                    'Name: ${widget.user.displayName}\n\n\n'
                    'ID: ${widget.user.uid}\n\n'
                    'Tenant ID: ${widget.user.tenantId}\n\n'
                    'Refresh token: ${widget.user.refreshToken}\n\n\n'
                    'Created: ${widget.user.metadata.creationTime.toString()}\n\n'
                    'Last login: ${widget.user.metadata.lastSignInTime}\n\n'),
            if (widget.user != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.user.providerData.isEmpty
                        ? 'No providers'
                        : 'Providers:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  for (var provider in widget.user.providerData)
                    Dismissible(
                      key: Key(provider.uid),
                      onDismissed: (action) =>
                          widget.user.unlink(provider.providerId),
                      child: Card(
                        color: Colors.grey[700],
                        child: ListTile(
                          leading: provider.photoURL == null
                              ? IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () =>
                                      widget.user.unlink(provider.providerId))
                              : Image.network(provider.photoURL),
                          title: Text(provider.providerId),
                          subtitle: Text(
                              "${provider.uid == null ? "" : "ID: ${provider.uid}\n"}"
                              "${provider.email == null ? "" : "Email: ${provider.email}\n"}"
                              "${provider.phoneNumber == null ? "" : "Phone number: ${provider.phoneNumber}\n"}"
                              "${provider.displayName == null ? "" : "Name: ${provider.displayName}\n"}"),
                        ),
                      ),
                    ),
                ],
              ),
            Visibility(
              visible: widget.user != null,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => widget.user.reload(),
                      icon: const Icon(Icons.refresh),
                    ),
                    IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => UpdateUserDialog(widget.user),
                      ),
                      icon: const Icon(Icons.text_snippet),
                    ),
                    IconButton(
                      onPressed: () => widget.user.delete(),
                      icon: const Icon(Icons.delete_forever),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateUserDialog extends StatefulWidget {
  final User user;

  const UpdateUserDialog(this.user);

  @override
  _UpdateUserDialogState createState() => _UpdateUserDialogState();
}

class _UpdateUserDialogState extends State<UpdateUserDialog> {
  TextEditingController _nameController;
  TextEditingController _urlController;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.user.displayName);
    _urlController = TextEditingController(text: widget.user.photoURL);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update profile'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            TextFormField(
              controller: _nameController,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'displayName'),
            ),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'photoURL'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autocorrect: false,
              validator: (String value) {
                if (value.isNotEmpty) {
                  var uri = Uri.parse(value);
                  if (uri.isAbsolute) {
                    //You can get the data with dart:io or http and check it here
                    return null;
                  }
                  return 'Faulty URL!';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.user.updateProfile(
                displayName: _nameController.text,
                photoURL: _urlController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        )
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
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
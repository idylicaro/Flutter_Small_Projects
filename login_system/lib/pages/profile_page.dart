import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:getwidget/getwidget.dart';

class UserInfoCard extends StatefulWidget {
  final User user;

  const UserInfoCard(this.user);

  @override
  UserInfoCardState createState() => UserInfoCardState();
}

class UserInfoCardState extends State<UserInfoCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue,Colors.indigo],
            stops: [0.1,0.4],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          )
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GFAvatar(
              backgroundImage: NetworkImage(widget.user.photoURL),
              radius: 60,
            ),
            ),
            Center(
              child: GFCard(
                boxFit: BoxFit.cover,
                title: GFListTile(
                  titleText: widget.user.displayName,
                  subtitleText: widget.user.email,
                ),
                color: Colors.white,
                content: Column(
                  children: [
                    GFTypography(
                      text: widget.user.uid,
                      type: GFTypographyType.typo6,
                      icon: Icon(Icons.perm_identity, color: Colors.greenAccent),
                    ),
                    Divider(),
                    GFTypography(
                      text: widget.user.emailVerified ? 'Email Verified': 'email not verified',
                      type: GFTypographyType.typo5,
                      icon: widget.user.emailVerified != null ? Icon(Icons.check, color: Colors.green) : Icon(Icons.block, color: Colors.redAccent),
                    ),
                    Divider(),
                    GFTypography(
                      text: widget.user.phoneNumber != null ? widget.user.phoneNumber: 'No cell number',
                      type: GFTypographyType.typo5,
                      icon: widget.user.phoneNumber != null ? Icon(Icons.check, color: Colors.green) : Icon(Icons.block, color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: GFButton(
                onPressed: () async {
                  await singOut(context);
                },
                text: 'SingOut',
                color: GFColors.DANGER,
                icon: Icon(Icons.exit_to_app),
                position: GFPosition.end,
                size: GFSize.LARGE,

              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> singOut(context) async {
  await GoogleSignIn().disconnect();
  await FirebaseAuth.instance.signOut();
  Navigator.pop(context);
}

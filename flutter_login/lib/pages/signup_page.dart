import 'package:flutter/material.dart';
import 'package:flutter_login/components/signup_form.dart';
import 'package:flutter_login/components/logo.dart';
import 'package:flutter_login/size.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: xlargeGap),
            Logo("Sign Up"),
            SizedBox(height: largeGap),
            SignUpForm(), 
          ],
        ),
      ),
    );
  }
}
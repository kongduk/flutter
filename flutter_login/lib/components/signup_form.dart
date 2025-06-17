import 'package:flutter/material.dart';
import 'package:flutter_login/size.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: "Name",
              hintText: "Enter your name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: mediumGap),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: mediumGap),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Password",
              hintText: "Enter your password",
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          SizedBox(height: largeGap),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, "/home");
            },
            child: Text("Sign Up"),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:rle/constants.dart';
import 'package:flutter/material.dart';
import 'package:rle/Components/roundedButton.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rle/Components/header.dart';
import 'package:http/http.dart' as http1;

class RegistrationScreen extends StatefulWidget {
  static String id = "registration_screen";
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool showSpinner = false;
  String username;

  submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      SnackBar snackBar = SnackBar(content: Text("Welcome $username"));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(),
      backgroundColor: Colors.black,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Center(
                  child: Text(
                    "Create a username",
                    style: TextStyle(fontSize: 25.0),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Container(
                  child: Form(
                    key: _formKey,
                    autovalidate: true,
                    child: TextFormField(
                      validator: (val) {
                        if (val.trim().length < 3 || val.isEmpty) {
                          return "Username too short";
                        } else if (val.trim().length > 12) {
                          return "Username too long";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (val) => username = val,
                      decoration: kTextFieldDecoration.copyWith(
                        labelText: "Username",
                        labelStyle: TextStyle(fontSize: 15.0),
                        hintText: "Must be at least 3 characters",
                      ),
                    ),
                  ),
                ),
              ),
              RoundedButton(
                title: 'Submit',
                onPressed: submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rle/Components/header.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: "Profile",
      ),
      body: Text("Profile"),
    );
  }
}

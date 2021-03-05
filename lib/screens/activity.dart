import 'package:flutter/material.dart';
import 'package:rle/Components/header.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, titleText: "Profile"),
      body: Text("Profile"),
    );
  }
}

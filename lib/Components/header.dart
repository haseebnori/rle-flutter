import 'package:flutter/material.dart';
import 'package:rle/screens/chat_screen.dart';
import 'package:rle/screens/welcome_screen.dart';

AppBar header(
  context, {
  bool isAppTitle = false,
  String titleText,
  removeBackButton = false,
}) {
  logout() {
    googleSignIn.signOut();
    Navigator.pushNamed(context, WelcomeScreen.id);
  }

  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    backgroundColor: Colors.deepOrange,
    title: Text(
      isAppTitle ? "RLE" : titleText,
      style: TextStyle(
        color: Colors.white,
        fontSize: isAppTitle ? 50.0 : 28.0,
      ),
    ),
    centerTitle: true,
    actions: <Widget>[
      PopupMenuButton<String>(
        elevation: 55.0,
        onSelected: (newValue) {
          // add this property

          if (newValue == '1') {
            Navigator.pushNamed(context, ChatScreen.id);
          }
          if (newValue == '0') {
            logout();
          }
        },
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<String>(
              child: Row(
                children: <Widget>[Icon(Icons.logout), Text(' Logout')],
              ),
              value: '0',
            ),
            PopupMenuItem<String>(
              child: Row(
                children: <Widget>[Icon(Icons.settings), Text(' Settings')],
              ),
              value: '1',
            ),
          ];
        },
        icon: CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage(currentUser.photoUrl),
        ),
      )
    ],
  );
}

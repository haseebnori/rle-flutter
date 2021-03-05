import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rle/main.dart';
import 'package:rle/screens/registration_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rle/Components/user.dart';
import 'package:rle/screens/search.dart';
import 'package:rle/screens/timeline.dart';
import 'package:rle/screens/upload.dart';
import 'package:rle/screens/profile.dart';
import 'package:rle/screens/activity.dart';
import 'package:algolia/algolia.dart';

final has = {"name": "John", "age": 30, "car": null};

final GoogleSignIn googleSignIn = GoogleSignIn();
final storageRef = FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');

final DateTime timeStamp = DateTime.now();
User currentUser;

class WelcomeScreen extends StatefulWidget {
  static String id = "welcome_screen";
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  bool isAuth = false;
  AnimationController controller;
  AnimationController controller1;
  Animation animation;
  PageController pageController;
  int pageIndex = 0;

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  logout() {
    googleSignIn.signOut();
  }

  @override
  void dispose() {
    controller.dispose();
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  buildAuthScreen() {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          children: <Widget>[
            ElevatedButton(
                child: Text(has[AutofillHints.name]), onPressed: logout),
            //Timeline(),
            ActivityFeed(),
            Upload(currentUser: currentUser),
            Search(),
            Profile(),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Colors.deepOrange,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 35.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
  }

  buildUnAuthScreen() {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: controller1.value,
                  ),
                ),
                Text(
                  'LE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 150.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 42.0,
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/google_logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();

    // dectects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error SignIn in $err');
    });
    //Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error SignIn in $err');
    });

    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    controller1 = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
      upperBound: 150.0,
    );
    animation =
        ColorTween(begin: Colors.white, end: Colors.black).animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
    controller1.forward();
    controller1.addListener(() {
      setState(() {});
    });
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFireStore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFireStore() async {
    // 1) check if user exists in users collection in database(according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user.id).get();
    // 2) if the user doesn't exist, then we want to take them to the create account page

    if (!doc.exists) {
      final username = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => RegistrationScreen()));

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.doc(user.id).set({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timeStamp": timeStamp,
      });
      doc = await usersRef.doc(user.id).get();
    }

    currentUser = User.fromDocument(doc);
    Map<String, dynamic> addData = {
      "id": user.id,
      "username": currentUser.username,
      "photoUrl": user.photoUrl,
      "email": user.email,
      "displayName": user.displayName,
      "bio": "",
      "timeStamp": timeStamp,
    };
    Algolia algolia = Algolia.init(
      applicationId: 'JFS9USS5TQ',
      apiKey: 'b3e278faa6507cd9830373e6d0bd88cc',
    );
    AlgoliaTask taskAdded,
        taskUpdated,
        taskDeleted,
        taskBatch,
        taskClearIndex,
        taskDeleteIndex;
    AlgoliaObjectSnapshot addedObject;

    taskAdded = await algolia.instance.index('users').addObject(addData);
    print(taskAdded.data);

    print(currentUser);
    print(currentUser.username);
  }

  login() {
    googleSignIn.signIn();
  }
}

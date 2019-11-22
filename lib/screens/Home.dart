import 'package:flash_chat/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/Profile.dart';
import 'package:flash_chat/screens/search.dart';
import 'package:flash_chat/screens/CameraHomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/models/user.dart';
import 'package:flash_chat/screens/activity_feed.dart';
import 'package:flash_chat/screens/contact.dart';

final _auth=FirebaseAuth.instance;
final usersRef = Firestore.instance.collection('Users');
FirebaseUser user_current;
User currentUser;
class Home extends StatefulWidget {
  static String id='home_screen';
  @override
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Home> {
  void initState(){
    super.initState();
    getcurrentuser();
    pageController = PageController();
  }
  void getcurrentuser() async{
    try {
      final user = await _auth.currentUser();
      if(user !=null){
        user_current = user;
        DocumentSnapshot doc = await usersRef.document(user_current.uid).get();
        currentUser = User.fromDocument(doc);
      }

    }catch(e){
      print(e.toString());
    }
  }

  PageController pageController;
  int pageIndex = 0;
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }
  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  Scaffold buildAuthScreen() {
    print('enter home');
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Contact(),
          ActivityFeed(),
          CameraHomeScreen(cameras,1,""),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.contacts)),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.photo_camera,
                size: 35.0,
              ),
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search)),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
          ]),
    );
    // return RaisedButton(
    //   child: Text('Logout'),
    //   onPressed: logout,
    // );
  }
  @override
  Widget build(BuildContext context) {
    return  buildAuthScreen();
  }
}
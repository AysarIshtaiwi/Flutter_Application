//import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/home.dart' as home;
import 'package:flash_chat/screens/header.dart';
import 'package:flash_chat/screens/progress.dart';
import 'package:flash_chat/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile.dart';

final _firestore = Firestore.instance;
final userref = _firestore.collection('Users');
final DateTime timestamp = DateTime.now();
final _auth = FirebaseAuth.instance;
User currentuser;
FirebaseUser user_current;
User user_profile_owner;
final friendsRef = Firestore.instance.collection('friends');
final activityFeedRef = Firestore.instance.collection('feed');

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFriend = false;
  String name;
  String currentUserId;

  String currentUserName;
  String profileUserId;

  String profileUserName;

  void initState() {
    super.initState();
    getcurrentuser();
    getprofile_owner_user();
    checkIfFriend();
  }

  void getcurrentuser() async {
    print('enter getcurrentuser metod');
    try {
      final user = await _auth.currentUser();
      print('assign user to current user from auth');
      if (user != null) {
        user_current = user;
        DocumentSnapshot doc = await _firestore
            .collection('Users')
            .document(user_current.uid)
            .get();
        setState(() {
          currentuser = User.fromDocument(doc);
          currentUserId = currentuser.id;
          currentUserName = currentuser.username;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void getprofile_owner_user() async {
    print('enter getcurrentuser metod');
    String id = widget.profileId;
    print("profile id is $id");
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Users').document(widget.profileId).get();
      setState(() {
        user_profile_owner = User.fromDocument(doc);
        profileUserId = user_profile_owner.id;
        profileUserName = user_profile_owner.username;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  checkIfFriend() async {
    print('profile id');
    print(widget.profileId);
    DocumentSnapshot doc = await friendsRef
        .document(widget.profileId)
        .collection('userFriends')
        .document(currentUserId)
        .get();
    setState(() {
      isFriend = doc == null ? false : true;
    });
    print('is friend');
    print(isFriend);
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 200.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: isFriend ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFriend ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFriend ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    print('you are friend?$isFriend');
    bool isProfileOwner = currentUserId == widget.profileId;
    print(widget.profileId);
    print("id value");
    if (isProfileOwner) {
      print(isProfileOwner);
      return buildButton(text: "Edit Profile", function: editProfile);
    } else if (isFriend) {
      return buildButton(
        text: "Unfriend",
        function: handleunfriendUser,
      );
    } else if (!isFriend) {
      return buildButton(
        text: "Add friend",
        function: handlefriendUser,
      );
    }
  }

  handleunfriendUser() {
    setState(() {
      isFriend = false;
    });
    // Make auth user follower of THAT user (update THEIR followers collection)
    friendsRef
        .document(widget.profileId)
        .collection('userFriends')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // Put THAT user on YOUR following collection (update your following collection)
    friendsRef
        .document(currentUserId)
        .collection('userFriends')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // add activity feed item for that user to notify about new follower (us)
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
          ..get().then((doc) {
            if (doc.exists) {
              doc.reference.delete();
            }
          });
  }

  handlefriendUser() {
    setState(() {
      isFriend = true;
    });
    // Make auth user friend of THAT user (update THEIR followers collection)
    friendsRef
        .document(widget.profileId)
        .collection('userFriends')
        .document(currentUserId)
        .setData({
      "username": currentUserName,
      "userId": currentUserId,
      //"userProfileImg": currentUser.photoUrl,
      "timestamp": timestamp,
    });
    // Put THAT user on YOUR friend collection (update your following collection)
    friendsRef
        .document(currentUserId)
        .collection('userFriends')
        .document(widget.profileId)
        .setData({
      "username": profileUserName,
      "userId": profileUserId,
      //"userProfileImg": currentUser.photoUrl,
      "timestamp": timestamp,
    });
    // add activity feed item for that user to notify about new follower (us)
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      "type": "added you",
      "ownerId": widget.profileId,
      //"username": home.currentUser.username,
      "username": currentUserName,
      "userId": currentUserId,
      //"userProfileImg": currentUser.photoUrl,
      "timestamp": timestamp,
    });
  }

  buildProfileHeader() {
    print(widget.profileId);
    return FutureBuilder(
      future: userref.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    // backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            // buildCountColumn("posts", 0),
                            //buildCountColumn("followers", 0),
                            //buildCountColumn("following", 0),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user_profile_owner.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  user_profile_owner.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2.0),
                child: Text(
                  user_profile_owner.email,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Profile"),
      body: ListView(
        children: <Widget>[buildProfileHeader()],
      ),
    );
  }
}

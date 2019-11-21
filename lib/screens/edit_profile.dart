import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flash_chat/models/user.dart';
import 'package:flash_chat/screens/home.dart';
import 'package:flash_chat/screens/progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';
final _firestore=Firestore.instance;
final userRef = _firestore.collection('Users');
final _auth=FirebaseAuth.instance;
FirebaseUser currentUser;
class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController userNameController = TextEditingController();

  bool isLoading = false;
  User user;

  bool _userNameValid = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    userNameController.text = user.username;

    setState(() {
      isLoading = false;
    });
  }

  Column builduserNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "User Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: userNameController,
          decoration: InputDecoration(
            hintText: "Update User Name",
            errorText: _userNameValid ? null : "Display Name too short",

          ),
        )
      ],
    );
  }


  updateProfileData() {


    if ( _userNameValid) {
      usersRef.document(widget.currentUserId).updateData({
        "user_name": userNameController.text,
      });
      SnackBar snackbar = SnackBar(content: Text("Profile updated!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: Colors.green,
            ),
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    top: 16.0,
                    bottom: 8.0,
                  ),
                  child: CircleAvatar(
                    radius: 50.0,
                   // backgroundImage:
                    //CachedNetworkImageProvider(user.photoUrl),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      builduserNameField(),
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed:updateProfileData,
                  child: Text(
                    "Update Profile",
                    style: TextStyle(
                      color: Theme
                          .of(context)
                          .primaryColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: FlatButton.icon(
                    onPressed: () async{
                      await  _auth.signOut();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
                    },
                    icon: Icon(Icons.cancel, color: Colors.red),
                    label: Text(
                      "Logout",
                      style: TextStyle(color: Colors.red, fontSize: 20.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

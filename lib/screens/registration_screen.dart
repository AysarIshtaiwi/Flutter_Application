import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/models/User.dart';
import 'package:flash_chat/screens/Home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


final _firestore=Firestore.instance;
User currentuser;
class RegistrationScreen extends StatefulWidget {
  static String id='registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth=FirebaseAuth.instance;


  bool showspinner=false;
  String email;
  String password;
  String username;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showspinner,
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
              SizedBox(
                height: 48.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    username=value;
                  },
                  decoration: KTextFieldDecoration.copyWith(hintText: 'Enter your name')),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email=value;
                  },
                  decoration: KTextFieldDecoration.copyWith(hintText: 'Enter your email')),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password=value;
                },
                decoration: KTextFieldDecoration.copyWith(hintText: 'Enter your password')),
              SizedBox(
                height: 24.0,
              ),

              RoundedButton(
                title: 'Register',
                clour: Colors.lightBlueAccent,
                onPressed: () async{
                  print(email);
                  print(password);
                  setState(() {
                    showspinner=true;
                  });
                  try {
                    print("123");
                    final  newuser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    FirebaseUser user =  await _auth.currentUser();
                    print("hie");
                    final user_id = user.uid;
                    _firestore.collection('Users').document(user_id).setData({
                      "id":user,
                      "user_name":username,
                      "email":email,
                      "password":password
                    });


                    if(newuser != null){
                      FirebaseUser user =  await _auth.currentUser();
                      final user_id = user.uid;
                      _firestore.collection('Users').document(user_id).setData({
                        "id":user_id,
                        "user_name":username,
                        "email":email,
                        "password":password
                      });

                      Navigator.pushNamed(context, Home.id);
                     // final doc = await _firestore.document(user_id).get();
                     // currentuser =User.fromDocument(doc);
                     // print(currentuser);
                     // print(currentuser.username);
                    }
                    setState(() {
                      showspinner=false;
                    });
                  }catch(e){
                    print(e.toString());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

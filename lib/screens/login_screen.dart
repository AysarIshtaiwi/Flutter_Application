import 'dart:core' as prefix0;
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flash_chat/screens/Home.dart';
class LoginScreen extends StatefulWidget {
  static String id='login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth=FirebaseAuth.instance;
  bool showspinner=false;
  String email;
  String password;
  String errormessage;
  bool emailValid=true;
  bool passwordValid=true;
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
                controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    errorText: emailValid ? null : errormessage,
                    hintText: 'Enter your email',
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                onChanged: (value) {
                  email=value;
                },
                ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    errorText: passwordValid ? null : errormessage,
                    hintText: 'Enter your Password',
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                onChanged: (value) {
                  password=value;
                },
                ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Log In',
                clour: Colors.lightBlueAccent,
                onPressed: ()async {
                 await checkemail(email);
                  setState(() {
                    showspinner=true;
                  });
                  try {

                      final user = await _auth.signInWithEmailAndPassword(
                          email: email, password: password);

                      if (user != null) {
                        Navigator.pushNamed(context, Home.id);
                      }
                      setState(() {
                        showspinner=false;
                      });

                  }catch(e){
                    print(e.code.toString());
                    if(e.code.toString()=='ERROR_USER_NOT_FOUND'){
                      setState(() {
                        emailValid=false;
                        errormessage='your email is not valid';
                      });

                    }else if(e.code.toString()=='ERROR_WRONG_PASSWORD'){
                      setState(() {
                        passwordValid=false;
                        errormessage='password is not correct';
                      });
                    }
                  }

                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  checkemail(String email) async{
    var userQuery =await Firestore.instance.collection('Users').where('email', isEqualTo: email).limit(1);
    userQuery.getDocuments().then((data){
      if (data.documents.length < 0){
      setState(() {
        SnackBar snackbar = SnackBar(content: Text("Wrong Email!"));
        _scaffoldKey.currentState.showSnackBar(snackbar);
      });
      }
      setState(() {

      });

     });
    }

}





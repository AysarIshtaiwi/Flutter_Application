import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/search.dart';
import 'package:flash_chat/screens/Home.dart';
import 'package:camera/camera.dart';



List<CameraDescription> cameras;

Future<Null> main() async {
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    //logError(e.code, e.description);
  }
  runApp(MaterialApp(

    initialRoute: Home.id,
    routes: {
      WelcomeScreen.id: (context) => WelcomeScreen(),
      Home.id: (context) => Home(),
      ChatScreen.id: (context) => ChatScreen(),
      LoginScreen.id: (context) => LoginScreen(),
      RegistrationScreen.id: (context) => RegistrationScreen(),
      Search.id: (context) => Search(),
      // EditProfile.id:(context)=>EditProfile(),
    },
    home: Home(),
  ),
  );
}

import 'package:flash_chat/main.dart';
import 'package:flash_chat/models/User.dart';
import 'package:flash_chat/screens/CameraHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
final userref = _firestore.collection('Users');
FirebaseUser loggedin;
User currentuser;
String id;
User frienduser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  final String profileId;

  ChatScreen({this.profileId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String friendId;

  String friendName;
  String friendemail;
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messagetext;

  @override
  void initState() {
    super.initState();
    getcurrentuser();
    getfrienduser();
  }

  void getcurrentuser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedin = user;
        id = user.uid;
        DocumentSnapshot doc = await userref.document(id).get();
        currentuser = User.fromDocument(doc);
        print(loggedin.email);
      }
    } catch (e) {
      print(e);
    }
  }

  getfrienduser() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Users').document(widget.profileId).get();
      setState(() {
        frienduser = User.fromDocument(doc);
        friendId = frienduser.id;
        friendName = frienduser.username;
        friendemail = frienduser.email;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
        title: Text(friendName == null ? "" : friendName),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Messages').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                final messages = snapshot.data.documents.reversed;
                List<MessageBubble> messageBubbles = [];
                for (var message in messages) {
                  final messagetext = message.data['text'];
                  final messagesender = message.data['sender'];
                  final currentuser = loggedin.email;
                  final messagesendto = message.data['sendto'];
                  final messageBubble = MessageBubble(
                    sender: messagesender,
                    text: messagetext,
                    isme: currentuser == messagesender,
                    isfriend: friendemail == messagesendto,
                  );
                  print('message sender $messagesender');
                  print("current user$currentuser");
                  print('message send to $messagesendto');
                  print('friend email $friendemail');
                  if ((messagesender == currentuser &&
                          messagesendto == friendemail) ||
                      (messagesender == friendemail &&
                          messagesendto == currentuser)) {
                    messageBubbles.add(messageBubble);
                  }
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    padding: EdgeInsets.all(10.0),
                    children: messageBubbles,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messagetext = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraHomeScreen(
                            cameras
                          ),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.photo_camera,
                      size: 25.0,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('Messages').add({
                        'text': messagetext,
                        'sender': loggedin.email,
                        'sendto': friendemail,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {this.sender, this.text, this.isme, this.isfriend, this.sendto});

  final String sender;
  final String sendto;
  final String text;
  final bool isme;
  final bool isfriend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(fontSize: 12.0, color: Colors.black54),
          ),
          Material(
            borderRadius: isme
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isme ? Colors.lightBlueAccent : Colors.white,
            child: Text(
              '$text ',
              style: TextStyle(
                color: isme ? Colors.white : Colors.black54,
                fontSize: 15.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

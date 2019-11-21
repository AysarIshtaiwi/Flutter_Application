//import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/profile.dart';
import 'package:flash_chat/screens/header.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flash_chat/screens/home.dart' as home;
import 'package:flash_chat/models//User.dart';
import 'package:flash_chat/screens/progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
final _firestore=Firestore.instance;
final activityFeedRef = Firestore.instance.collection('feed');
final _auth=FirebaseAuth.instance;
User currentuser;
FirebaseUser user_current;
class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
 String currentUserId ;
 String currentUserName ;
  void initState() {
    super.initState();
    getcurrentuser();
  }
  void getcurrentuser() async{
    print('enter getcurrentuser metod');
    try {
      final user = await _auth.currentUser();
      print('assign user to current user from auth');
      if(user !=null){
        user_current = user;
        DocumentSnapshot doc = await _firestore.collection('Users').document(user_current.uid).get();
        setState(() {
          currentuser = User.fromDocument(doc);
          currentUserId=currentuser.id;
          currentUserName=currentuser.username;
        });

      }

    }catch(e){
      print(e.toString());
    }
  }
  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .document(currentUserId)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .getDocuments();
    List<ActivityFeedItem> feedItems = [];
    snapshot.documents.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
      // print('Activity Feed Item: ${doc.data}');
    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: header(context, titleText: "Activity Feed"),
      body: Container(
          child: FutureBuilder(
            future: getActivityFeed(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              }
              return ListView(
                children: snapshot.data,
              );
            },
          )),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type; // 'like', 'follow', 'comment'
  //final String userProfileImg;
  final Timestamp timestamp;

  ActivityFeedItem({
    this.username,
    this.userId,
    this.type,
    //this.userProfileImg,
    this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc.data['username'],
      userId: doc.data['userId'],
      type: doc.data['type'],
      //userProfileImg: doc['userProfileImg'],
      timestamp: doc.data['timestamp'],
    );
  }

  configureMediaPreview() {
      mediaPreview = Text('');
    if (type == 'message') {
      activityItemText = "send you a message";
    } else if (type == 'added you') {
      activityItemText = "add you as friend";
    }  else {
      activityItemText = "Error: Unknown type '$type'";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview();
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' $activityItemText',
                    ),
                  ]),
            ),
          ),
          leading: CircleAvatar(
            //backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}
showProfile(BuildContext context, {String profileId}) {
  print(profileId);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          Profile(
            profileId: profileId,
          ),
    ),
  );
}

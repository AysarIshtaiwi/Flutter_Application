import 'package:cloud_firestore/cloud_firestore.dart';

class message {
  final String text;
  final String sender;
  final String sendto;



  message({
    this.text,
    this.sender,
    this.sendto,

  });

  factory message.fromDocument(DocumentSnapshot doc) {
    return message(text: doc.data['text'],
      sender: doc.data['sender'],
      sendto: doc.data['sendto'],
      );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String password;


  User({
    this.id,
    this.username,
    this.email,
    this.password,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(id: doc.data['id'],
      email: doc.data['email'],
      username: doc.data['user_name'],
      password: doc.data['password'], );

  }
}
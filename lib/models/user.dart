import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String username;
  String email;

  UserModel({required this.uid,required this.username, required this.email});

  static UserModel fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'],
      email: data['email'] ?? '',
      username: data['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'uid': uid,
    'username': username,
  };
}

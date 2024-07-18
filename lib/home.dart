import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_Screen.dart';
import 'models/user.dart';


class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

   HomeScreen({super.key});

  String chatRoomid(String u1, String u2) {
    if (u1[0].codeUnits[0] > u2[0].codeUnits[0]) {
      return "$u1$u2";
    } else {
      return "$u2$u1";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Users', style: TextStyle(color: Colors.black),),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/auth');
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var users = snapshot.data!.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(users[index].username, style: const TextStyle(color: Colors.white),),
                style: ListTileStyle.drawer,

                onTap: () {
                  String roomId = chatRoomid(_auth.currentUser!.uid, users[index].uid);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(user: users[index], chatroomid: roomId,),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

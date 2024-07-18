import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/user.dart';

class ChatScreen extends StatefulWidget {
  final UserModel user;
  final String chatroomid;

  const ChatScreen({super.key, required this.user, required this.chatroomid});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? loggedInUser;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          loggedInUser = user;
          currentUserId = user.uid;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void sendMessage() async {
    if (_controller.text.isNotEmpty) {
      Map<String, dynamic> msg = {
        "sendby": _auth.currentUser!.uid,
        "msg": _controller.text,
        "time": Timestamp.now()
      };

      if (_controller.text.isNotEmpty) {
        await FirebaseFirestore.instance.collection('chatroom').doc(
            widget.chatroomid).collection('chats').add(msg);
        _controller.clear();
      }
    }
  }


  Widget messages(Size size, Map<String, dynamic> map, BuildContext context,
      String messageId) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Message'),
              content: const Text(
                  'Are you sure you want to delete this message?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('chatroom')
                        .doc(widget.chatroomid)
                        .collection('chats')
                        .doc(messageId)
                        .delete();
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: size.width,
        alignment: map['sendby'] == _auth.currentUser!.uid
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.blue,
          ),
          child: Text(
            map['msg'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.username),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chatroom')
                  .doc(widget.chatroomid)
                  .collection('chats')
                  .orderBy('time', descending: false)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.data != null) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> map = snapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;
                      String messageId = snapshot.data!.docs[index].id;
                      return messages(size, map, context, messageId);
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

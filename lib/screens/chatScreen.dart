import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/providers/chatProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/userSchema.dart';
import 'package:oman_trippoint/widgets/chatBoxWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

class ChatScreen extends StatelessWidget {
  static String router = "/chat";
  static final store = FirebaseFirestore.instance;
  static final auth = FirebaseAuth.instance;

  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);

    return Builder(builder: (context) {
      if (auth.currentUser == null) {
        return Center(
          child: Text(AppHelper.returnText(
              context, "You haven't login ", "لم تقم بتسجيل الدخول")),
        );
      }
      return StreamBuilder(
          stream: store
              .collection(ChatProvider.collection)
              .where(UserProvider.collection,
                  arrayContains: auth.currentUser!.uid)
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return FutureBuilder(
                future: chatProvider.getChats(
                    query: snapshot.data!, context: context),
                builder: (BuildContext ctx, AsyncSnapshot<dynamic> snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (chatProvider.chats == null || chatProvider.chats == []) {
                    return Center(
                      child: Text(AppHelper.returnText(
                          context, "No chats", "لا توجد محادثات")),
                    );
                  }

                  return ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          AppHelper.returnText(
                              context, "Chat ... ", "دردشة ... "),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          ...chatProvider.chats.map((e) {
                            String userId = e.users.singleWhere(
                                (id) => id != auth.currentUser!.uid);

                            if (userId != null && e != null) {
                              return ChatBoxWidget(
                                chat: e,
                                key: Key(e.Id),
                              );
                            }
                            return const SizedBox();
                          }).toList(),
                        ],
                      ),
                    ],
                  );
                });
          });
    });
  }
}

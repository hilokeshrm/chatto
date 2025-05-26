import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../chat_screen.dart'; // Adjust path if needed

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // DEBUG: omit orderBy for now
    final chatsQuery = FirebaseFirestore.instance
        .collection('chats')
        .where('members', arrayContains: uid);
    // .orderBy('lastUpdated', descending: true); // ← COMMENTED OUT

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatsQuery.snapshots(),
        builder: (context, snapshot) {
          // Print out how many docs we got
          if (snapshot.hasData) {
            debugPrint("🔍 Found ${snapshot.data!.docs.length} chat docs");
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading chats: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;
          if (chats.isEmpty) {
            return const Center(child: Text('No chats yet'));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final members = List<String>.from(chat['members'] as List);
              final otherUid = members.firstWhere(
                    (u) => u != uid,
                orElse: () => uid,
              );

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUid)
                    .get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const ListTile(title: Text('Loading user…'));
                  }
                  final userData =
                  userSnap.data!.data()! as Map<String, dynamic>;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: userData['photoUrl'] != null
                          ? NetworkImage(userData['photoUrl'])
                          : null,
                      child: userData['photoUrl'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(userData['name'] ?? 'Unknown'),
                    subtitle: Text(chat['lastMessage'] ?? ''),
                    trailing: chat['lastUpdated'] != null
                        ? Text(
                      _formatTimestamp(
                        chat['lastUpdated'] as Timestamp,
                      ),
                      style: const TextStyle(fontSize: 12),
                    )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chat.id,
                            otherUser: userData,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "${dateTime.hour.toString().padLeft(2, '0')}:"
          "${dateTime.minute.toString().padLeft(2, '0')}";
    } else {
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }
  }
}

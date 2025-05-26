import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../chat/chat_screen.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  String generateChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return "${sorted[0]}_${sorted[1]}";
  }

  Future<String> getOrCreateChat(String currentUid, String otherUid) async {
    final chatId = generateChatId(currentUid, otherUid);
    final chatDoc = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final docSnapshot = await chatDoc.get();

    if (!docSnapshot.exists) {
      await chatDoc.set({
        'members': [currentUid, otherUid],
        'isGroup': false,
        'lastMessage': '',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }

  void openChat(BuildContext context, String chatId, Map<String, dynamic> otherUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(chatId: chatId, otherUser: otherUser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('Discover Users')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading users: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final userData = userDoc.data()! as Map<String, dynamic>;
              final uid = userDoc.id;

              final targetUserData = uid == currentUser.uid
                  ? {
                'name': currentUser.displayName ?? 'You',
                'email': currentUser.email ?? '',
                'photoUrl': currentUser.photoURL,
              }
                  : userData;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: targetUserData['photoUrl'] == null
                        ? const Icon(Icons.person)
                        : ClipOval(
                      child: Image.network(
                        targetUserData['photoUrl'],
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person);
                        },
                      ),
                    ),
                  ),
                  title: Text(targetUserData['name'] ?? 'No Name'),
                  subtitle: Text(targetUserData['email'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.add), // plus icon for starting chat
                    onPressed: () async {
                      final chatId = await getOrCreateChat(currentUser.uid, uid);
                      openChat(context, chatId, targetUserData);
                    },
                  ),
                  onTap: () async {
                    final chatId = await getOrCreateChat(currentUser.uid, uid);
                    openChat(context, chatId, targetUserData);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

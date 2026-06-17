import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final currentUid = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      // Live-updating list of all users, pulled directly from
      // Firestore's 'users' collection via a snapshots() stream.
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs
              .where((doc) => doc.id != currentUid) // exclude self
              .toList();

          if (users.isEmpty) {
            return const Center(
              child: Text('No other users yet. Invite a friend to sign up!'),
            );
          }

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;
              final email = data['email'] ?? 'Unknown';
              final isOnline = data['isOnline'] ?? false;
              final otherUid = users[index].id;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.shade100,
                  child: Text(
                    email.isNotEmpty ? email[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(email),
                subtitle: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(isOnline ? 'Online' : 'Offline'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        otherUserId: otherUid,
                        otherUserEmail: email,
                      ),
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

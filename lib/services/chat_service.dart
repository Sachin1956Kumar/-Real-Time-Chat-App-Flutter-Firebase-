import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

// Handles sending messages and listening to a live message
// stream between two users.
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // -------------------------------------------------------
  // Builds a consistent, unique chat room ID for any pair of
  // users, regardless of who initiated the chat. Sorting the
  // two UIDs alphabetically guarantees user A->B and user B->A
  // both resolve to the SAME room ID.
  // -------------------------------------------------------
  String getChatRoomId(String userA, String userB) {
    List<String> ids = [userA, userB];
    ids.sort();
    return ids.join('_');
  }

  // -------------------------------------------------------
  // Send a message into the given chat room's message
  // subcollection.
  // -------------------------------------------------------
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderEmail,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    Message message = Message(
      senderId: senderId,
      senderEmail: senderEmail,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(message.toMap());

    // Also update a "last message" preview on the chat room
    // document itself, useful later for a chat-list screen.
    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'lastMessage': message.text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'participants': [senderId],
    }, SetOptions(merge: true));
  }

  // -------------------------------------------------------
  // Returns a real-time stream of messages for a chat room,
  // ordered oldest -> newest.
  // -------------------------------------------------------
  Stream<List<Message>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data()))
          .toList();
    });
  }
}

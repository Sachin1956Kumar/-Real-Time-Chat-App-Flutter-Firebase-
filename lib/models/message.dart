// Represents a single chat message stored in Firestore.
class Message {
  final String senderId;
  final String senderEmail;
  final String text;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.text,
    required this.timestamp,
  });

  // Convert a Message object into a Map for writing to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'text': text,
      'timestamp': timestamp,
    };
  }

  // Build a Message object from a Firestore document snapshot.
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] != null)
          ? map['timestamp'].toDate()
          : DateTime.now(),
    );
  }
}

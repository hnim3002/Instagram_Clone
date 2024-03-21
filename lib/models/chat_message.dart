
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/const.dart';

class ChatMessage {
  final String? messageId;
  final String? senderId;
  final String? type;
  final bool? isSeen;
  final String? messageContent;
  final Timestamp? timestamp;


  const ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.isSeen,
    required this.type,
    required this.messageContent,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    kKeyMessageId: messageId,
    kKeySenderId: senderId,
    kKeyIsSeen: isSeen,
    kKeyMessageType: type,
    kKeyMessageContent : messageContent,
    kKeyTimestamp: timestamp,
  };

  factory ChatMessage.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return ChatMessage(
      messageId: data?[kKeyMessageId],
      senderId: data?[kKeySenderId],
      isSeen: data?[kKeyIsSeen],
      type: data?[kKeyMessageType],
      messageContent: data?[kKeyMessageContent],
      timestamp: data?[kKeyTimestamp],);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (messageId != null) kKeyMessageId: messageId,
      if (senderId != null) kKeySenderId: senderId,
      if(isSeen != null) kKeyIsSeen: isSeen,
      if (type != null) kKeyMessageType: type,
      if (messageContent != null)  kKeyMessageContent: messageContent,
      if (timestamp != null) kKeyTimestamp: timestamp,
    };
  }
}
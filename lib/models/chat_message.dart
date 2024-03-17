
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/const.dart';

class ChatMessage {
  final String? messageId;
  final String? senderId;
  final String? type;
  final String? messageContent;
  final Timestamp? timestamp;


  const ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.type,
    required this.messageContent,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    kKeyMessageId: messageId,
    kKeySenderId: senderId,
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
      type: data?[kKeyMessageType],
      messageContent: data?[kKeyMessageContent],
      timestamp: data?[kKeyTimestamp],);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (messageId != null) kKeyChatRoomId: messageId,
      if (senderId != null) kKeyIsSeen: senderId,
      if (type != null) kKeyMessageType: type,
      if (messageContent != null)  kKeyParticipantsId: messageContent,
      if (timestamp != null) kKeyTimestamp: timestamp,
    };
  }
}
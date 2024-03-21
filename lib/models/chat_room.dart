

import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/const.dart';

class ChatRoom {
  final String? chatId;
  final bool? isSeen;
  final String? senderId;
  final List? participantsId;
  final String? lastMessage;
  final Timestamp? timestamp;


  const ChatRoom({
    required this.chatId,
    required this.isSeen,
    required this.senderId,
    required this.participantsId,
    required this.lastMessage,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    kKeyChatRoomId: chatId,
    kKeyIsSeen: isSeen,
    kKeySenderId: senderId,
    kKeyParticipantsId : participantsId,
    kKeyLastMessage: lastMessage,
    kKeyTimestamp: timestamp,
  };

  factory ChatRoom.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return ChatRoom(
        chatId: data?[kKeyChatRoomId],
        isSeen: data?[kKeyIsSeen],
        senderId: data?[kKeySenderId],
        participantsId: data?[kKeyParticipantsId],
        lastMessage: data?[kKeyLastMessage],
        timestamp: data?[kKeyTimestamp],);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (chatId != null) kKeyChatRoomId: chatId,
      if (isSeen != null) kKeyIsSeen: isSeen,
      if (senderId != null) kKeySenderId: senderId,
      if (participantsId != null)  kKeyParticipantsId: participantsId,
      if (lastMessage != null)  kKeyLastMessage: lastMessage,
      if (timestamp != null)  kKeyTimestamp: timestamp,
    };
  }
}
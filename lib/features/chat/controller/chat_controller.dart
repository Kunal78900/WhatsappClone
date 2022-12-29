import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/common/providers/message_reply_provider.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_ui/models/message.dart';

import '../../../models/chat_contact.dart';
import '../repositotries/chat_repository.dart';

final chatControllerProvider = Provider((ref) {
  // ignore: non_constant_identifier_names
  final ChatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(
    chatRepository: ChatRepository,
    ref: ref,
  );
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;
  ChatController({
    required this.chatRepository,
    required this.ref,
  });

  Stream<List<ChatContact>> chatContacts() {
    return chatRepository.getChatContacts();
  }

  Stream<List<Message>> chatStream(String recieverUserId) {
    return chatRepository.getChatStream(recieverUserId);
  }

  void sendTextMessage(
    BuildContext context,
    String text,
    String recieverUserId,
  ) {
    final messageReply = ref.read(MessageReplyProvider);
    ref
        .read(userDataAuthProvider)
        .whenData((value) => chatRepository.sendTextMessage(
              context: context,
              text: text,
              recieverUserID: recieverUserId,
              senderUser: value!,
              messageReply: messageReply,
            ));
    ref.read(MessageReplyProvider.state).update((state) => null);
  }

  void sendFileMessage(
    BuildContext context,
    File file,
    String recieverUserId,
    MessageEnum messageEnum,
  ) {
    final messageReply = ref.read(MessageReplyProvider);
    ref
        .read(userDataAuthProvider)
        .whenData((value) => chatRepository.sendFileMessage(
              context: context,
              file: file,
              recieverUserId: recieverUserId,
              senderUserData: value!,
              messageEnum: messageEnum,
              ref: ref,
              messageReply: messageReply,
            ));
    ref.read(MessageReplyProvider.state).update((state) => null);

  }
//   void sendGIFMessage(
//     BuildContext context,
//     String gifUrl,
//     String recieverUserId,
//  //   bool isGroupChat,
//   ) {
//   //  final messageReply = ref.read(messageReplyProvider);
//     int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
//     String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
//     String newgifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';

//     ref.read(userDataAuthProvider).whenData(
//           (value) => chatRepository.sendGIFMessage(
//             context: context,
//             gifUrl: newgifUrl,
//             recieverUserId: recieverUserId,
//             senderUser: value!,
//         //    messageReply: messageReply,
//         //    isGroupChat: isGroupChat,
//           ),
//         );
//    // ref.read(messageReplyProvider.state).update((state) => null);
//   }
  // ref.read(messageReplyProvider.state).update((state) => null);


  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ){
    chatRepository.setChatMessageSeen(
      context,
      recieverUserId,
      messageId,
    );
  }
}

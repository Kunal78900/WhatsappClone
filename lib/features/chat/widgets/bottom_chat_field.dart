import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/common/providers/message_reply_provider.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/chat/widgets/message_reply_preview.dart';
import 'package:whatsapp_ui/models/message.dart';

import '../../../common/utils/colors.dart';
import '../controller/chat_controller.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String recieverUserId;
  const BottomChatField({
    Key? key,
    required this.recieverUserId,
  }) : super(key: key);

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool isShowSendButton = false;
  final TextEditingController _messsageContoller = TextEditingController();
  FlutterSoundRecorder? _soundRecorder;
  bool isRecorderInit = false;
  bool isShowEmoji = false;
  bool isRecording = false;
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    openAudio();
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic not allowed');
    }
    await _soundRecorder!.openRecorder();
    isRecorderInit = true;
  }

  void sendTextMessage() async {
    if (isShowSendButton) {
      ref.read(chatControllerProvider).sendTextMessage(
            context,
            _messsageContoller.text.trim(),
            widget.recieverUserId,
          );
      setState(() {
        _messsageContoller.text = ' ';
      });
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';
      if (!isRecorderInit) {
        return;
      }
      if (isRecording) {
        await _soundRecorder!.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecorder!.startRecorder(
          toFile: path,
        );
      }
    }
    setState(() {
      isRecording = !isRecording;
    });
  }

  void sendFileMessage(
    File file,
    MessageEnum messageEnum,
  ) {
    ref
        .read(chatControllerProvider)
        .sendFileMessage(context, file, widget.recieverUserId, messageEnum);
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }
  // void selectGIF() async {
  //   final gif = await pickGIF(context);
  //   if (gif != null) {
  //     ref.read(chatControllerProvider).sendGIFMessage(
  //           context,
  //           gif.url,
  //           widget.recieverUserId,
  //         );
  //   }
  // }

  void hideEmojiContainer() {
    setState(() {
      isShowEmoji = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmoji = true;
    });
  }

  void showKeyBoard() => focusNode.requestFocus();
  void hideKeyBoard() => focusNode.unfocus();
  void toggleEmojiKeyboard() {
    if (isShowEmoji) {
      showKeyBoard();
      hideEmojiContainer();
    } else {
      hideKeyBoard();
      showEmojiContainer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messsageContoller.dispose();
    _soundRecorder!.closeRecorder();
    isRecorderInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(MessageReplyProvider);
    final isShowMessageReply = messageReply != null;
    return Column(
      children: [
        isShowMessageReply ? const MessageReplyPreview(): const SizedBox(),
        Container(
          height: 65,
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                  color: mobileChatBoxColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.emoji_emotions,
                        size: 30,
                        color: Colors.grey,
                      ),
                      onTap: toggleEmojiKeyboard,
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.gif,
                        color: Colors.grey,
                        size: 30,
                      ),
                      onTap: null,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 150,
                      child: TextFormField(
                        focusNode: focusNode,
                        controller: _messsageContoller,
                        onChanged: (val) {
                          if (val.isNotEmpty) {
                            setState(() {
                              isShowSendButton = true;
                            });
                          } else {
                            setState(() {
                              isShowSendButton = false;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'message!',
                          border: InputBorder.none,
                          // contentPadding: const EdgeInsets.all(3),
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.attach_file,
                        size: 30,
                        color: Colors.grey,
                      ),
                      onTap: selectVideo,
                    ),
                    SizedBox(
                      width: 15,
                      child: GestureDetector(
                        child: Icon(
                          Icons.photo,
                          size: 30,
                          color: Colors.grey,
                        ),
                        onTap: selectImage,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                    right: 2,
                    left: 2,
                  ),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF128C7E),
                    radius: 25,
                    child: GestureDetector(
                      child: Icon(
                        isShowSendButton
                            ? Icons.send
                            : isRecording
                                ? Icons.close
                                : Icons.mic,
                        color: Colors.white,
                      ),
                      onTap: sendTextMessage,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        isShowEmoji
            ? SizedBox(
                height: 210,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    setState(() {
                      _messsageContoller.text =
                          _messsageContoller.text + emoji.emoji;
                    });
                    if (!isShowSendButton) {
                      setState(() {
                        isShowSendButton = true;
                      });
                    }
                  },
                ))
            : const SizedBox(),
      ],
    );
  }
}

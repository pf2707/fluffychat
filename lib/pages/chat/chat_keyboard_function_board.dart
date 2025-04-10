
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pages/chat/chat_emoji_picker.dart';
import 'package:fluffychat/pages/chat/chat_function_picker.dart';
import 'package:flutter/material.dart';

class ChatKeyboardFunctionBoard extends StatelessWidget {
  final ChatController controller;
  const ChatKeyboardFunctionBoard(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: FluffyThemes.animationDuration,
      curve: FluffyThemes.animationCurve,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      height: _height(context),
      child: _builder(context),
    );
  }

  double _height(BuildContext context) {
    if (controller.showFunctionToolPicker) {
      return 262;
    } else if (controller.showEmojiPicker) {
      return MediaQuery.of(context).size.height / 2;
    }
    return 0;
  }

  Widget _builder(BuildContext context) {
    if (controller.showFunctionToolPicker) {
      return ChatFunctionPicker(controller);
    } else if (controller.showEmojiPicker) {
      return ChatEmojiPicker(controller);
    }
    return const SizedBox();
  }
}

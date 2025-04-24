
import 'dart:convert';

import 'package:fluffychat/pages/chat/events/custom/message_type_extension.dart';
import 'package:fluffychat/utils/common_extension.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class ShareContactsImpl {

  static Map<String, dynamic> _messageContentFrom(List<Profile> contacts) {
    final map = {
      'msgtype': MessageTypesExt.ShareContacts,
      'body': jsonEncode(contacts.map((e) => e.toJson()).toList()),
    };
    return map;
  }

  static List<Profile> getListOfSharedContacts(Event event) {
    final body = event.content.tryGet<String>("body") ?? "";
    final info = jsonDecode(body) as List<dynamic>?;
    if (info != null) {
      final medias = info.map((e) => Profile.fromJson(e)).toList();
      return medias;
    }
    return [];
  }

  static sendMessage(BuildContext outerContext, Room room, List<Profile> contacts) async {
    final scaffoldMessenger = ScaffoldMessenger.of(outerContext);
    final l10n = L10n.of(outerContext);

    // Send the message with multiple contacts
    final messageContent = _messageContentFrom(contacts);

    try {
      scaffoldMessenger.showLoadingSnackBar(
        l10n.sendingContacts,
      );
      await room.sendEvent(messageContent);
    } on MatrixException catch (e) {
      final retryAfterMs = e.retryAfterMs;
      if (e.error != MatrixError.M_LIMIT_EXCEEDED || retryAfterMs == null) {
        rethrow;
      }
      final retryAfterDuration =
      Duration(milliseconds: retryAfterMs + 1000);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.serverLimitReached(retryAfterDuration.inSeconds),
          ),
        ),
      );
      await Future.delayed(retryAfterDuration);

      scaffoldMessenger.showLoadingSnackBar(l10n.sendingContacts);
      await room.sendEvent(messageContent);
    }
    scaffoldMessenger.clearSnackBars();
  }
}
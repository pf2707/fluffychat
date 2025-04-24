
import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:fluffychat/model/media.dart';
import 'package:fluffychat/pages/chat/events/custom/message_type_extension.dart';
import 'package:fluffychat/pages/chat/events/custom/room_extension.dart';
import 'package:fluffychat/utils/common_extension.dart';
import 'package:fluffychat/utils/resize_video.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class VideoInfoItem {
  final XFile? file;
  final double? aspectRatio;
  VideoInfoItem({
    this.file,
    this.aspectRatio,
  });
}

class MultipleImagesImpl {

  // static Map<String, dynamic> _messageContentFrom(List<Media> medias, {String? caption}) {
  //   final map = {
  //     'msgtype': MessageTypesExt.Medias,
  //     'body': jsonEncode(medias.map((e) => e.toJson()).toList()),
  //     "caption": caption,
  //   };
  //   return map;
  // }

  static List<Media> getListOfImageUrls(Event event) {
    final body = event.content.tryGet<String>("body") ?? "";
    final info = jsonDecode(body) as List<dynamic>?;
    if (info != null) {
      final medias = info.map((e) => Media.fromJson(e)).toList();
      return medias;
    }
    return [];
  }

  static String? getCaption(Event event) {
    final caption = event.content.tryGet<String>('caption');
    return caption;
  }

  static bool hasCaption(Event event) {
    final caption = event.content.tryGet<String>('caption');
    return caption != null && caption.isNotEmpty;
  }

  static sendMessage(BuildContext outerContext, Room room, List<VideoInfoItem> files, {String? caption}) async {
    final scaffoldMessenger = ScaffoldMessenger.of(outerContext);
    final l10n = L10n.of(outerContext);

    scaffoldMessenger.showLoadingSnackBar(l10n.prepareSendingAttachment);

    // final clientConfig = await room.client.getConfig();
    // final maxUploadSize = clientConfig.mUploadSize ?? 100 * 1000 * 1000;
    //
    // final urls = <Media>[];
    //
    // await Future.forEach(files, (item) async {
    //   final xFile = item.file;
    //   if (xFile != null) {
    //     if (xFile.isVideo) {
    //       final videoFile = await xFile.resizeVideo();
    //       if (videoFile.bytes.length < maxUploadSize) {
    //         final thumbnail = await xFile.getVideoThumbnail();
    //         final uri = await room.client.uploadContent(videoFile.bytes);
    //
    //         if (thumbnail != null) {
    //           final thumbUri = await room.client.uploadContent(thumbnail.bytes);
    //           urls.add(Media(fileType: xFile.fileType, url: uri.toString(), name: xFile.name, thumbUrl: thumbUri.toString(), aspectRatio: item.aspectRatio,));
    //         } else {
    //           urls.add(Media(fileType: xFile.fileType, name: xFile.name, url: uri.toString(), aspectRatio: item.aspectRatio,));
    //         }
    //       }
    //     } else {
    //       final data = await xFile.readAsBytes();
    //       if (data.length < maxUploadSize) {
    //         final uri = await room.client.uploadContent(data);
    //         urls.add(Media(fileType: xFile.fileType, name: xFile.name, url: uri.toString()));
    //       }
    //     }
    //   }
    // });
    //
    // // Send the message with multiple image mxc URLs
    // final messageContent = _messageContentFrom(urls, caption: caption);

    scaffoldMessenger.clearSnackBars();
    try {
      // scaffoldMessenger.showLoadingSnackBar(
      //   l10n.sendingAttachment,
      // );
      // await room.sendEvent(messageContent);
      await room.sendMultipleMediasEvent(files, caption: caption);
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

      scaffoldMessenger.showLoadingSnackBar(l10n.sendingAttachment);
      // await room.sendEvent(messageContent);
      await room.sendMultipleMediasEvent(files,);
    }

    scaffoldMessenger.clearSnackBars();
  }
}
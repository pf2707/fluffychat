
import 'dart:convert';

import 'package:fluffychat/model/media.dart';
import 'package:fluffychat/pages/chat/events/custom/message_type_extension.dart';
import 'package:fluffychat/pages/chat/events/custom/multiple_images_impl.dart';
import 'package:fluffychat/utils/common_extension.dart';
import 'package:fluffychat/utils/resize_video.dart';
import 'package:matrix/encryption/encryption.dart';
import 'package:matrix/matrix.dart';

extension RoomExtension on Room {

  static final _staticSendingMediasPlaceholders = Expando<Map<String, List<dynamic>>>();
  Map<String, List<dynamic>> get _sendingMediasPlaceholders => _staticSendingMediasPlaceholders[this] ?? {};

  set _sendingMediasPlaceholders(Map<String, List<dynamic>> value) {
    _staticSendingMediasPlaceholders[this] = value;
  }

  Future<String?> sendMultipleMediasEvent(
    List<VideoInfoItem> files, {
        String? caption,
        String? txid,
        Event? inReplyTo,
        String? editEventId,
        int? shrinkImageMaxDimension,
        MatrixImageFile? thumbnail,
        Map<String, dynamic>? extraContent,
        String? threadRootEventId,
        String? threadLastEventId,
      }) async {
    txid ??= client.generateUniqueTransactionId();
    _sendingMediasPlaceholders[txid] = files;
    if (thumbnail != null) {
      sendingFileThumbnails[txid] = thumbnail;
    }

    // Create a fake Event object as a placeholder for the uploading file:
    final placeholderFiles = files.map((item) {
      if (item.file != null) {
        return Media(fileType: item.file!.fileType, url: "", name: item.file!.name, placeholderFilePath: item.file!.path);
      }
      return null;
    }).nonNulls.toList();
    final syncUpdate = SyncUpdate(
      nextBatch: '',
      rooms: RoomsUpdate(
        join: {
          id: JoinedRoomUpdate(
            timeline: TimelineUpdate(
              events: [
                MatrixEvent(
                  content: {
                    'msgtype': MessageTypesExt.Medias,
                    'body': jsonEncode(placeholderFiles.map((e) => e.toJson()).toList()), //empty for placeholder
                    "caption": caption,
                    if (extraContent != null) ...extraContent,
                  },
                  type: EventTypes.Message,
                  eventId: txid,
                  senderId: client.userID!,
                  originServerTs: DateTime.now(),
                  unsigned: {
                    messageSendingStatusKey: EventStatus.sending.intValue,
                    'transaction_id': txid,
                    // ...FileSendRequestCredentials(
                    //   inReplyTo: inReplyTo?.eventId,
                    //   editEventId: editEventId,
                    //   shrinkImageMaxDimension: shrinkImageMaxDimension,
                    //   extraContent: extraContent,
                    // ).toJson(),
                  },
                ),
              ],
            ),
          ),
        },
      ),
    );

    final clientConfig = await client.getConfig();
    final maxUploadSize = clientConfig.mUploadSize ?? 100 * 1000 * 1000;

    final medias = <Media>[];

    final timeoutDate = DateTime.now().add(client.sendTimelineEventTimeout * 5); // "sendTimelineEventTimeout" is 1 minute -> increase to 5 minutes
    syncUpdate.rooms!.join!.values.first.timeline!.events!.first
        .unsigned![fileSendingStatusKey] = FileSendingStatus.uploading.name;
    _handleFakeSync(syncUpdate);

    try {
      await Future.forEach(files, (item) async {
        final xFile = item.file;
        if (xFile != null) {
          if (xFile.isVideo) {
            final videoFile = await xFile.resizeVideo();
            if (videoFile.bytes.length < maxUploadSize) {
              final thumbnail = await xFile.getVideoThumbnail();
              final uri = await client.uploadContent(videoFile.bytes);

              if (thumbnail != null) {
                final thumbUri = await client.uploadContent(thumbnail.bytes);
                medias.add(Media(fileType: xFile.fileType, url: uri.toString(), name: xFile.name, thumbUrl: thumbUri.toString(), aspectRatio: item.aspectRatio,));
              } else {
                medias.add(Media(fileType: xFile.fileType, name: xFile.name, url: uri.toString(), aspectRatio: item.aspectRatio,));
              }
            }
          } else {
            final data = await xFile.readAsBytes();
            if (data.length < maxUploadSize) {
              final uri = await client.uploadContent(data);
              medias.add(Media(fileType: xFile.fileType, name: xFile.name, url: uri.toString()));
            }
          }
        }
      });
    } on MatrixException catch (_) {
      syncUpdate.rooms!.join!.values.first.timeline!.events!.first
          .unsigned![messageSendingStatusKey] = EventStatus.error.intValue;
      await _handleFakeSync(syncUpdate);
      rethrow;
    } catch (_) {
      if (DateTime.now().isAfter(timeoutDate)) {
        syncUpdate.rooms!.join!.values.first.timeline!.events!.first
            .unsigned![messageSendingStatusKey] = EventStatus.error.intValue;
        await _handleFakeSync(syncUpdate);
        rethrow;
      }
      Logs().v('Send Medias into room failed. Try again...');
      // await Future.delayed(const Duration(seconds: 1));
    }

    // Send the message with multiple image mxc URLs
    // final messageContent = _messageContentFrom(urls, caption: caption);
    final messageContent = {
      'msgtype': MessageTypesExt.Medias,
      'body': jsonEncode(medias.map((e) => e.toJson()).toList()),
      "caption": caption,
    };

    // MatrixFile uploadFile = file; // ignore: omit_local_variable_types
    // computing the thumbnail in case we can
    // if (file is MatrixImageFile &&
    //     (thumbnail == null || shrinkImageMaxDimension != null)) {
    //   syncUpdate.rooms!.join!.values.first.timeline!.events!.first
    //       .unsigned![fileSendingStatusKey] =
    //       FileSendingStatus.generatingThumbnail.name;
    //   await _handleFakeSync(syncUpdate);
    //   thumbnail ??= await file.generateThumbnail(
    //     nativeImplementations: client.nativeImplementations,
    //     customImageResizer: client.customImageResizer,
    //   );
    //   if (shrinkImageMaxDimension != null) {
    //     file = await MatrixImageFile.shrink(
    //       bytes: file.bytes,
    //       name: file.name,
    //       maxDimension: shrinkImageMaxDimension,
    //       customImageResizer: client.customImageResizer,
    //       nativeImplementations: client.nativeImplementations,
    //     );
    //   }
    //
    //   if (thumbnail != null && file.size < thumbnail.size) {
    //     thumbnail = null; // in this case, the thumbnail is not usefull
    //   }
    // }

    // Check media config of the server before sending the file. Stop if the
    // Media config is unreachable or the file is bigger than the given maxsize.
    final eventId = await sendEvent(
      messageContent,
      txid: txid,
      inReplyTo: inReplyTo,
      editEventId: editEventId,
      threadRootEventId: threadRootEventId,
      threadLastEventId: threadLastEventId,
    );
    _sendingMediasPlaceholders.remove(txid);
    // sendingFileThumbnails.remove(txid);
    return eventId;
  }

  Future<void> _handleFakeSync(
      SyncUpdate syncUpdate, {
        Direction? direction,
      }) async {
    if (client.database != null) {
      await client.database?.transaction(() async {
        await client.handleSync(syncUpdate, direction: direction);
      });
    } else {
      await client.handleSync(syncUpdate, direction: direction);
    }
  }
}
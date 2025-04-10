
import 'package:cross_file/cross_file.dart';
import 'package:fluffychat/pages/chat/events/custom/multiple_images_impl.dart';
import 'package:fluffychat/pages/chat/events/message_content.dart';
import 'package:fluffychat/utils/common_extension.dart';
import 'package:fluffychat/utils/localized_exception_extension.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_file_extension.dart';
import 'package:fluffychat/utils/other_party_can_receive.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/utils/resize_video.dart';
import 'package:fluffychat/utils/size_string.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/dialog_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matrix/matrix.dart';
import 'package:mime/mime.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:widget_zoom/widget_zoom.dart';

class SendImageScreen extends StatefulWidget {
  final Room room;
  final List<XFile> files;
  final BuildContext outerContext;

  const SendImageScreen({super.key,
    required this.room,
    required this.files,
    required this.outerContext,
  });

  @override
  State<SendImageScreen> createState() => _SendImageScreenState();
}

class _SendImageScreenState extends State<SendImageScreen> {

  bool compress = false;
  static const int minSizeToCompress = 20 * 1000;

  final TextEditingController _labelTextController = TextEditingController();
  final _pageController = PageController();

  Future<String> _calcCombinedFileSize() async {
    final lengths =
    await Future.wait(widget.files.map((file) => file.length()));
    return lengths.fold<double>(0, (p, length) => p + length).sizeString;
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    var sendStr = L10n.of(context).sendFile;
    final uniqueFileType = widget.files
        .map((file) => file.mimeType ?? lookupMimeType(file.name))
        .map((mimeType) => mimeType?.split('/').first)
        .toSet()
        .singleOrNull;

    // final fileName = widget.files.length == 1
    //     ? widget.files.single.name
    //     : L10n.of(context).countFiles(widget.files.length);
    // final fileTypes = widget.files
    //     .map((file) => file.name.split('.').last)
    //     .toSet()
    //     .join(', ')
    //     .toUpperCase();

    if (uniqueFileType == 'image') {
      if (widget.files.length == 1) {
        sendStr = L10n.of(context).sendImage;
      } else {
        sendStr = L10n.of(context).sendImages(widget.files.length);
      }
    } else if (uniqueFileType == 'audio') {
      sendStr = L10n.of(context).sendAudio;
    } else if (uniqueFileType == 'video') {
      sendStr = L10n.of(context).sendVideo;
    }

    // final compressionSupported =
    //     uniqueFileType != 'video' || PlatformInfos.isMobile;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(sendStr),
        leading: TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: false).pop(),
          child: SvgPicture.asset('assets/svg/ic_back.svg'),
        ),
      ),
      body: SizedBox(
        width: double.infinity, height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<String>(
                future: _calcCombinedFileSize(),
                builder: (context, snapshot) {
                  // final sizeString =
                  //     snapshot.data ?? L10n.of(context).calculatingFileSize;

                  return SizedBox(
                    width: double.infinity, height: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: widget.files.length,
                            itemBuilder: (ctx, i) => FutureBuilder(
                              future: widget.files[i].readAsBytes(),
                              builder: (context, snapshot) {
                                final bytes = snapshot.data;
                                if (bytes == null) {
                                  return const Center(
                                    child: CircularProgressIndicator
                                        .adaptive(),
                                  );
                                }
                                if (snapshot.error != null) {
                                  Logs().w(
                                    'Unable to preview image',
                                    snapshot.error,
                                    snapshot.stackTrace,
                                  );
                                  return const Center(
                                    child: SizedBox(
                                      width: 256,
                                      height: 256,
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        size: 64,
                                      ),
                                    ),
                                  );
                                }
                                return WidgetZoom(
                                  heroAnimationTag: i.toString(),
                                  maxScaleFullscreen: 5,
                                  minScaleFullscreen: 1,
                                  maxScaleEmbeddedView: 3,
                                  minScaleEmbeddedView: 1,
                                  zoomWidget: SizedBox(
                                    width: MediaQuery.of(context).size.width, height: double.infinity,
                                    child: Image.memory(
                                      bytes,
                                      height: double.infinity,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, e, s) {
                                        Logs()
                                            .w('Unable to preview image', e, s);
                                        return const Center(
                                          child: SizedBox(
                                            width: 256,
                                            height: 256,
                                            child: Icon(
                                              Icons.broken_image_outlined,
                                              size: 64,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            )
                          ),
                        ),

                        Positioned(
                          left: 20, right: 20, bottom: 16, height: 52,
                          child: Center(
                            child:  SmoothPageIndicator(
                              controller: _pageController,  // PageController
                              count: widget.files.length,
                              axisDirection: Axis.horizontal,
                              effect: const WormEffect(
                                dotWidth: 10,
                                dotHeight: 10,
                                radius: 5,
                                activeDotColor: Color(0xFF003EBF)
                              ),
                            ),
                          ),
                          // child: widget.files.length > 6 ?
                          // const SizedBox() :
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     for (var i = 0; i < widget.files.length; i++)...[
                          //
                          //     ]
                          //   ],
                          // ),
                        )
                      ],
                    ),
                  );
                  // return SizedBox(
                  //   width: double.infinity, height: double.infinity,
                  //   child: ListView.builder(
                  //     shrinkWrap: true,
                  //     itemCount: widget.files.length,
                  //     scrollDirection: Axis.horizontal,
                  //     itemBuilder: (context, i) => FutureBuilder(
                  //       future: widget.files[i].readAsBytes(),
                  //       builder: (context, snapshot) {
                  //         final bytes = snapshot.data;
                  //         if (bytes == null) {
                  //           return const Center(
                  //             child: CircularProgressIndicator
                  //                 .adaptive(),
                  //           );
                  //         }
                  //         if (snapshot.error != null) {
                  //           Logs().w(
                  //             'Unable to preview image',
                  //             snapshot.error,
                  //             snapshot.stackTrace,
                  //           );
                  //           return const Center(
                  //             child: SizedBox(
                  //               width: 256,
                  //               height: 256,
                  //               child: Icon(
                  //                 Icons.broken_image_outlined,
                  //                 size: 64,
                  //               ),
                  //             ),
                  //           );
                  //         }
                  //         return SizedBox(
                  //           width: MediaQuery.of(context).size.width, height: double.infinity,
                  //           child: Image.memory(
                  //             bytes,
                  //             height: double.infinity,
                  //             width: double.infinity,
                  //             fit: BoxFit.contain,
                  //             errorBuilder: (context, e, s) {
                  //               Logs()
                  //                   .w('Unable to preview image', e, s);
                  //               return const Center(
                  //                 child: SizedBox(
                  //                   width: 256,
                  //                   height: 256,
                  //                   child: Icon(
                  //                     Icons.broken_image_outlined,
                  //                     size: 64,
                  //                   ),
                  //                 ),
                  //               );
                  //             },
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // );
                },
              ),
            ),

            Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.only(top: 12, bottom: 34, left: 12, right: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: DialogTextField(
                        controller: _labelTextController,
                        labelText: L10n.of(context).optionalMessage,
                        minLines: 1,
                        maxLines: 3,
                        maxLength: 255,
                        counterText: '',
                        backgroundColor: const Color(0xFFE7E7E7),
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),

                    FloatingActionButton.small(
                      tooltip: L10n.of(context).send,
                      onPressed: _send,
                      elevation: 0,
                      heroTag: null,
                      backgroundColor: Colors.transparent,
                      child: SvgPicture.asset('assets/svg/ic_send_chat.svg'),
                    ),
                  ],
                )
            )
          ],
        )
      ),
    );
  }

  Future<void> _send() async {
    final scaffoldMessenger = ScaffoldMessenger.of(widget.outerContext);
    final l10n = L10n.of(context);

    try {
      if (!widget.room.otherPartyCanReceiveMessages) {
        throw OtherPartyCanNotReceiveMessages();
      }
      scaffoldMessenger.showLoadingSnackBar(l10n.prepareSendingAttachment);
      Navigator.of(context, rootNavigator: false).pop();
      final clientConfig = await widget.room.client.getConfig();
      final maxUploadSize = clientConfig.mUploadSize ?? 100 * 1000 * 1000;

      final uniqueFileType = widget.files
          .map((file) => file.mimeType ?? lookupMimeType(file.name))
          .map((mimeType) => mimeType?.split('/').first)
          .toSet()
          .singleOrNull;
      if (uniqueFileType == 'image' && widget.files.length > 1) {
        final urls = <String>[];

        await Future.forEach(widget.files, (xFile) async {
          final data = await xFile.readAsBytes();
          if (data.length < maxUploadSize) {
            final uri = await widget.room.client.uploadContent(data);
            // final url = uri.path;
            // final url2 = uri.toString();
            urls.add(uri.toString());
          }
        });

        // Send the message with multiple image mxc URLs
        final label = _labelTextController.text.trim();
        final messageContent = MultipleImagesImpl.messageContentFrom(urls, caption: label);

        try {
          scaffoldMessenger.showLoadingSnackBar(
            l10n.sendingAttachment,
          );
          await widget.room.sendEvent(messageContent);
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
          await widget.room.sendEvent(messageContent);
        }
      } else {
        for (final xFile in widget.files) {
          final MatrixFile file;
          MatrixImageFile? thumbnail;
          final length = await xFile.length();
          final mimeType = xFile.mimeType ?? lookupMimeType(xFile.path);

          // If file is a video, shrink it!
          if (PlatformInfos.isMobile &&
              mimeType != null &&
              mimeType.startsWith('video') &&
              length > minSizeToCompress &&
              compress) {
            scaffoldMessenger.showLoadingSnackBar(l10n.compressVideo);
            file = await xFile.resizeVideo();
            scaffoldMessenger.showLoadingSnackBar(l10n.generatingVideoThumbnail);
            thumbnail = await xFile.getVideoThumbnail();
          } else {
            if (length > maxUploadSize) {
              throw FileTooBigMatrixException(length, maxUploadSize);
            }
            // Else we just create a MatrixFile
            file = MatrixFile(
              bytes: await xFile.readAsBytes(),
              name: xFile.name,
              mimeType: mimeType,
            ).detectFileType;
          }

          if (file.bytes.length > maxUploadSize) {
            throw FileTooBigMatrixException(length, maxUploadSize);
          }

          if (widget.files.length > 1) {
            scaffoldMessenger.showLoadingSnackBar(
              l10n.sendingAttachmentCountOfCount(
                widget.files.indexOf(xFile) + 1,
                widget.files.length,
              ),
            );
          } else {
            scaffoldMessenger.clearSnackBars();
          }

          final label = _labelTextController.text.trim();

          try {
            await widget.room.sendFileEvent(
              file,
              thumbnail: thumbnail,
              shrinkImageMaxDimension: compress ? 1600 : null,
              extraContent: label.isEmpty ? null : {'body': label},
            );
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

            await widget.room.sendFileEvent(
              file,
              thumbnail: thumbnail,
              shrinkImageMaxDimension: compress ? 1600 : null,
              extraContent: label.isEmpty ? null : {'body': label},
            );
          }
        }
      }

      scaffoldMessenger.clearSnackBars();
    } catch (e) {
      scaffoldMessenger.clearSnackBars();
      final theme = Theme.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: theme.colorScheme.errorContainer,
          closeIconColor: theme.colorScheme.onErrorContainer,
          content: Text(
            e.toLocalizedString(widget.outerContext),
            style: TextStyle(color: theme.colorScheme.onErrorContainer),
          ),
          duration: const Duration(seconds: 30),
          showCloseIcon: true,
        ),
      );
      rethrow;
    }

    return;
  }
}

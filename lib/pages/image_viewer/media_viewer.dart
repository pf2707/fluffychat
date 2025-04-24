import 'dart:io';

import 'package:fluffychat/pages/chat/events/custom/message_type_extension.dart';
import 'package:fluffychat/pages/chat/events/custom/multiple_images_impl.dart';
import 'package:fluffychat/pages/image_viewer/media_viewer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';

import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/utils/show_scaffold_dialog.dart';
import 'package:fluffychat/widgets/share_scaffold_dialog.dart';
import '../../utils/matrix_sdk_extensions/event_extension.dart';

class MediaViewerItem {
  Event event;
  String? url;
  String type;
  String? name;
  String? thumbUrl;
  double? aspectRatio;

  MediaViewerItem({
    required this.event,
    this.url,
    required this.type,
    this.name,
    this.thumbUrl,
    this.aspectRatio,
  });

  String get tagId {
    return event.eventId + (url != null ? "_$url!" : "");
  }

  bool get isVideo {
    return type.startsWith("video");
  }

  bool get isImage {
    return type.startsWith("image");
  }
}

class MediaViewer extends StatefulWidget {
  final Event event;
  final int subIndex;
  final Timeline? timeline;
  final BuildContext outerContext;

  const MediaViewer(
    this.event, {
    required this.outerContext,
    this.subIndex = 0,
    this.timeline,
    super.key,
  });

  @override
  MediaViewerController createState() => MediaViewerController();
}

class MediaViewerController extends State<MediaViewer> {
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    allItems = widget.timeline?.events
        .where((event) => _isValid(event))
        .toList()
        .reversed
        .expand((e) {
          if (e.messageType == MessageTypesExt.Medias) {
            //Media
            final medias = MultipleImagesImpl.getListOfImageUrls(e);
            return medias.map((info) => MediaViewerItem(event: e, url: info.url, type: info.fileType, name: info.name, thumbUrl: info.thumbUrl, aspectRatio: info.aspectRatio,)).toList();
          } else if (e.messageType == MessageTypes.Video) {
            return [MediaViewerItem(event: e, type: "video")];
          }
          //Image
          return [MediaViewerItem(event: e, type: "image")];
        })
        .toList() ?? [];
    var index = allItems.indexWhere((item) => item.event.eventId == widget.event.eventId);
    if (index < 0) {
      index = 0;
    } else {
      final event = allItems[index].event;
      if (event.messageType == MessageTypesExt.Medias) {
        index += widget.subIndex;
      }
    }
    pageController = PageController(initialPage: index);
  }

  late final PageController pageController;

  // late final List<Event> allEvents;
  late final List<MediaViewerItem> allItems;

  final videoMatrixFiles = <String, MatrixFile>{}; //key: item tagId
  final videoDownloadedFiles = <String, File>{}; //key: item tagId

  bool _isValid(Event event) {
    final valid = (event.messageType == MessageTypes.Image ||
        event.messageType == MessageTypes.Video ||
        event.messageType == MessageTypesExt.Medias);
    return valid;
  }

  void onKeyEvent(KeyEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        if (canGoBack) prevImage();
        break;
      case LogicalKeyboardKey.arrowRight:
        if (canGoNext) nextImage();
        break;
    }
  }

  void prevImage() async {
    await pageController.previousPage(
      duration: FluffyThemes.animationDuration,
      curve: FluffyThemes.animationCurve,
    );
    if (!mounted) return;
    setState(() {});
  }

  void nextImage() async {
    await pageController.nextPage(
      duration: FluffyThemes.animationDuration,
      curve: FluffyThemes.animationCurve,
    );
    if (!mounted) return;
    setState(() {});
  }

  int get _index => pageController.page?.toInt() ?? 0;

  Event get currentEvent => allItems[_index].event;

  bool get canGoNext => _index < allItems.length - 1;

  bool get canGoBack => _index > 0;

  /// Forward this image to another room.
  void forwardAction() => showScaffoldDialog(
    context: context,
    builder: (context) => ShareScaffoldDialog(
      items: [ContentShareItem(currentEvent.content)],
    ),
  );

  /// Save this file with a system call.
  void saveFileAction(BuildContext context) {
    final item = allItems[_index];
    if (item.event.messageType == MessageTypesExt.Medias) {
      final file = videoMatrixFiles[item.tagId];
      if (file != null) {
        currentEvent.saveFileDirectly(context, file);
      }
    } else {
      currentEvent.saveFile(context);
    }
  }

  /// Save this file with a system call.
  void shareFileAction(BuildContext context) {
    final item = allItems[_index];
    if (item.event.messageType == MessageTypesExt.Medias) {
      final file = videoMatrixFiles[item.tagId];
      if (file != null) {
        currentEvent.shareFileDirectly(context, file);
      }
    } else {
      currentEvent.shareFile(context);
    }
  }

  static const maxScaleFactor = 1.5;

  /// Go back if user swiped it away
  void onInteractionEnds(ScaleEndDetails endDetails) {
    if (PlatformInfos.usesTouchscreen == false) {
      if (endDetails.velocity.pixelsPerSecond.dy >
          MediaQuery.of(context).size.height * maxScaleFactor) {
        Navigator.of(context, rootNavigator: false).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) => MediaViewerView(this);
}

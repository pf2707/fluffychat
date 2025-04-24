import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:fluffychat/pages/image_viewer/media_viewer.dart';
import 'package:fluffychat/utils/client_download_content_extension.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/widgets/hover_builder.dart';
import 'package:fluffychat/widgets/mxc_image.dart';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class MediaViewerView extends StatelessWidget {
  final MediaViewerController controller;
  final videoControllers = <String, ChewieController>{};

  MediaViewerView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final iconButtonStyle = IconButton.styleFrom(
      backgroundColor: Colors.black.withAlpha(200),
      foregroundColor: Colors.white,
    );
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withAlpha(128),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            style: iconButtonStyle,
            icon: const Icon(Icons.close),
            onPressed: Navigator.of(context).pop,
            color: Colors.white,
            tooltip: L10n.of(context).close,
          ),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              style: iconButtonStyle,
              icon: const Icon(Icons.reply_outlined),
              onPressed: controller.forwardAction,
              color: Colors.white,
              tooltip: L10n.of(context).share,
            ),
            const SizedBox(width: 8),
            IconButton(
              style: iconButtonStyle,
              icon: const Icon(Icons.download_outlined),
              onPressed: () => controller.saveFileAction(context),
              color: Colors.white,
              tooltip: L10n.of(context).downloadFile,
            ),
            const SizedBox(width: 8),
            if (PlatformInfos.isMobile)
            // Use builder context to correctly position the share dialog on iPad
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Builder(
                  builder: (context) => IconButton(
                    style: iconButtonStyle,
                    onPressed: () => controller.shareFileAction(context),
                    tooltip: L10n.of(context).share,
                    color: Colors.white,
                    icon: Icon(Icons.adaptive.share_outlined),
                  ),
                ),
              ),
          ],
        ),
        body: HoverBuilder(
          builder: (context, hovered) => Stack(
            children: [
              KeyboardListener(
                focusNode: controller.focusNode,
                onKeyEvent: controller.onKeyEvent,
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: controller.allItems.length,
                  itemBuilder: (context, i) => InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 10.0,
                    onInteractionEnd: controller.onInteractionEnds,
                    child: Center(
                      child: Hero(
                        tag: controller.allItems[i].tagId,
                        child: GestureDetector(
                          // Ignore taps to not go back here:
                          onTap: () {},
                          child: controller.allItems[i].isVideo ?
                          _videoItem(controller.allItems[i]) :
                          (
                            //Image
                            controller.allItems[i].url != null ?
                            SizedBox(
                              width: double.infinity, height: double.infinity,
                              child: Center(
                                child: MxcImage(
                                  key: ValueKey(controller.allItems[i].tagId),
                                  uri: Uri.tryParse(controller.allItems[i].url!),
                                  fit: BoxFit.contain,
                                  isThumbnail: false,
                                  animated: true,
                                ),
                              ),
                            ) :
                            SizedBox(
                              width: double.infinity, height: double.infinity,
                              child: Center(
                                child: MxcImage(
                                  key: ValueKey(controller.allItems[i].tagId),
                                  event: controller.allItems[i].event,
                                  fit: BoxFit.contain,
                                  isThumbnail: false,
                                  animated: true,
                                ),
                              ),
                            )
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (hovered && controller.canGoBack)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: IconButton(
                      style: iconButtonStyle,
                      tooltip: L10n.of(context).previous,
                      icon: const Icon(Icons.chevron_left_outlined),
                      onPressed: controller.prevImage,
                    ),
                  ),
                ),
              if (hovered && controller.canGoNext)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: IconButton(
                      style: iconButtonStyle,
                      tooltip: L10n.of(context).next,
                      icon: const Icon(Icons.chevron_right_outlined),
                      onPressed: controller.nextImage,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _videoItem(MediaViewerItem item) {
    return FutureBuilder(
      future: _downloadVideo(item),
      builder: (ctx, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final tagId = item.tagId;
          var videoController = videoControllers[tagId];
          videoController ??= ChewieController(
            useRootNavigator: false,
            aspectRatio: item.aspectRatio,
            videoPlayerController: VideoPlayerController.file(snapshot.data!),
            autoPlay: false,
            autoInitialize: true,
          );
          videoControllers[tagId] = videoController;
          return Center(
            child: Chewie(controller: videoController),
          );
        }
        return const SizedBox();
      },
    );
  }

  Future<File?> _downloadVideo(MediaViewerItem item) async {
    final downloadedFile = controller.videoDownloadedFiles[item.tagId];
    if (downloadedFile != null) { return downloadedFile; }

    final tempDir = await getTemporaryDirectory();

    if (item.url != null) {
      //Video from multiple medias
      final uri = Uri.tryParse(item.url!);
      if (uri != null) {
        final fileName = Uri.encodeComponent(uri.pathSegments.last);
        final file = File('${tempDir.path}/${fileName}_${item.name}');
        if (await file.exists() == false) {
          final data = await item.event.room.client.database?.getFile(uri);
          if (data != null) {
            controller.videoMatrixFiles[item.tagId] = MatrixFile(bytes: data, name: item.name ?? "", mimeType: item.type);
            final result = await file.writeAsBytes(data);
            controller.videoDownloadedFiles[item.tagId] = result;
          } else {
            try {
              final downloadedData = await item.event.room.client.downloadMxcCached(uri);
              controller.videoMatrixFiles[item.tagId] = MatrixFile(bytes: downloadedData, name: item.name ?? "", mimeType: item.type);
              final result = await file.writeAsBytes(downloadedData);
              controller.videoDownloadedFiles[item.tagId] = result;
            } catch (e) {
              return null;
            }
          }
        }

        return file;
      }
    } else {
      //Single video -> download from Event itself
      final matrixFile = await item.event.downloadAndDecryptAttachment();
      controller.videoMatrixFiles[item.tagId] = matrixFile;

      final file = File('${tempDir.path}/${matrixFile.name}');
      if (await file.exists() == false) {
        final result = await file.writeAsBytes(matrixFile.bytes);
        controller.videoDownloadedFiles[item.tagId] = result;
      }

      return file;
    }
    return null;
  }
}

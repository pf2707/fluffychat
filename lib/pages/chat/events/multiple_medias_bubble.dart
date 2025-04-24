
import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/model/media.dart';
import 'package:fluffychat/pages/chat/events/custom/multiple_images_impl.dart';
import 'package:fluffychat/pages/image_viewer/media_viewer.dart';
import 'package:fluffychat/utils/url_launcher.dart';
import 'package:fluffychat/widgets/blur_hash.dart';
import 'package:fluffychat/widgets/mxc_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:matrix/matrix.dart';

class MultipleMediasBubble extends StatelessWidget {
  final Event event;
  final bool tapToView;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? linkColor;
  final bool animated;
  final BorderRadius? borderRadius;
  final Timeline? timeline;

  const MultipleMediasBubble(
    this.event, {
      this.tapToView = true,
      this.animated = false,
      this.borderRadius,
      this.timeline,
      this.textColor,
      this.linkColor,
      this.backgroundColor,
      super.key,
    });

  final _perImageWidth = 120.0;
  final _padding = 2.0;

  @override
  Widget build(BuildContext context) {
    final fullWidth = _perImageWidth * 2 + _padding;
    var height = _perImageWidth;
    final medias = MultipleImagesImpl.getListOfImageUrls(event);
    if (medias.length > 2) {
      height = fullWidth;
    }

    final borderRadius =
        this.borderRadius ?? BorderRadius.circular(AppConfig.borderRadius);

    final caption = MultipleImagesImpl.getCaption(event);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: fullWidth, height: height,
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity, height: _perImageWidth,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _media(context, medias[0], 0, _perImageWidth),
                      ),
                      SizedBox(width: _padding),
                      Expanded(
                        flex: 1,
                        child: _media(context, medias[1], 1, _perImageWidth),
                      ),
                    ],
                  ),
                ),

                if (medias.length > 2)...[
                  SizedBox(height: _padding),
                  if (medias.length == 3)
                    _media(context, medias[2], 2, fullWidth)
                  else
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _media(context, medias[2], 2, _perImageWidth),
                        ),
                        SizedBox(width: _padding),
                        Expanded(
                          flex: 1,
                          child: medias.length > 4 ?
                          SizedBox(
                            width: _perImageWidth, height: _perImageWidth,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: _media(context, medias[3], 3, _perImageWidth),
                                ),
                                Positioned.fill(
                                  child: InkWell(
                                    onTap: () => _tap(context, 3),
                                    child: Container(
                                      width: _perImageWidth, height: _perImageWidth,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.65),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "+${(medias.length - 3).toString()}",
                                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: Colors.white),
                                        ),
                                      ),
                                    ),)
                                )
                              ],
                            ),
                          ) :
                          _media(context, medias[3], 3, _perImageWidth),
                        ),
                      ],
                    ),
                ],
              ],
            ),
          ),
        ),

        if (caption != null && caption.isNotEmpty)
          Container(
            width: fullWidth,
            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            color: backgroundColor ?? Colors.transparent,
            child: Linkify(
              text: caption,
              style: TextStyle(
                color: textColor ?? Colors.black,
                fontSize: AppConfig.fontSizeFactor * AppConfig.messageFontSize,
              ),
              options: const LinkifyOptions(humanize: false),
              linkStyle: TextStyle(
                color: linkColor,
                fontSize: AppConfig.fontSizeFactor * AppConfig.messageFontSize,
                decoration: TextDecoration.underline,
                decorationColor: linkColor,
              ),
              onOpen: (url) => UrlLauncher(context, url.url).launchUrl(),
            ),
          ),
      ],
    );
  }

  Widget _media(BuildContext context, Media info, int index, double width) {
    final theme = Theme.of(context);

    if (info.showPlaceholder) {
      return SizedBox(
        width: width, height: _perImageWidth,
        child: _buildPlaceholder(width, _perImageWidth),
      );
    }

    if (info.isVideo) {
      return InkWell(
        onTap: () => _tap(context, index),
        child: SizedBox(
            width: width, height: _perImageWidth,
            child: Stack(
              children: [
                Positioned.fill(
                  child: MxcImage(
                    uri: Uri.tryParse(info.thumbUrl ?? ""),
                    event: event,
                    width: width,
                    height: _perImageWidth,
                    fit: BoxFit.cover,
                    animated: animated,
                    isThumbnail: true,
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface.withOpacity(0.3),
                      ),
                      icon: const Icon(Icons.play_circle_outlined),
                      onPressed: () => _tap(context, index),
                    ),
                  ),
                ),
              ],
            ),
          ),
      );
    } else if (info.isImage) {
      return InkWell(
        onTap: () => _tap(context, index),
        child: MxcImage(
          uri: Uri.tryParse(info.url),
          width: width,
          height: _perImageWidth,
          fit: BoxFit.cover,
          animated: animated,
          isThumbnail: true,
        ),
      );
    }
    return SizedBox(width: width, height: width);
  }

  _tap(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => MediaViewer(
        event,
        timeline: timeline,
        outerContext: context,
        subIndex: index,
      ),
    );
  }

  Widget _buildPlaceholder(double width, double height) {
    final String blurHashString =
    event.infoMap['xyz.amorgan.blurhash'] is String
        ? event.infoMap['xyz.amorgan.blurhash']
        : 'LEHV6nWB2yk8pyo0adR*.7kCMdnj';
    return BlurHash(
      blurhash: blurHashString,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}

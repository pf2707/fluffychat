
import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pages/chat/events/custom/multiple_images_impl.dart';
import 'package:fluffychat/utils/url_launcher.dart';
import 'package:fluffychat/widgets/blur_hash.dart';
import 'package:fluffychat/widgets/mxc_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:matrix/matrix.dart';

class MultipleImagesBubble extends StatelessWidget {
  final Event event;
  final bool tapToView;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? linkColor;
  final bool animated;
  final BorderRadius? borderRadius;
  final Timeline? timeline;

  const MultipleImagesBubble(
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
    final imageUrls = MultipleImagesImpl.getListOfImageUrls(event);
    if (imageUrls.length > 2) {
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
                        child: _image(imageUrls[0], _perImageWidth),
                      ),
                      SizedBox(width: _padding),
                      Expanded(
                        flex: 1,
                        child: _image(imageUrls[1], _perImageWidth),
                      ),
                    ],
                  ),
                ),

                if (imageUrls.length > 2)...[
                  SizedBox(height: _padding),
                  if (imageUrls.length == 3)
                    _image(imageUrls[2], fullWidth)
                  else
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _image(imageUrls[2], _perImageWidth),
                        ),
                        SizedBox(width: _padding),
                        Expanded(
                          flex: 1,
                          child: imageUrls.length > 4 ?
                          SizedBox(
                            width: _perImageWidth, height: _perImageWidth,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: _image(imageUrls[3], _perImageWidth),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    width: _perImageWidth, height: _perImageWidth,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.65),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "+${(imageUrls.length - 3).toString()}",
                                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ) :
                          _image(imageUrls[3], _perImageWidth),
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

  Widget _image(String url, double width) {
    return MxcImage(
      uri: Uri.tryParse(url),
      event: event,
      width: width,
      height: _perImageWidth,
      fit: BoxFit.cover,
      animated: animated,
      isThumbnail: true,
    );
  }
}

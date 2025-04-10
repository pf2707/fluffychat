
import 'package:matrix/matrix.dart';

extension MessageTypesExt on MessageTypes {
  static const String Images = 'm.images';
}

class MultipleImagesImpl {

  static Map<String, dynamic> messageContentFrom(List<String> urls, {String? caption}) {
    return {
      'msgtype': MessageTypesExt.Images,
      'body': urls,
      "caption": caption,
    };
  }

  static List<String> getListOfImageUrls(Event event) {
    final body = event.content.tryGetList<String>("body") ?? [];
    return body;
  }

  static String? getCaption(Event event) {
    final caption = event.content.tryGet<String>('caption');
    return caption;
  }

  static bool hasCaption(Event event) {
    final caption = event.content.tryGet<String>('caption');
    return caption != null && caption.isNotEmpty;
  }
}
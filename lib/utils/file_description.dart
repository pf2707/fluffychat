import 'package:matrix/matrix.dart';

extension FileDescriptionExtension on Event {
  String? get fileDescription {
    if (!{
      MessageTypes.File,
      MessageTypes.Image,
      MessageTypes.Video,
    }.contains(messageType)) {
      return null;
    }
    final formattedBody = content.tryGet<String>('formatted_body');
    if (formattedBody != null) return formattedBody;

    final filename = content.tryGet<String>('filename');
    final body = content.tryGet<String>('body');
    if (filename != body && body != null && filename != null) return body;
    return null;
  }

  double? get videoAspectRatio {
    if (!{
      MessageTypes.Video,
    }.contains(messageType)) {
      return null;
    }
    final aspectRatio = content.tryGet<double>('aspect_ratio');
    return aspectRatio;
  }
}

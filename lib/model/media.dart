
import 'package:cross_file/cross_file.dart';

class Media {
  late String fileType;
  late String url;
  late String name;
  String? thumbUrl;
  double? aspectRatio;
  String? placeholderFilePath; //used to set placeholder while uploading and sending real message

  Media({
    required this.fileType,
    required this.url,
    required this.name,
    this.thumbUrl,
    this.aspectRatio,
    this.placeholderFilePath,
  });

  bool get showPlaceholder {
    return placeholderFilePath != null;
  }

  Media.fromJson(Map<String, dynamic> json) {
    fileType = json['type'] ?? "unknown";
    url = json['url'] ?? "";
    name = json['name'] ?? "";
    thumbUrl = json['thumb_url'];
    aspectRatio = json['aspect_ratio'];
    placeholderFilePath = json['placeholderFilePath'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = fileType;
    map['url'] = url;
    map['name'] = name;
    map['thumb_url'] = thumbUrl;
    map['aspect_ratio'] = aspectRatio;
    map['placeholderFilePath'] = placeholderFilePath;
    return map;
  }

  bool get isVideo {
    return fileType.startsWith("video");
  }

  bool get isImage {
    return fileType.startsWith("image");
  }
}

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

extension ScaffoldMessengerStateExt on ScaffoldMessengerState {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showLoadingSnackBar(
      String title,
      ) {
    clearSnackBars();
    return showSnackBar(
      SnackBar(
        duration: const Duration(minutes: 5),
        dismissDirection: DismissDirection.none,
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 16),
            Text(title),
          ],
        ),
      ),
    );
  }
}

extension XFileExt on XFile {

  String get fileType {
    return _currentMimeType ?? "unknown";
  }

  String? get _currentMimeType {
    final type = mimeType ?? lookupMimeType(path);
    return type;
  }

  bool get isImage {
    return _currentMimeType?.startsWith("image") ?? false;
  }

  bool get isVideo {
    return _currentMimeType?.startsWith("video") ?? false;
  }
}
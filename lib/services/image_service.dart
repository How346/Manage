import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndPersist({required ImageSource source}) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (file == null) return null;

    final documents = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(documents.path, 'school_media'));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final extension = p.extension(file.path).isEmpty ? '.jpg' : p.extension(file.path);
    final target = p.join(
      mediaDir.path,
      'photo_${DateTime.now().microsecondsSinceEpoch}$extension',
    );
    await File(file.path).copy(target);
    return target;
  }

  Future<void> deleteIfExists(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

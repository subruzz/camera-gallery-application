import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class FavNotifier extends StateNotifier<List<File>> {
  FavNotifier() : super([]);
  Future<String> createInternalFolder() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String folderName = 'galleryimg';
    String folderPath = '$appDocPath/$folderName';

    // Create the folder if it doesn't exist
    if (!await Directory(folderPath).exists()) {
      await Directory(folderPath).create(recursive: true);
    }
    return folderPath;
  }

  //add those images to the separate folder
  Future<void> addimage(
    File file,
  ) async {
    String folderPath = await createInternalFolder();
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String imageName = 'image_$timestamp${p.extension(file.path)}';
    String imagePath = '$folderPath/$imageName';
    await file.copy(imagePath);

//     List<int> imageBytes = await file.readAsBytes();

//     File(imagePath).writeAsBytesSync(imageBytes);
    await retrieveImages();
  }

  Future<void> retrieveImages() async {
    String folderPath = await createInternalFolder();
    Directory directory = Directory(folderPath);
    List<FileSystemEntity> files = await directory.list().toList();
    List<File> imageFiles = files.whereType<File>().toList();
    state = imageFiles;
  }

  Future<void> removeImage(File file) async {
    await file.delete();
    await retrieveImages();
  }
}

final imgProvider =
    StateNotifierProvider<FavNotifier, List<File>>((ref) => FavNotifier());

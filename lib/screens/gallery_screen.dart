import 'dart:io';

import 'package:cameramain/provider/img_provider.dart';
import 'package:cameramain/widgets/each_images.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // creating  the separate folder
  Future<String> createInternalFolder() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String folderName = 'cameraPhotos';
      String folderPath = '$appDocPath/$folderName';

      // Create the folder if it doesn't exist
      if (!await Directory(folderPath).exists()) {
        await Directory(folderPath).create(recursive: true);
      }
      print('created $folderPath');
      return folderPath;
    } catch (error) {
      showFailedSnackBar('Failed to create a folder');
      return '';
    }
  }
  // this is good
  
 
// this is
  void showFailedSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  //add those images to the separate folder
  Future<void> addimage(
    File file,
  ) async {
    try {
      String folderPath = await createInternalFolder();
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String imageName = 'image_$timestamp${p.extension(file.path)}';
      String imagePath = '$folderPath/$imageName';
      await file.copy(imagePath);
      // Read the image file
      // List<int> imageBytes = await file.readAsBytes();

// Save the image with the original bytes
      // File(imagePath).writeAsBytesSync(imageBytes);
      setState(() {});
    } catch (err) {
      showFailedSnackBar('failed to add images');
    }
  }

  List<File> imageFiles = [];
  Future<List<File>> retrieveImages() async {
    String folderPath = await createInternalFolder();
    Directory directory = Directory(folderPath);
    List<FileSystemEntity> files = directory.listSync();
    List<File> imageFiles = files.whereType<File>().toList();
    imageFiles
        .sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

    return imageFiles;
  }

  Future<void> removeImage(File file) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                ),
              ),
              IconButton(
                  onPressed: () async {
                    try {
                      await file.delete();
                      await retrieveImages();
                      setState(() {});
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      showFailedSnackBar('failed to delete try again!');
                    }
                  },
                  icon: const Icon(
                    Icons.check,
                    color: Colors.green,
                  )),
            ],
          )
        ],
        title: const Text(
          'Are you sure you want to delete?',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.normal, fontSize: 18),
        ),
      ),
    );
  }

  //picking image from camera
  File? _selectedImage;
  void pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 600, imageQuality: 100);
    if (pickedImage == null) {
      return;
    }

    _selectedImage = File(pickedImage.path);
    await addimage(_selectedImage!);

    // await ref.read(imgProvider.notifier).addimage(
    //       _selectedImage!,
    //     );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pickImage();
        },
        child: const Icon(
          Icons.camera,
        ),
      ),
      appBar: AppBar(
        title: const Text('Gallery'),
      ),
      body:
          //  GridView.builder(
          //   padding: const EdgeInsets.all(10),
          //   itemCount: imgList.length,
          //   gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          //     maxCrossAxisExtent: 150, // Adjust this value based on your needs
          //     crossAxisSpacing: 8, // Adjust spacing between items
          //     mainAxisSpacing: 8, // Adjust spacing between rows
          //   ),
          //   itemBuilder: (ctx, index) => EachImages(
          //       img: imgList,
          //       index: index,
          //       totalIndex: imgList.length,
          //       removeImage: removeImage),
          // )
          FutureBuilder(
        future: retrieveImages(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
              'No images available.',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: Colors.white, fontSize: 20),
            ));
          } else {
            return GridView.builder(
              padding: const EdgeInsets.all(7),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent:
                    150, // Adjust this value based on your needs
                crossAxisSpacing: 8, // Adjust spacing between items
                mainAxisSpacing: 8, // Adjust spacing between rows
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (ctx, index) => EachImages(
                  img: snapshot.data!,
                  index: index,
                  totalIndex: snapshot.data!.length,
                  removeImage: removeImage),
            );
          }
        }),
      ),
    );
  }
}

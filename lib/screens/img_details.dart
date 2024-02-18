import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:zoom_widget/zoom_widget.dart';

class ImageDetails extends ConsumerStatefulWidget {
  const ImageDetails(
      {super.key,
      required this.img,
      required this.index,
      required this.totalLength});
  final List<File> img;
  final int index;
  final int totalLength;

  @override
  ConsumerState<ImageDetails> createState() => _ImageDetailsState();
}

class _ImageDetailsState extends ConsumerState<ImageDetails> {
  int currentIndex = 0;
  @override
  void initState() {
    currentIndex = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String fullPath = widget.img[currentIndex].path;
    String fileName = p.basename(fullPath);
    return Scaffold(
        appBar: AppBar(
          title: Text(fileName),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                onPressed: () async {},
                icon: const Icon(
                  Icons.favorite,
                  // Optionally, you can set the color
                ),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                onPageChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemCount: widget.img.length,
                controller: PageController(initialPage: widget.index),
                itemBuilder: (context, pageIndex) {
                  return InteractiveViewer(
                    maxScale: 5,
                    child: Center(
                      child: Hero(
                        tag: widget.img[pageIndex],
                        child: Image.file(
                          widget.img[pageIndex],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Text(
              '${currentIndex + 1}/${widget.totalLength}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ],
        ));
  }
}

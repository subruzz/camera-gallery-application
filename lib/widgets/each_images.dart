import 'dart:io';

import 'package:cameramain/screens/img_details.dart';
import 'package:flutter/material.dart';

class EachImages extends StatelessWidget {
  const EachImages(
      {super.key,
      required this.img,
      required this.index,
      required this.totalIndex,
      required this.removeImage});
  final List<File> img;
  final int index;
  final int totalIndex;
  final void Function(File file) removeImage;
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: img[index],
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => ImageDetails(
                totalLength: totalIndex,
                index: index,
                img: img,
              ),
            ),
          );
        },
        onLongPress: () {
          removeImage(img[index]);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.black,
            ),
          ),
          child: Image.file(
            img[index],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity, // Adjust the fit as needed
          ),
        ),
      ),
    );
  }
}

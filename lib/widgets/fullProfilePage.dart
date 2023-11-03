import 'package:antonios/constants/appConstantnts.dart';
import 'package:antonios/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';


class FullPhotoPage extends StatelessWidget {
  final String url;

  const FullPhotoPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        title: const Text(
          AppConstants.fullPhotoTitle,
          style: TextStyle(color: AppColor.secondaryColor),
        ),
        centerTitle: true,
      ),
      body: PhotoView(
        imageProvider: NetworkImage(url),
      ),
    );
  }
}
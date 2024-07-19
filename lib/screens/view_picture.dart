import 'package:anime_list_app/widgets/cached_image/cached_image_widget.dart';
import 'package:flutter/material.dart';

class ViewPicturePage extends StatefulWidget {
  final dynamic imageData;

  const ViewPicturePage({
    super.key,
    required this.imageData
  });

  @override
  State<ViewPicturePage> createState() => ViewPicturePageState();
}

class ViewPicturePageState extends State<ViewPicturePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picture'),
      ),
      body: InteractiveViewer(
        child: Center(
          child: CachedImageWidget(imageClass: widget.imageData)
        ),
      ),
    );
  }
}

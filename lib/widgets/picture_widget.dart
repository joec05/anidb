import 'package:anime_list_app/constants/ui/screen_size/screen_size.dart';
import 'package:anime_list_app/styles/default_values/default_values.dart';
import 'package:anime_list_app/widgets/cached_image/cached_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PictureWidget extends StatefulWidget {
  final dynamic imageData;

  const PictureWidget({
    super.key,
    required this.imageData
  });

  @override
  State<PictureWidget> createState() => PictureWidgetState();
}

class PictureWidgetState extends State<PictureWidget>{
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/view-picture', extra: widget.imageData),
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.symmetric(
          horizontal: getScreenWidth() * 0.015,
          vertical: getScreenHeight() * 0.0025,
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        child: CachedImageWidget(
          imageClass: widget.imageData,
          width: animeGridDisplayCoverSize.width,
          height: animeGridDisplayCoverSize.height
        ),
      ),
    );
  }
}
